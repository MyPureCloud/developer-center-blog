---
title: A quick update on CX as Code
tags: Genesys Cloud, Developer Engagement, SDK
date: 2022-03-23
author: john.carnell
category: 0
---

Greetings everyone. It is a beautiful spring day here in Durham, North Carolina. I hope everyone is well and your new year has been kicked off with a bang. The Developer Engagement team has been hard at work on a number of new **CX as Code** features and content. I wanted to spend a few moments on what has been delivered so far this year and what we currently have in the pipeline.

## New CX as Code Features

In the last several months we have delivered several new pieces of functionality in the **CX as Code** Terraform provider. Use the latest [CX as Code](https://registry.terraform.io/providers/MyPureCloud/genesyscloud/latest/docs) provider to get access to this new functionality. This new functionality includes:

| Feature      |Description |
|--------------|------------|
|**CX as Code** export as HCL| The initial release of the **CX as Code** provider only supported the exporting of Genesys Cloud objects in a JSON format. This works, but the reality is that almost all of the Terraform documentation is in an HCL (Hashicorp Markup Language) format. With the new `export_as_hcl` attribute on the `genesyscloud_tf_export` resource, you can now have Genesys Cloud objects exported as HCL. If the `export_as_hcl` attribute is not explicitly set to a value of `true` the export provider will continue with its default behavior and export Genesys Cloud objects in JSON. More information about this feature can be found [here](https://registry.terraform.io/providers/MyPureCloud/genesyscloud/latest/docs/resources/tf_export). |
|**CX as Code** export variable substitution| There are certain values that Genesys Cloud will never export. These values include credentials used in the Genesys Cloud integration/data actions modules. To help facilitate the exporting of Genesys Cloud objects we now automatically inject a Terraform variable into the exported file for these sensitive resource. We also generate a `tf.auto.vars` file containing the variable name and empty value for the exported variable. This way you can easily manage sensitive variables in one place through a `tf.auto.vars` file or other mechanisms like a secrets vault.|
|**CX as Code** remote modules| **CX as Code** provides DevOps primitives for building and managing Genesys Cloud objects. However, some of the **CX as Code** resources can have sophisticated configuration associated with them. By leveraging Terraform's remote modules capability, Genesys Cloud is building a repository of pre-defined **CX as Code** configurations that you can invoke directly from your Terraform projects. For more information on Terraform remote modules go [here](https://www.terraform.io/language/modules/sources). To see the available remote modules in the Genesys Cloud **CX as Code** repository, go [here](https://github.com/GenesysCloudDevOps).|
|Architect Flow Resource| Previously, if you wanted to deploy an Archy flow in your CI/CD pipelines you needed to use the Archy CLI. However, we now have a **CX as Code** Flow resource that will allow you to deploy An architect flow without the need to have the CLI installed. This resource is currently in a closed beta, but if you are interested in joining the beta, please contact the **CX as Code** product manager, Becky Powell, at becky.powell@genesys.com. For documentation on this new **CX as Code** resource, please take a look [here](https://registry.terraform.io/providers/MyPureCloud/genesyscloud/latest/docs/resources/flow).|
|Web Messaging Resource|Web Messaging enables an organization to deploy a Genesys Cloud messaging widget that allows an organization's customers to chat either with an automated bot running in or an agent logged into Genesys Cloud. new The Web Messaging **CX as Code** resource allows you manage the configuration of these messaging resources. Documentation for the Web Messaging resource can be found [here](https://registry.terraform.io/providers/MyPureCloud/genesyscloud/latest/docs/resources/webdeployments_deployment).|
|Web Chat Resource|Web Chat is Genesys Cloud's legacy chat tooling. With this **CX as Code** resource, you will be able to manage the configuration needed to support the web chat widget. **NOTE: Web Messaging and not Web Chat is the stated direction by Genesys Cloud for building out a chat solution. This resource was provided for compatibility with existing Web Chat deployments. If you are building a new messaging solution, you should use Web Messaging.** Documentation for the Web Chat resource be found [here](https://registry.terraform.io/providers/MyPureCloud/genesyscloud/latest/docs/resources/widget_deployment).|

## New Content

The Developer Engagement team has been hard at work building out new **CX as Code** content. The new **CX as Code** content delivered this quarter includes:

| Title        |Type|Description |
|--------------|----|------------|
|[CX as Code in Action: Building Contact Centers via CI/CD Pipelines](https://youtu.be/cFNI-lOHaBI)|DevCast|A 45 minute Web that demonstrates how to leverage Github Actions, Terraform Cloud and **CX as Code** to deliver a CI/CD pipeline that can deploy an a Genesys Cloud architect flow and its downstream dependencies. The blueprint for this presentation can be found [here](https://github.com/GenesysCloudBlueprints/cx-as-code-cicd-gitactions-blueprint).|
|[Build a web messaging chat bot calling an AWS Lambda via a Genesys Cloud Data Action](https://github.com/GenesysCloudBlueprints/deploy-webmessaging-chatbot-with-lambda-blueprint)|Blueprint|This Genesys Cloud blueprint demonstrates how to build a Web Messaging-based chatbot using Genesys Cloud's Web Messaging capabilities and integrating that chatbot with an AWS lambda. **NOTE: This blueprint is still in draft format because it is still in content review. The code examples work, but the blueprint is still being edited.**|
|[Build a webchat chat bot calling an AWS Lambda via a Genesys Cloud Data Action](https://github.com/GenesysCloudBlueprints/deploy-webchat-chatbot-with-lambda-blueprint)|Blueprint|This Genesys Cloud Developer blueprint demonstrates how to build a chatbot using Genesys Cloud's Web Chat capabilities and integrating that chatbot with an AWS lambda. **NOTE: This blueprint is still in draft format because it is still in content review. The code examples work, but the blueprint is still being edited.**|

## Closing Thoughts 

The Genesys Cloud Developer Engagement team is continuing to build and expand **CX as Code** capabilities. Watch the Developer forum and blog for more information on **CX as Code**. In the coming months, we will continue to:

1. **Build out additional CX as Code resources**. The Genesys Cloud development teams are going to continue adding new Genesys Cloud resources. Regularly checkin on the [Terraform registry](https://registry.terraform.io/providers/MyPureCloud/genesyscloud/latest) for new resources that are released.
Genesys Cloud is continuing to invest in building out the **CX as Code** toolset. If you have ideas for additional CX as Code resources or capabilities please consider submitting a request to our [Ideas Portal](https://genesyscloud.ideas.aha.io/).

2. **Focus on expanding CX as Code use cases**. The Developer Engagement team has gotten a lot of questions from the developer community about whether we can use **CX as Code** to back up and restore one org into another org or use **CX as Code** to snapshot an environment and promote those changes to another environment. Our initial focus has been on leveraging **CX as Code** as a tool for CI/CD pipelines, but our development and testing teams are experimenting with these alternative use cases and ensuring that the individual Genesys Cloud resources in **CX as Code** will function properly in these new use cases.

3. **Focus on building a community-based repository of CX as Code/Terraform remote modules**. **CX as Code** was designed to be an open platform. As we build out our own **CX as Code** modules and example stacks of CX functionality, we want to use Terraform remote modules to build a community-based repository of modules to enable developers to jumpstart their own CX initiatives. Keep an eye on the Genesys Cloud [Devops GitHub repository](https://github.com/GenesysCloudDevOps) for new **CX as Code** modules. More remote modules will be coming shortly.

