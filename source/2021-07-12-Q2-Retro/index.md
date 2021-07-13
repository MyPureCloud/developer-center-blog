---
title: Q2 2021 - A Retrospective
tags: Genesys Cloud, Developer Engagement, SDK
date: 2021-07-12
author: john.carnell
category: 0
---

Greetings everyone. I hope everyone is keeping safe and healthy in these challenging times. We are officially halfway through the year. 2021 is flying by and the second quarter of the year is in the books. The Developer Engagement team and the rest of Genesys Cloud has been busy this year. New features, new development tools and lots of new content. I wanted to take a moment and share with you a quick summary of everything the team has been working on this quarter.

# New faces on the team 

Our senior leadership recognizes that one of the keys to a vibrant development platform is to have the right people in place to support the needs of a rapidly growing and ever changing development community. As our developer community grows, we are growing. I am pleased to announce two new engineers have joined the developer engagement team, bringing our total engineering staff up to 7 engineers. The new engineers joining the Development Engagement team are:

| | | |
|-|-|-|
|<img src="ebenezeroseigenesyscom.png" alt="Jacob Shaw" width="100"/>|Ebenezer Osei|Ebenzer is an international student from Ghana. Ebenezer graduated from Truman State University in spring, 2021 with a Computer Science major. His favorite technologies so far are Flutter for mobile development and React for frontend.|
|<img src="charlieconneelygenesyscom.png" alt="Jacob Shaw" width="100"/>|Charlie Conneely|Charlie is from County Cavan in Ireland and recently graduated from the Galway-Mayo Institute of Technology with a degree in Software Development.|

# More Content, More Channels of Information
Our goal is to deliver timely, relevant, and consumable content for all the developers who use our site. We currently have 5 channels for delivering information about the Genesys Cloud development platform:

