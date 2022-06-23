---
title: CX as Code and Remote Modules 
tags: Genesys Cloud,CX as Code, Remote Modules, Terraform
date: 2022-06-21
author: john.carnell@genesys.comn
category: 6
---

Greetings everyone. It is June 2022, the year is half over and I hope everyone is enjoying the summer months. I know here in Raleigh, North Carolina it is a hot and humid. The heat will not stop until October. Today, I want to introduce you guys to the concept of Terraform modules and how you can use them from within your own **CX as Code** projects. Terraform modules allow you to make your Terraform flows more organized and reusable. In this blog post we are going to cover three major topic areas:

1. What is a Terraform module
2. What is a Terraform remote module
3. The Genesys Cloud DevOps Remote Module Repository

## What is a Terraform module

If you have done any work with **CX as Code** and Terraform you know that you often start a project using a single Terraform file (e.g. `main.tf`). However, as the size of the project grows, your your single Terraform configuration can quickly grow large as you add more and more resource definitions to your project. Many DevOps engineers will start decomposing their Terraform resources into multiple files that contain related resource definitions. 

:::{"alert":"warning","title":"What is the right size for a CX as Code project?","autoCollapse":false}
One of the more common mistakes developers make with **CX as Code** and Terraform is that they try to manage their entire contact center infrastructure in a single Terraform project residing in a single source control repository using a single backing state. A better approach is to decompose your contact center into major areas of functionality and break your Terraform projects into separate repositories and backing states. I personally recommend using your Genesys Cloud Architect flows as a means to look for natural divisions within your contact center. However, even if you do decompose to align with your Genesys Cloud Architect flows, your Terraform project files can still get large because a single Genesys Cloud Architect flow can end up with dozens of dependencies that need to be deployed along with the flow. Terraform modules help you manage the size and complexity of these type of projects. 

For more information on best practices in building out your **CX as Code** projects, take a look at this [best practices](/blog/2022-05-12-cx-as-code-devops-best-practices/) blog post.
:::

There is nothing wrong with breaking your resources into multiple Terraform files, but there might be times when you want parameterize and re-use resource definitions within the same Terraform code base. For example, you might want to create multiple Genesys Cloud queues with slightly different values for each queue. You could define each queue individually (like in the code block below):

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
The code above will work, but I am a dutiful follower of Dave Thomas and Andy Hunt's DRY principle. First documented in their classic book [The Pragmatic Programmer](https://www.amazon.com/Pragmatic-Programmer-journey-mastery-Anniversary-ebook/dp/B07VRS84D1/ref=sr_1_1?keywords=the+pragmatic+programmer+20th+anniversary+edition%2C+2nd+edition&qid=1655926310&sprefix=the+pragma%2Caps%2C81&sr=8-1), the DRY principle stands for: **Don't Repeat Yourself**. Any time I start seeing repetitive code that looks almost exactly the same, I stop and take a step back and see if I can simplify the code. With Terraform and *CX as Code*, rather then defining each queue resource individually, a better approach would be to generalize and encapsulate the definition of the queue resource inside a a Terraform module. 

A Terraform module allows you to wrap your resource definitions inside of function-like structure that accepts input parameters and publishes output parameters. Modules allow you to better organize your resources and then re-use them throughout your project. Typically, I like to setup my modules within a folder and file structure right within my Terraform project. While this is not required by Terraform I typically use the following structure for my **CX as Code** projects.

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

So let's write an example queue module using the structure above. We will begin with a `modules/queues/inputs.tf` file. This file defines all of the input values being passed into the module. Modules act as containers around the resources defined within them. This means a module can not reference a value outside of the module unless it is explicitly passed in as a Terraform input parameter, nor can values produced by the module be accessed outside of the module without explicitly passing the value outside the module via a Terraform output variable.

Here is a example implementation of our `inputs.tf` file.

```hcl
variable "classifier_queue_names" {
  type        = list(string)
  description = "A list of queues names that you want to have generated."
}
```

This module is going to allow you to parameterize 1 variable: a list of queue names.

