---
title: Q3 2021 - A Retrospective
tags: Genesys Cloud, Developer Engagement, SDK
date: 2021-10-11
author: john.carnell
category: 0
---

Greetings everyone. I hope everyone is keeping safe and healthy in these challenging times. We are officially three-fourths of the way through the year. 2021 is flying by and the third quarter of the year is now behind us. The Developer Engagement team and the rest of Genesys Cloud has been busy this year. New features, new development tools and lots of new content. I wanted to take a moment and share with you a quick summary of everything the team has been working on in the third quarter of 2021.

## More Content, More Channels of Information
Our goal is to deliver timely, relevant, and consumable content for all the developers who use our site. We currently have 5 channels for delivering information about the Genesys Cloud development platform:

1. [__Developer Center__](https://developer.genesys.cloud). Our developer center is the main portal for finding documentation around the Genesys Cloud APIs and development tools. It has a wide variety of topics dealing not only with the individual API calls, but also development guides on API integration, data integration, and Genesys Cloud development best practices. The developer center is the starting point for all developer content within Genesys Cloud. 

2. [__Genesys Cloud Developer Blog__](/blog/). The blog contains articles on various Genesys Cloud development topics. It covers a wide range of topics, including new developer tool announcements, best practices for building your contact center within Genesys Cloud and hands-on articles on how to use the Genesys Cloud APIs.

3. [__DevDrops__](/video/devdrops/). Our DevDrop series is a new video series that we released this year. Its focus is on delivering short, consumable videos (10-20 minutes in length) that are meant to be "developer-to-developer" conversations around specific developer-related topics. We are experimenting with our video formats and looking at how we can break down larger topics into smaller videos. 

4. [__DevCasts__](/video/devcasts/). Our DevCasts are our more traditional Webinar topics that are approximately 45-60 minutes in lengths and allow for audience participation. They cover a wide variety of development topics and are not just limited to discussions related to platform APIs.

5. [__Blueprints__](/blueprints/). Blueprints are hands-on examples of how to integrate and extend Genesys Cloud functionality with other vendor products and technologies. The number of blueprints we have continues to grow in size and come from not only our development engagement team, but also our developers, solution consultants and partners.

Here is a summary of the content we delivered or are close to delivering this quarter:

| Content Name | Type | Description|
|--------------|------|------------|
|[New Experimental CLI Feature: Alternative Formats](2021-08-31-new-experimental-cli-feature-alternative-formats/)| Blog |We are constantly working to improve and try new things in our blog. This blog post introduces how to use YAML support for input and output to the Genesys Cloud CLI. We have introduced this feature as experimental but expect to introduce this fully into the CLI in the 4th quarter.|
|[Transferring calls to an external device with BYOC Cloud trunk](/blog/2021-09-03-transferring-calls-to-external-using-byoc/)| Blog |This blog post demonstrates how to configure a BYOC trunk within Genesys Cloud.|
|[Introducing the New Archy Export Feature](/blog/2021-09-15-archy-export-feature/)| Blog |Archy is the Genesys Cloud CLI tool for importing and exporting Architect flows from one Genesys Cloud organization to another. In this article, Prince Merzula demonstrates how to export an Architect flow into a YAML format.|
|[New Experimental CLI Feature: Transform Data](/blog/2021-10-01-experimental-feature-transform-data/)| Blog |This is one of the new features I am most excited about. With this feature, you know have the ability define [Golang templates](https://pkg.go.dev/text/template) to transform data coming out of the Genesys Cloud CLI. We also incorporate the [Sprig](https://github.com/Masterminds/sprig) library into the templates to leverage a large set of pre-defined functions in your transformation templates. This allows you to more easily parse, transform and then redirect Genesys Cloud data returned by the CLI into proprietary formats.|
|[How to begin your CX as Code Journey](blog/2021-10-10-treating-contact-center-infrastructure-as-code/)| Blog |CX a Code is our new tool for promoting Genesys Cloud configuration from one organization to another via a Continuous Integration/Continuous Deployment (CI/CD) pipeline. This blog post helps provides guidance on when your organization should look to leverage CX as Code and some best practices for getting started.|
|[New Account Switcher for Developer Tools](/blog/2021-10-12-new-account-switcher-in-devtools/)| Blog | This article introduces how to setup multiple Genesys Cloud organizations and then easily switch between them using the new account switcher functionality introduced in the online developer tools.|
|[Python SDK Notification Service](https://www.youtube.com/watch?v=z6JS12DX_pI)|DevDrop|Michael Roddy, an engineer in the Developer Engagement team, demonstrates how to use the Genesys Cloud Python SDK to connect to the Genesys Cloud notification service and listen to real-time events coming from Genesys Cloud.| 
|[Connecting to the Notification Service using the Genesys Cloud CLI](https://www.youtube.com/watch?v=r4Jc-Mn0ONA)|DevDrop|Have you ever had the need to quickly inspect and capture the real-time event stream originating from Genesys Cloud? Charlie Conneely, an engineer from the Developer Engagement team, walks through how to configure the Genesys Cloud CLI to listen to these events.| 
|[Introducing the Developer Tools Account Switcher](https://www.youtube.com/watch?v=F0sIpIfoa0k)|DevDrop|In this video, Ebenezer Osei an engineer from the Developer Engagement team demonstrates how to use the development tools account switcher to easily login and switch between multiple Genesys Cloud organizations.|
|[Introduction to the Genesys Cloud Open Messaging API](https://www.youtube.com/watch?v=dBEhmO1AaS0 )|DevCast|Open messaging is a lightweight, webhook-based integration that facilitates messaging with 3rd party systems and external messaging services. With open messaging you can leverage Genesys Cloud's asynchronous ACD capabilities to route inbound open messages to the right queues and agents. Asynchronous messaging allows conversations to remain active so that customers can continue conversations at their preferred pace. Additionally, you can use Inbound Message flows in Architect to route inbound open messages to integrations, bots, and queues based on message content.|
|[Managing your Customer Experience as Code: Introducing CX as Code](https://www.youtube.com/watch?v=21p6hDFipKY)|DevCast|In this presentation, John Carnell, will show you how to take an entire Genesys Cloud architect flow along with all of its dependent objects and use CX as Code, Archy (our Genesys Cloud architect flow import/export tool), and Terraform (the DevOps tools CX as Code is built on) to deploy with one command an entire call center application. John will share some of his learnings from using CX as Code with Terraform, provide guidance on when (and whether) you should consider using CX as Code within your own organization and then review whats coming next with the CX as Code toolset.|
|[Develop an Angular app that uses the Genesys Cloud Platform SDK](/blueprints/angular-app-with-genesys-cloud-sdk/)|Blueprint|This Genesys Cloud Developer Blueprint demonstrates how to to include the Genesys Cloud Javascript Platform SDK in an Angular project. The blueprint includes a sample Angular project that uses the Genesys Cloud API for supervisor functionalities like searching and setting the status of users. The blueprint also shows how to configure the SDK for a new or existing Angular project.|
|[Deployment Guide for Chat Assistant on Genesys Cloud](/blueprints/chat-assistant-blueprint/)|Blueprint|This Genesys Blueprint provides instructions for deploying a chat assistant on Genesys Cloud. The Chat Assistant actively listens to the chat interaction and suggest responses based on keywords. Sending messages and the typing indicator features of the Chat API will be convenient in this scenario.|
|[Classify and route emails with Amazon Comprehend](/blueprints/email-aws-comprehend-blueprint/)|Blueprint|This Genesys Cloud developer Blueprint explains how to use Amazon Comprehend's Natural Language Processing (NLP) to classify inbound emails so they can be routed to a specific queue. It also shows how to setup all of the Genesys Cloud components using CX as Code and Archy|
|[Integrating your digital bot with bot connector](blueprints/bot-connector-for-ms-power-virtual-agent)|Blueprint|This Genesys Cloud Developer Blueprint explains how to deploy a Microsoft Power Virtual Agent (VA) bot to answer your customer queries through web messaging and Messenger. The blueprint also provides the solution for using a third-party bot that Genesys Cloud does not support as a strategic vendor. The solution uses the Genesys Bot Connector that provides the API and acts as the link between Genesys Cloud and the bot.|
|[Create a PagerDuty incident in response to OAuth Client deletes via AWS EventBridge](/blueprints/aws-eventbridge-oauth-client-delete-blueprint)|Blueprint|This Genesys Cloud Developer Blueprint provides an example of a Lambda function that creates a PagerDuty incident in response to OAuth client deletes. The Lambda is triggered by a Genesys Cloud event transported over an AWS EventBridge integration|
|[Write User Presence Updates to Dynamo via AWS EventBridge](/blueprints/aws-eventbridge-user-presence-update-blueprint)|Blueprint|This Genesys Cloud Developer Blueprint provides an example of how to write a Lambda function that responds to user presence updates sent via AWS EventBridge and writes them to a DynamoDB table.|
<br/>

In addition to the content completed this quarter, here is some of the new content already being worked on for Q4 of this year.

| Content Name | Type | Description|
|--------------|------|------------|
|Integrating CX as Code into a CICD Pipeline|Blueprint|__Coming soon__. John Carnell, manager of the Developer Engagement engineers, will demonstrate how to use GitHub Actions, Terraform Cloud, CX as Code and Archy to build a multi-environment CICD pipeline.|
|Integrating the Genesys Javascript SDK with React|Blueprint|__Coming soon__. Jacob Shaw, one of our Developer Engagement engineers, will demonstrate how to setup and build a React-based application using our Genesys Cloud SDK.|

## More Tools
The engineers in the Developer Engagement team have been heads down this quarter and have delivered several new capabilities. These new capabilities include:

| | | |
|-|-|-|
|[Genesys Cloud CLI](/api/rest/command-line-interface/)|Several new features have been added to the CLI as experimental features. These new features include the ability input and output data in a YAML format. We have also included a new transform command that will let you pass the output of a CLI command to a GO template and transform the output.|
|[CX as Code](/api/rest/CX-as-Code/)|We continue to build out the resources and data sources within our CX as Code DevOps tool. For a complete list of the published resources take a look at the [resource documentation](https://registry.terraform.io/providers/MyPureCloud/genesyscloud/latest/docs)|
|[Account Switcher](/guides/quickstarts/developer-tools-intro)|The developer tools now allow you to setup multiple Genesys Cloud accounts within the developer tools and switch between those accounts without having to log out.|
<br/>

##Whats Coming Up?

The Developer Engagement team is in full swing for this next quarter. Some of the things coming up for this next quarter include:

1. **New CX as Code integrations with Archy**. It's almost here. Our goal is to have Archy be able to be integrated into Terraform without the need to install and configure the Archy CLI to deploy flows. This new integration will significantly simplify the setup work needed to be done in your CI/CD piplein.e

2. **More CLI capabilities**. We are finalizing two new experimental features in the CLI. The first feature is the ability to process multiple files for a create or update command. Currently, the CLI can only process one file at a time and if you want to feed in multiple files for a create or update command you need to do some file listing and parsing magic using Unix or Powershell tools. This new command will let you process all of the files in a directory and apply the CLI command using each file. The second capability is to allow a administrator to not only login into the CLI with a OAuth 2 client credential grant, but also an implicit OAuth client credential. This will allow Genesys Cloud the ability to log "who" did what with the CLI rather then just a generic OAuth token. 

3. **A new API Explorer**. The Developer Engagement team is in the final stages of releasing a new version of its API explorer. I just had a demonstration of it and I thought it was amazing and I think our development community will love it. Some of the new features include a redesigned wizard front end entering API data, stronger type checking and the ability to embed the API explorer directly in our technical documentation. Expect the beta to start soon and we would love feedback.

The Developer Engagement team has been roaring through this year and I am excited and proud to see the content and capabilities being produced by this team. I am also ecstatic with the developer community we continue to build out. Many of the features and content we build come directly from our day-to-day interactions with you. Please keep the feedback coming,use the [developer forum](https://developer.genesys.cloud/forum/), and let's build something together.