1. [__Developer Center__](https://developer.genesys.cloud). Our developer center is the main portal for finding documentation around the Genesys Cloud APIs and development tools. It has a wide variety of topics dealing not only with the individual API calls, but also development guides on API integration, data integration, and Genesys Cloud development best practices. The developer center is the starting point for all developer content within Genesys Cloud. 

2. [__Genesys Cloud Developer Blog__](/blog/). The blog contains articles on various Genesys Cloud development topics. It covers a wide range of topics, including new developer tool announcements, best practices for building your contact center within Genesys Cloud and hands-on articles on how to use the Genesys Cloud APIs.

3. [__DevDrops__](/video/devdrops/). Our DevDrop series is a new video series that we released this year. Its focus is on delivering short, consumable videos (10-20 minutes in length) that are meant to be "developer-to-developer" conversations around specific developer-related topics.

4. [__DevCasts__](/video/devcasts/). Our DevCasts are our more traditional Webinar topics that are approximately 45-60 minutes in lengths and allow for audience participation. They cover a wide variety of development topics and are not just limited to discussions related to platform APIs.

5. [__Blueprints__](/blueprints/). Blueprints are hands-on examples of how to integrate and extend Genesys Cloud functionality with other vendor products and technologies. The number of blueprints we have continue to grow in size and come from not only our development engagement team, but also our developers, solution consultants and partners.

Here is a summary of the content we delivered or are close to delivering this quarter:

| Content Name | Type | Description|
|--------------|------|------------|
|[Introducing CX as Code](/blog/2021-04-16-cx-as-code/)| Blog |CX as Code is a configuration management tool that allows you to define Genesys Cloud configuration objects (e.g. Queues, Skills, Users, etc) in plain old text files and then apply that configuration across multiple Genesys Cloud organizations|
|[Introducing AWS Chat Translation](/blog/2021-05-03-aws-chat-translation/)| Blog |This blog post introduces the new UI integration starting guide we have produced.  In this guide we will show you have to build an embedded application to translate user and agent messages on the fly using AWS Translate.|
|[Genesys Cloud SDK Configuration and Logging](/blog/2021-05-06-sdk-config-and-logging/)| Blog |In early May, we released new logging capabilities with the Genesys Cloud SDK. This article covers some of the new features and how to configure them.|
|[Using PowerShell with the Genesys Cloud CLI](/blog/2021-06-01-cli-with-powershell/)| Blog |Prince Merzula, one of our Developer Evangelists, demonstrates how to use Windows, PowerShell and the Genesys Cloud CLI to automate common Genesys Cloud administrative tasks.|
|[New Fully Generated CLI Released](/blog/2021-06-04-new-cli-release/)| Blog |This article announce the release of our Genesys Cloud CLI with support for our entire API.|
|[New Flow Outcome Milestones Released](/blog/2021-06-10-flow-outcome-milestones/)| Blog |Tom Hynes, a lead engineer in the Architect team introduce these new Flow outcome milestone feature.  With the release of this new feature, you will be able to track where in flow a user has reached. This allows for more fine-grained reporting on flow activity. |
|[Building Resiliency into your Cloud Integration Patterns](/blog/2021-06-15-Resiliency-Patterns/)| Blog |John Carnell, platform architect and team lead for Developer Engagement, talks about how you can design and implement resiliency into your cloud-based integrations. |
|[Xperience 21 Welcome to Truly Differentiating Your CX](/blog/2021-06-24-xpr21-welcome/)| Blog |Jack Nichols, VP of product management, welcomes you to Xperience 21 and provides an overview of the Genesys Cloud development resources tools available building a differentiated customer experience.  |
|[Introduction to Analytics API Detail Record Metrics](/blog/2021-05-10-introduction-to-analytics-api/)| Blog |Jen Barrera, an associate Developer Evangelist, walks through the Analytics Details API and how to use to the Analytics Query Builder tool to query this API.  |
|[A preview of CX As Code](https://youtu.be/ol_8HYSGmGg)|DevDrop|John Carnell, the manager of the Genesys Cloud Developer Engagement team, gives a preview of the new Genesys Cloud CX as Code tool.| 
|[Rate-limiting and the Genesys Cloud Platform API](https://youtu.be/_Ugol0NZMbk)|DevDrop|In this video, we cover the topic of rate-limiting and walk through how to deal with rate-limiting when calling the Genesys Cloud platform API.| 
|[Using the Genesys Cloud Java SDK’s retry logic for rate-limits](https://youtu.be/QfwXZOOUWi0)|DevDrop|In this video, we cover how the Genesys Cloud Java SDK's built-in retry functionality.| 
|[Using caching to mitigate rate limiting](https://youtu.be/QfwXZOOUWi0)|DevDrop|In this video we cover how to use Spring Boot, the open-source Caffeine cache project, and Genesys Cloud to mitigate rate-limiting by reducing the number of Genesys Cloud APIs needed to be made on a particular call.| 
|[The developer tools strike back](https://youtu.be/0E2h6sgd6rM)|DevDrop|In this DevDrop, we will walk through each of our development tools (APIs, SDKs, Genesys Cloud CLI, CX as Code, and Archy) and discuss what capabilities the tools provide and when you should consider using one tool over another.| 
|[Installing and Configuring Archy](https://youtu.be/fOI_vq3PnM8)|DevDrop|Archy is the Genesys Cloud command-line tool for exporting and importing Genesys Cloud Architect flows in a human-readable format (e.g. YAML). Archy was built as a means to promote architect flows between multiple Genesys Cloud environments. (e.g. dev, test, prod, etc...). In this video, we will show you how to install and configure Archy.| 
|[Exporting Architect Flows with Archy](https://youtu.be/QAmkM_agsrY)|DevDrop|In this DevDrop, we will show you how to export an Architect flow using Archy.|
|[Importing an Architect Flow using Archy](https://youtu.be/3NwGJ9X1O0s)|DevDrop|In this DevDrop, we will show you how to take a Genesys Cloud flow that has been exported as YAML and import it into an organization.|
|[Predictive Engagement Journey Tracking in Web Messaging using the pageview command](https://youtu.be/247DJ0r8kdE)|DevDrop|In this DevDrop, Michal Krzywonos a software engineer on the Predictive Engagement team will introduce you to the Predictive Engagement web messaging journey plug-in.|
|[Predictive Engagement Journey Tracking in Web Messaging using the record command](https://youtu.be/c58p2C0wVZE)|DevDrop|This DevDrop will cover the Journey plugin's record command and demonstrate how to change the default behavior of the plugin, along with capturing custom journey data|
|[Predictive Engagement for Developers](https://youtu.be/qu0nKhzKaVY)|DevCast|Genesys Predictive Engagement allows you to capture and analyze each of your customer’s journeys on your website and beyond. We’ll dig into the predictive engagement SDK and API’s that you can use to fully understand the customer journey and use it to deliver great experiences.|
|[Building Resilient Apps in Genesys Cloud](https://youtu.be/0Y37xlfZLtg)|DevCast|John Carnell, platform architect and team lead for the Genesys Cloud developer engagement team, is going to walkthrough 5 resiliency patterns you can use in your Genesys Cloud integrations to make your integrations stable and resilient.|
|[Introduction to the Genesys Cloud Open Messaging API](https://youtu.be/dBEhmO1AaS0)|DevCast|  the Genesys Cloud Open Messaging API	Open messaging is a lightweight, webhook-based integration that facilitates messaging with 3rd party systems and external messaging services. With open messaging you can leverage Genesys Cloud's asynchronous ACD capabilities to route inbound open messages to the right queues and agents.|
|[Build a chat translation assistant with the AWS Translate service](/blueprints/chat-translator-blueprint/)|Blueprint|This Genesys Developer Cloud Blueprint provides instructions for building a chat translation assistant which uses the AWS Translate service to allow customers and agents to chat in their preferred languages. The chat translation assistant automatically translates everything in the chat window in real-time, including canned responses.|
|[Design a SQL database for storing analytics JSON data](/blueprints/conversation-model-to-sql-blueprint/)|Blueprint|This Genesys Cloud Developer Blueprint provides an example of how to design a SQL database for storing JSON data, specifically data from the POST /api/v2/analytics/conversations/details/query.|
|[Query your API usage using Genesys Cloud CLI and analyze it with AWS S3/Athena](/blueprints/usage-api-blueprint/)|Blueprint|This Genesys Cloud Developer Blueprint demonstrates how to query your organization's API usage, using the Genesys Cloud CLI. Analyzing your usage is essential in optimizing and scaling any solution that uses the API. This blueprint also demonstrates an example integration by exporting the information to an AWS S3 bucket and using AWS Athena to process queries against it.|
|[UI Integration Starting Guide](/guides/ui-integration/)|Starting Guide|This Genesys Cloud Developer Starting Guide helps you implement a UI integration that uses the AWS Translate service to translate chats to the recipient's preferred language in real time.|
<br/>

In addition to the content completed this quarter, here is some of the new content already being worked on for Q3 of this year.
| Content Name | Type | Description|
|--------------|------|------------|
|Integrating the Genesys Javascript SDK with React|Blueprint|__Coming soon__. Jacob Shaw, one of our Developer Engagement engineers, will demonstrate how to setup and build a React-based application using our Genesys Cloud SDK. |
|Integrating the Genesys Javascript SDK with Angular|Blueprint|__Coming soon__. Prince Merzula, a Genesys Cloud Developer Evangelist, will show ow how to configure and use the Angular framework to deliver a Single Page Application (SPA).|
|Integrating your digital bot with bot connector|Blueprint|__Coming soon__. Marc Sassoon, a Genesys Cloud Senior Cloud Solution Architect, will introduce the Genesys bot connector.|
|Leveraging AWS Comprehend to classify and route inbound email flows|Blueprint|__Coming soon__. John Carnell, Genesys Cloud platform architect, will demonstrate how to use AWS Comprehend to classify incoming emails and route them to a different queues based on the content.|
|Consuming Genesys Cloud Event Streams with AWS Event Bridge|Blueprint|__Coming soon__. Ronan Watkins, one of our Developer Engagement engineers, will show how to use AWS Event Bridge to carry event stream data from Genesys Cloud over to your own integrations.|


# More Tools
The engineers in the Developer Engagement team have been heads down this quarter and have delivered several new capabilities. These new capabilities include:

| | | |
|-|-|-|
|[Genesys Cloud CLI](/api/rest/command-line-interface/)|A new version of the CLI has been released that fully supports the entire Genesys Cloud API.  Every-time a new API is released it will automatically be part of the CLI.|
|[CX as Code](/api/rest/CX-as-Code/)|A new DevOps tool based on Terraform.  **CX as Code** allows you to define core Genesys Cloud configuration like Queues, Integrations and Data Actions (to name just a few) in human-readable text files and deploy these objects as part of your CI/CD pipeline. |
|[Developer Center V2](https://developer.genesys.cloud/)|The Developer Center has a new look and feel, better performance and a new domain name. Check us out. |
|[SDK Logging Configuration](/api/rest/client-libraries/logging)|Our Java, .NET, Python, Golang, Node and Javascript SDKs now have a unified set of logging capabilities.|
|[New PowerShell CLI Recipes](https://github.com/MyPureCloud/quick-hits-cli)|Checkout the quick hits repository. Many of the script examples now include PowerShell examples for our Windows admins.|

The first half of the year has come and gone, but the team is plowing ahead with new tools and new capabilities.  Let's build something great together.
