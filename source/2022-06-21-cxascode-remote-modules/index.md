---
title: CX as Code and Remote Modules 
tags: Genesys Cloud,CX as Code, Remote Modules, Terraform
date: 2022-06-21
author: john.carnell
category: 6
---

Greetings, everyone, It is June 2022, the year is half over, and I hope everyone is enjoying the summer months. I know it is hot and humid here in Raleigh, North Carolina. The heat does not stop until October. Today, I want to introduce you to Terraform modules and how you can use them from within your own **CX as Code** projects. Terraform modules allow you to make your Terraform flows more organized and reusable. In this blog post, we cover three major topics:

1. What is a Terraform module
2. What is a Terraform remote module
3. The Genesys Cloud DevOps Remote Module repository

## What is a Terraform module
If you have done any work with **CX as Code** and, you know that you often start a project using a single Terraform file, for example, `main.tf`. However, as the project's size grows, your single Terraform configuration can quickly grow as you add more resource definitions to your project. Many DevOps engineers start decomposing their Terraform resources into multiple files that contain related resource definitions. 

:::{"alert":"warning","title":"What is the right size for a CX as Code project?","autoCollapse":false}
One of the common mistakes developers make with **CX as Code** and Terraform is that they try to manage their entire contact center infrastructure in a single Terraform project that reside in a single source control repository using a single backing state. A better approach is to decompose your contact center into major areas of functionality and break your Terraform projects into separate repositories and backing states. I recommend using your Genesys Cloud Architect flows to look for natural divisions within your contact center. However, even if you decompose to align with your Genesys Cloud Architect flows, your Terraform project files can become large because a single Architect flow can end up with dozens of dependencies that need to be deployed along with the flow. Terraform modules help you manage the size and complexity of these types of projects. 