:::{"alert":"warning","title":"Don't get overzealous with module input variables","autoCollapse":false}
Be careful not to make every parameter of a resource as an input variable for a module. Modules are meant for you to re-use the general definition of your resources with a tweak here or there for context specific values. I have seen developers take the concept of modules too far to the point where everything is parameterized and made a module.  For many Terraform projects, this can make things difficult to follow.
:::

The actual resource definition for the module is shown below (e.g. the `modules/queues/main.tf` file):

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

In the example above, we iterate through each of the queue names passed into the module via the `for_each=toset(var.classifier_queue_names)` line. The value read from the list passed into the module is bound to a variable called `each`. The `each.value` variable is used to set the `name` attribute on the **CX as Code** queue resource and also build a `description` using the `each.value` to build a string for the description. The rest of the attributes for the queue resource are kept as the same values.

As mentioned earlier, all values generated from within a module are available only with the module unless they are explicitly mapped to an output variable.  In our queue example there are often specific Genesys Cloud Architect flows and actions that can be associated with a queue.  In order to perform these type of mappings and make the created queue's ids available for consumption, we need to define an output variable to hold the values. To do this, we can create a file called `modules/queues/output.tf` that will define a map variable (called `queue_ids`) of all of the created queue ids where the key for the map is the queue name. An example `output.tf` file is shown below:

```
output "queue_ids" {
  value = {
    for queue in genesyscloud_routing_queue.Queues:
    queue.name => queue.id
  }
```

This will bind a variable called `queue_ids` to the module. We will show you how to access the output variable shortly.

At this point, you have all of the pieces defined for a module.  Now let's look at how you would include this module in one of your own Terraform projects. To use the module within your Terraform code, you can define use the `module` block within any of your Terraform files. I usually put my module configurations in the `main.tf` for the entire project.  Here is an example of how to configure our queue module we just defined:

```hcl
module "classifier_queues" {
  source                   = "../modules/queues"                                 ## Fully qualified or relative path from the main.tf
  classifier_queue_names   = ["401K", "IRA", "529", "GeneralSupport"]
}
```

The above module definition will attempt to load the queues modules, associate the module with the name `classifier_queues`.  Four queue names are passed in as input variables to the module: 401K, IRA, 529 and General Support. When you run `terraform init` for the first time, Terraform will check for the existence of the module. When a `terraform apply` is invoked, the above module will be called with each of the queues names passed in. Any output variables defined (e.g. the queue_ids) will be bound to the module name `classified queues`. Later on, if one of my Terraform resource definitions wanted to associate the 401K queue id created by this module to another resource, I could use the line `modules.classifier_queues.queue_ids["401K"]` to access to queue id for the created queue.

Several of our Genesys Cloud blueprints leverage modules to help organize their Terraform code. Examples of Terraform modules being used in this projects can be found in these repositories:

