---
title: CX as Code and Remote Modules 
tags: Genesys Cloud,CX as Code, Remote Modules, Terraform
date: 2022-06-21
image: cover.png
author: john.carnell@genesys.comn
category: 6
---

Greetings everyone. It is June 2022, the year is half over and I hope everyone is enjoying the summer months. I know here in Raleigh, North Carolina it is a hot and humid and the heat will not stop until October. Today, I want to introduce you guys to the concept of Terraform modules and introduce you to how you can use them from within your own **CX as Code** projects to make your Terraform flows more modular and usable. In this blog post we are going to cover three major topic areas:

1. What is a Terraform module?
2. What is a Terraform remote module?
3. Introducing the Genesys Cloud DevOps Terraform Repository?

## What is a Terraform module

If you have done any work with **CX as Code** and Terraform you know that what might have started as a single `.tf` can quickly grow massive as you add resource definitions to your project. Many DevOps engineers will then start decomposing their Terraform resources into multiple files that contain related definitions. There is nothing wrong with this approach, but there might be times when you want parameterize and re-use module definitions within the same Terraform code base. For example, you might want to create multiple Genesys Cloud queues with slightly different values for each queue. You could define each queue individually (like in the code block below):

```
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

A better approach is to generalize and encapsulate your queue object into a Terraform module. A Terraform module allows you to wrap your resource definitions inside of function-like structure that accepts input parameters and publishes outputs. Modules allow you to better organize your resources and then re-use them throughout your project. Typically, I like to setup my modules within a folder and file structure right within my Terraform project.  While this is not required by Terraform I typically use the following structure for my **CX as Code** projects.

```
  main.tf                # The main Terraform definitions
  provider.tf            # Defines all of my providers used within my project 
  variables.tf           # Input variables for the project
  modules/
     queues/
       inputs.tf         # Input variables for the project   
       outputs.tf        # Output variables for the project
       main.tf           # The resource definitions
     module1/
     module2/
```

So lets take and write an example queue module `inputs.tf` file. This file defines all of the input values being passed into a module. It defines each of the input parameters we want to use to parameterize the module. The goal will the input values in the `inputs.tf` is to provide just enough information to customize the resource. Modules act as containers around the resources defined within them.  This means a module can not reference a value outside of the module unless it is explicitly passed in as an Terraform input parameter, nor can values produced by the module being accessed outside of the module without explicitly being passed outside the module via a Terraform output variable.

Here is a example implementation of an `inputs.tf` file.

```
variable "classifier_queue_names" {
  type        = list(string)
  description = "A list of queues names that you want to have generated."
}
```

This module is going to allow you to parameterize 1 variable: a list of queue names.


:::{"alert":"warning","title":"Don't get overzealous with module input parameters","autoCollapse":false}
Be careful not to make every parameter of a resource in your own module.  Modules are meant for you to re-use the general definition of your resources with a tweak here or there context specific values. I have seen developers take the concept of modules too far to the point where everything is parameterized and made a module.  For many Terraform projects, this can make things difficult to follow.
:::

The actual resource definition for the module is shown below (e.g. the main.tf):

```
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

In the example above, we iterate through each of the queue names passed into the module via the `for_each= toset(var.classifier_queue_names)` line. The value read from the list passed in as bound to a variable called `each`. The `each.value` variable is used to set the `name` attribute on the **CX as Code** queue resource and also build a `description` using the `each.value` to build a string for the description. The rest of the attributes for the queue resource are kept as the same values.

As mentioned earlier, all values generated from within a module are available only with the module unless they are explicitly mapped to an output attribute.  In our queue example there are often specific Genesys Cloud Architect flows and actions that can be associated with a queue.  In order to perform these type of mappings we need to make the queue ids of the created available out of the module. To do this, we can create a file called `output.tf` that will output a map of all of the created queue ids where the key for the map is the name of the queue. An example `output.tf` file is shown below:

```
output "queue_ids" {
  value = {
    for queue in genesyscloud_routing_queue.Queues:
    queue.name => queue.id
  }
```

This will bind a variable called queue_ids to the module. We will show you how to access the output parameter shortly.

At this point, you have all of the pieces defined for a module.  Now let's look at how you would include this module in one of your own Terraform projects. To use the module within your Terraform code, you can define use the `module` block within any of your Terraform files. I usually put my module configurations in the `main.tf` for the entire project.  Here is an example of how to configure our queue module we just defined:

```
module "classifier_queues" {
  source                   = "../modules/queues"                                 ## Fully qualified or relative path from the main.tf
  classifier_queue_names   = ["401K", "IRA", "529", "GeneralSupport"]
}
```

The above module definition will attempt to load the queues modules, associate the module with the names `classifie_queues` and pass in 4 queue names as input variables to the module: 401K, IRA, 529 and General Support. When you run `terraform init` for the first time, Terraform will check for the existence of the module. When a `terraform apply` is invoked, the above module will be called with each of the queues names passed in. Any output variables defined (e.g. the queue_ids) will be bound to the module name `classified queues`. Later on of my Terraform resource definitions I want to associate the 401K queue id created by this module, I could use `modules.classifier_queues.queue_ids["401K"]` to access to queue id for the created queue.

## Remote modules
## Using a CX as Code Remote Module within your own Terraform Flows



## Introducing the Genesys Cloud DevOps Repository


## Closing Thoughts
## Resources

1.  Terraform Module Page
2.  Genesys Cloud Repository 