For more information on best practices in building out your **CX as Code** projects, see [best practices](https://github.com/MyPureCloud/developer-center-blog/tree/master/source/2022-05-12-cx-as-code-devops-best-practices "Goes to the best practices repository page") in GitHub.
:::

There is nothing wrong with breaking your resources into multiple Terraform files. Sometimes you want to parameterize and reuse resource definitions within the same Terraform code base. For example, you might want to create multiple Genesys Cloud queues with slightly different values for each queue. As listed, you could define each queue individually:

```hcl
resource "genesyscloud_routing_queue" "401K_Queue" {
  name                     = 401K
  description              = "This is the 401K queues"
  acw_wrapup_prompt        = "MANDATORY_TIMEOUT"
  acw_timeout_ms           = 300000
  skill_evaluation_method  = "BEST"
  auto_answer_only         = true
  enable_transcription     = true
  enable_manual_assignment = true
}

resource "genesyscloud_routing_queue" "IRA_Queue" {
  name                     = IRA
  description              = "This is the IRA Queue"
  acw_wrapup_prompt        = "MANDATORY_TIMEOUT"
  acw_timeout_ms           = 300000
  skill_evaluation_method  = "BEST"
  auto_answer_only         = true
  enable_transcription     = true
  enable_manual_assignment = true
}
.....
```
The previous code works, but I am a dutiful follower of Dave Thomas and Andy Hunt's DRY principle. First documented in their classic book [The Pragmatic Programmer](https://www.amazon.com/Pragmatic-Programmer-journey-mastery-Anniversary-ebook/dp/B07VRS84D1/ref=sr_1_1?keywords=the+pragmatic+programmer+20th+anniversary+edition%2C+2nd+edition&qid=1655926310&sprefix=the+pragma%2Caps%2C81&sr=8-1 "Goes to the Pragmatic Programmer repository page"), the DRY principle stands for: **Don't Repeat Yourself**. Any time I start seeing repetitive code that looks almost the same, I stop and step back to see if I can simplify the code. With Terraform and *CX as Code*, instead of defining each queue resource individually, a better approach would be to generalize and encapsulate the definition of the queue resource inside a Terraform module. 

Terraform modules allow you to organize your resources better and reuse them throughout your project. A Terraform module enables you to wrap your resource definitions inside a function-like structure that accepts input parameters and publishes output parameters. Typically, I like to set up my modules within a folder and file structure within my Terraform project. While Terraform does not need this, I usually use the following structure for my **CX as Code** projects.

```
 .
└── main.tf                # The main Terraform definitions/
    ├── provider.tf            # Defines all of my providers used within my project 
    ├── variables.tf           # Input variables for the project
    └── modules/
        ├── queues/
        │   ├── inputs.tf         # Input variables for the project   
        │   ├── outputs.tf        # Output variables for the project
        │   └── main.tf           # The resource definitions
        ├── module1/
        └── module2/
```

Let's write an example queue module using the previous structure. We begin with a `modules/queues/inputs.tf` file. This file defines the input values passed into the module. Modules act as containers around the resources defined within them. This means that a module can not reference a value outside of the module unless it is explicitly passed in as a Terraform input parameter, nor can values made by the module be accessed outside of the module without explicitly passing the value outside the module via a Terraform output variable.

Here is a example implementation of our `inputs.tf` file.

```hcl
variable "classifier_queue_names" {
  type        = list(string)
  description = "A list of queue names that you want generated."
}
```

This module allows you to parameterize one variable: a list of queue names.

:::{"alert":"warning","title":"Don't get overzealous with module input variables","autoCollapse":false}
Modules are meant for you to reuse the general definition of your resources with a tweak here or there for context-specific values. Be careful not to make every parameter of a resource an input variable for a module. I have seen developers take the idea of modules too far to the point where everything is parameterized and done in a module. For many Terraform projects, this can make things difficult to follow.
:::

Listed is the actual resource definition, an example of the `modules/queues/main.tf` file:

```hcl
resource "genesyscloud_routing_queue" "Queues" {
  for_each                 = toset(var.classifier_queue_names)
  name                     = each.value
  description              = "${each.value} questions and answers"
  acw_wrapup_prompt        = "MANDATORY_TIMEOUT"
  acw_timeout_ms           = 300000
  skill_evaluation_method  = "BEST"
  auto_answer_only         = true
  enable_transcription     = true
  enable_manual_assignment = true
}
```

In the previous example, we iterate through each queue name passed into the module via the `for_each=toset(var.classifier_queue_names)` line. The value read from the list passed into the module is bound to a variable called `each`. The `each.value` variable is used to set the `name` attribute on the **CX as Code** queue resource and build a `description` using the `each.value` to build a string for the description. The rest of the attributes for the queue resource are kept at the same values.

As mentioned earlier, all values generated from within a module are available only with the module unless they are explicitly mapped to an output variable. In our queue example, there are often specific Genesys Cloud Architect flows and actions that can be associated with a queue. To do these mappings and make the created queue's ids available for consumption, we need to define an output variable to hold the values. To do this, we can create a file called `modules/queues/output.tf` that defines a map variable (called `queue_ids`) of all of the created queue ids where the key for the map is the queue name. The following is an example of the `output.tf` file:

```
output "queue_ids" {
  value = {
    for queue in genesyscloud_routing_queue.Queues:
    queue.name => queue.id
  }
```

This binds a variable called `queue_ids` to the module. We will show you how to access the output variable shortly.

You have all the pieces defined for a module. Now let's look at how you would include this module in one of your Terraform projects. To use the module within your Terraform code, you can define the `module` block within any of your Terraform files. I usually put my module configurations in the `main.tf` for the entire project. Here is an example of how to configure the defined queue module:

```hcl
module "classifier_queues" {
  source                   = "../modules/queues"                                 ## Fully qualified or relative path from the main.tf
  classifier_queue_names   = ["401K", "IRA", "529", "GeneralSupport"]
}
```

The previous module definition attempts to load the queues modules, associate the module with the name `classifier_queues`.  Four queue names are passed as input variables to the module: 401K, IRA, 529, and General Support. When you run `terraform init` for the first time, Terraform checks for the existence of the modules. When a `terraform apply` is invoked, the previous module is called with each queues name passed. Any output variables defined, for example, the queue_ids are bound to the module name `classified queues`. Later, if one of the Terraform resource definitions wanted to associate the 401K queue id created by this module to another resource, I could use the line `modules.classifier_queues.queue_ids["401K"]` to access the queue id for the created queue.

Several Genesys Cloud blueprints use modules to help organize their Terraform code. For more examples, see the following repositories:

1. [Email AWS Comprehend blueprint](https://github.com/GenesysCloudBlueprints/email-aws-comprehend-blueprint "Goes to the Email AWS Comprehend blueprint repository page") in GitHub.
2. [Building CI/CD pipelines using GitHub Actions](https://github.com/GenesysCloudBlueprints/email-aws-comprehend-blueprint "Goes to the BUilding CI/CD pipelines using GitHub Actions repository page") in GitHub.
3. [Emergency Group Lambda blueprint](https://github.com/GenesysCloudBlueprints/set-emergency-group-lambda-blueprint/tree/main/blueprint/terraform/modules "Goes to the Emergency Group Lambda blueprint repository page") in GitHub.

Terraform modules are an very powerful mechanism for organizing and partitioning a large project into multiple pieces. While a Terraform module can help promote code re-use throughout a single project, how can you use modules across multiple Terraform projects? The answer is Terraform remote modules. 

## Terraform Remote modules
Remote modules are an powerful mechanism for building higher-level abstractions on top of a provider's resource that can then be easily shared across a project. Terraform allows you to host your remote modules outside of the local filesystem so that they can be reused across projects. Terraform remote modules can be stored inside GitHub, Bitbucket, HTTP, AWS S3, and Google Cloud Service (GCS) buckets.

For example, here is how to configure a remote module that invokes the same `classifier_queues` resource configuration we used in the previous section of this blog post. The following configuration is the remote module that is pulled from a GitHub repository:

```hcl
module "classifier_queues" {
  source                   = "git::https://github.com/GenesysCloudDevOps/genesys-cloud-queues-demo.git?ref=main"
  classifier_queue_names   = ["401K", "IRA", "529", "GeneralSupport", "Banking"]
  classifier_queue_members = ["member id #1 (guid)", "member id #2 (guid)" ]    
}
```
When the `terraform init` command is run with the previous configuration, Terraform pulls down a local copy of the previous remote module. When `terraform apply` is executed, the downloaded module is executed with the previously defined parameters. For example, the `classifier_queue_names`, `classifier_queue_members`)  is passed to locally downloaded modules. 

## Introducing the Genesys Cloud DevOps repository
As Genesys Cloud continues in its own Terraform journey, I am pleased to announce that the Developer Engagement team is launching a new open-source GitHub repository called [GenesysCloudDevOps](https://github.com/GenesysCloudDevOps/). This repository houses various Terraform remote modules that you can use and apply within your own **CX as Code** projects. Even with **CX as Code**, some Genesys Cloud resources can be difficult to configure because a great deal of meta-data needs to be set up and configured to use it.  We hope these remote modules help simplify this configuration setup.

This GitHub repository includes remote modules for:

1. Configuring Genesys Cloud to use an [Amazon EventBridge](https://github.com/GenesysCloudDevOps/aws-event-bridge-module "Goes to the Amazon EventBridge repository page") in GitHub.
2. Configuring AWS Lambdas with [Genesys Cloud Integrations](https://github.com/GenesysCloudDevOps/integration-lambda-module) and [Genesys Cloud Data Actions](https://github.com/GenesysCloudDevOps/data-action-lambda-module "Goes to the Genesys Cloud Data Actions repository page") in GitHub.
3. Creating Genesys Cloud Data Actions for invoking various [Genesys Cloud APIs](https://github.com/GenesysCloudDevOps "Goes to the Genesys Cloud APIs repository page") in GitHub. Any repository that begins with the prefix `public-api-` is a data action that wrappers a Genesys Cloud public API call. 


There are three ways to use the Genesys Cloud remote module repository:

1.  **Directly copy the configuration into your project using these repositories as examples**. Review the resource configuration as examples and then cut and paste them directly into your Terraform project. There is no requirement that you have to use these modules are remote modules.
2.  **Reference the remote module directly within your own Terraform project**. This is the simplest and easiest way to use remote modules. Just point your Terraform project to the module and use it.
3.  **Fork the remote module repository into your own organization's repository**.  Many organizations have strict code review processes and would prefer to manage the source code they use inside of their own GitHub repositories. You can always fork one of the remote module repositories and use it within your code.

:::{"alert":"warning","title":"Versioning of remote modules","autoCollapse":false}
While Terraform remote modules support the idea of versioning through source control tags, we do not tag our modules with a version number, and the modules are always referenced off the main branch of the remote module repository. We always try not to make a "breaking change" to a remote module, but we do not guarantee it. If you want tighter control over the remote module source, I recommend you fork the repository you use and maintain the code within your repository.
:::

## Closing thoughts
I am a huge fan of Terraform modules. They allow me to organize my Terraform code better, reuse configuration and accelerate how quickly I can build Terraform/CX as Code configuration. The Developer Engagement team continues to build our GenesysCloudDevOps remote module repositories. We currently have 21 remote modules in our GenesysCloudDevOps repositories but plan on releasing more over the next several months. I hope you find these remote modules valuable and can use them in your projects. As always, we welcome Pull Requests ([PR](https://github.com/GenesysCloudDevOps "Goes to the Genesys CLoud DevOps repository page")) in GitHub for new submissions.

## Additional resources
* [How to begin your CX as Code Journey](/blog/2021-10-10-treating-contact-center-infrastructure-as-code/ "Goes to How to begin your CX as Code Journey repository page") in GitHub.
* [Genesys Cloud CX as Code/DevOps best practices](/blog/2022-05-12-cx-as-code-devops-best-practices/ "Goes to the enesys Cloud CX as Code/DevOps best practices repository page") in GitHub.
* [Modules](https://www.terraform.io/language/modules "Goes to the Modules page") on the Terraform website.
* [Module Sources](https://www.terraform.io/language/modules/sources "Goes to the Modules Sources page") on the Terraform website.
* [Genesys Cloud DevOps](https://github.com/GenesysCloudDevOps "Goes to the Genesys Cloud DevOps repository page") in GitHub.
* [Genesys Cloud Blueprints](https://github.com/GenesysCloudBlueprints "Goes to the Genesys CLoud Blueprints repository page") in GitHub.