1. [Email AWS Comprehend blueprint](https://github.com/GenesysCloudBlueprints/email-aws-comprehend-blueprint)
2. [Building CI/CD pipelines using GitHub Actions](https://github.com/GenesysCloudBlueprints/email-aws-comprehend-blueprint)
3. [Emergency Group Lambda blueprint](https://github.com/GenesysCloudBlueprints/set-emergency-group-lambda-blueprint/tree/main/blueprint/terraform/modules)

Terraform modules are an extremely powerful mechanism for organizing and partitioning a large Terraform project into multiple pieces. While a Terraform module can help promote code re-use throughout a single project, how can you use modules across multiple Terraform projects? The answer is Terraform remote modules. 

## Terraform Remote modules
Terraform allows you to host your remote modules outside of the local filesystem so that they can be re-used across projects. Terraform remote modules can be stored inside of GitHub, Bitbucket, HTTP, AWS S3, and Google Cloud Service (GCS) buckets. Remote modules are an extremely powerful mechanism for building higher-level abstractions on top of a provider's resource that can then be easily shared across a project.

For example, here is how to configure a remote module that invokes the same `classifier_queues` resource configuration we used in the previous section of this blog post. In the configuration below, the remote module is being pulled down from a GitHub repository:

```hcl
module "classifier_queues" {
  source                   = "git::https://github.com/GenesysCloudDevOps/genesys-cloud-queues-demo.git?ref=main"
  classifier_queue_names   = ["401K", "IRA", "529", "GeneralSupport", "Banking"]
  classifier_queue_members = ["member id #1 (guid)", "member id #2 (guid)" ]    
}
```
When the `terraform init` command is run with the above configuration, Terraform will pull down a local copy of the above remote module. When `terraform apply` is executed the downloaded module will be executed with the parameters defined above (e.g. the `classifier_queue_names`, `classifier_queue_members`) will be passed to locally downloaded modules. 

## Introducing the Genesys Cloud DevOps Repository
As Genesys Cloud continues in its own Terraform journey, I am pleased to announce that the Developer Engagement team is launching a new open-source GitHub repository called [GenesysCloudDevOps](https://github.com/GenesysCloudDevOps/). This repository will house a variety of Terraform remote modules that you can use and leverage within your own **CX as Code** projects. Even with **CX as Code**, some Genesys Cloud resources can be difficult to configure because there is a great deal of meta-data that needs to be setup and configured to use it.  We hope that these remote modules will help simplify this type of configuration setup.

This Github repository includes remote modules for:

1. Configuring Genesys Cloud to use an [AWS Event Bridge](https://github.com/GenesysCloudDevOps/aws-event-bridge-module).
2. Configuring AWS Lambdas with [Genesys Cloud Integrations](https://github.com/GenesysCloudDevOps/integration-lambda-module) and [Genesys Cloud Data Actions](https://github.com/GenesysCloudDevOps/data-action-lambda-module).
3. Creating Genesys Cloud Data Actions for invoking various [Genesys Cloud APIs](https://github.com/GenesysCloudDevOps). Any repository that begins with the prefix `public-api-` is a data action that wrappers a Genesys Cloud public API call. 


There are three ways to use the Genesys Cloud remote module repository:

1.  **Directly copy the configuration into your project using these repositories as examples**. There is no requirement that you have to use these modules are remote modules. Review the resource configuration as examples and then cut and paste them directly into your Terraform project.
2.  **Reference the remote module directly within your own Terraform project**. This is the simplest and easiest way to leverage remote modules. Just point your Terraform project to the module and use it.
3.  **Fork the remote module repository into your own organization's repository**.  Many organizations have stringent code review processes and would prefer to manage the source code they use inside of their own GitHub repositories. You can always fork one of remote module repositories and leverage it within your own code.

:::{"alert":"warning","title":"Versioning of remote modules","autoCollapse":false}
While Terraform remote modules support the concept of versioning through the use of source control tags we do not tag our modules with a version number and the modules are always referenced off the main branch of the remote module repository. We will always make the best effort to not make a "breaking change" to a remote module, but we do not guarantee it. If you would like tighter control over the remote module source, I recommend you fork the repository you are going to use and maintain the code within your repository.
:::

## Closing Thoughts

I am a huge fan of Terraform modules. They allow me to better organize my Terraform code, reuse configuration and accelerate how quickly I can build Terraform/CX as Code configuration. The Developer Engagement team is going to continue to build out our GenesysCloudDevOps remote module repositories. We currently have 21 remote modules in our GenesysCloudDevOps repositories but plan on releasing more over the next several months. I hope you find these remote modules valuable and you can use them within your own projects. As always, we welcome Pull Requests ([PR](https://github.com/GenesysCloudDevOps)) for new submissions.
## Resources

1. [Beginning your CX as Code journey](/blog/2021-10-10-treating-contact-center-infrastructure-as-code/)
2. [Genesys Cloud CX as Code/DevOps best practices](/blog/2022-05-12-cx-as-code-devops-best-practices/)
3. [Building a Terraform module](https://www.terraform.io/language/modules)
4. [Using Remote Terraform module](https://www.terraform.io/language/modules/sources)
5. [Genesys Cloud DevOps GitHub Repository](https://github.com/GenesysCloudDevOps)
6. [Genesys Cloud Blueprints](https://github.com/GenesysCloudBlueprints)