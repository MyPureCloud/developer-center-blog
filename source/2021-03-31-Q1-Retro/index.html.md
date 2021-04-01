---
title: Q1 2021 - A Retrospective
tags: Genesys Cloud, Developer Engagement, SDK
date: 2021-04-01
author: john.carnell@genesys.com
---

Greetings everyone. I hope everyone is keeping safe and healthy in these challenging times. Wow! 2021 is flying by and the first quarter of the year is already in the bag. I wanted to take a moment and reflect on whats going on in the Developer Engagement team, what we have delivered this year and what you can plan to see over the course of the rest of the year.

# We are growing as a team

Our Senior leadership recognizes that one of the keys to a vibrant development platform is a vibrant development community. With the launch of the Developer Engagement team in Q2 of 2020, we have grown from a team of two engineers to a team of 5 full-time engineers and evangelists.  I would like to introduce our team and put some faces with the names you see on our forums:

|        |      |            |
|--------|------|------------|
|<img src="johncarnellgenesyscom.png" alt="John Carnell" width="100"/>|John Carnell| John has been with Genesys since 2015 and is currently the architect and team lead for the Genesys Cloud Developer Engagement team. John is a prolific speaker and writer. He regularly speaks at conferences and industry user groups. John's most recent book [Spring Microservices in Action](https://www.manning.com/books/spring-microservices-in-action-second-edition?utm_source=google&utm_medium=search&utm_campaign=dynamicsearch&gclid=Cj0KCQjwjPaCBhDkARIsAISZN7TThRZBnEPrb-FkhQwlFHEbExCIHI2lo70DvP28Rtr2lxf9AFkVvn8aAhmiEALw_wcB) is about to be released in its second edition. John is based out of our Raleigh, North Carolina office.
|<img src="timjsmithgenesyscom.png" alt="Tim Smith" width="100"/>     |Tim Smith   | Tim is a Senior Developer Evangelist and has been with Genesys since 2007. Tim's focus in the team is designing and developing customer-facing integrations and customizations. Tim is based out of our Denver, Colorado office.|
|<img src="ronanwatkinsgenesyscom.png" alt="Ronan Watkins" width="100"/>|Ronan Watkins|Ronan has been with Genesys since 2020 and is a software engineer within the Developer Engagement team. Ronan has worked extensively with our SDKs and is a core contribute to the Genesys Cloud Command Line Interface (CLI). Ronan is based out of our Galway, Ireland office.|
|<img src="weiteligenesyscom.png" alt="Weite Li" width="100"/>|Weite Li|Weite just graduated from college in summer 2020 and joined Genesys since then. He is working within Developer Engagement team. Weite is heavily involved with our Developer Center portal and supporting our Developer tools. Weite is based out of our Indianapolis office.|
|<img src="jacobshawgenesyscom.png" alt="Jacob Shaw" width="100"/>|Jacob Shaw|Jacob is the newest member of our team. He just recently joined the Developer Engagement team is based out of Atlanta, Georgia. Jacob has degree in computer systems engineering. Jacob will be help the team build out their content management tools.|

We are still looking at growing the team beyond our current capacity. We are adding another 2 positions later this year. In addition, the Developer Engagement team now includes dedicated testing resources and technical writers to help improve the quality of our code and our documentation. We are extremely excited about the opportunity to build out a team that can support our growing development community.

# More Content
Our focus this is year is on delivering more content to our developers across multiple delivery channels. Our goal with our content is to deliver new content with a regular cadence and with different levels of consumption. We want timely, relevant, and consumable content for all the developers who use our site.  We currently have 5 channels for delivering information about the Genesys Cloud development platform:

1. [__Developer Center__](https://developer.mypurecloud.com). Our developer center is the main portal for finding documentation around the Genesys Cloud APIs. It has a wide variety of topics dealing not only with the individual API calls, but also development guides on API integration, data integration, and Genesys Cloud development best practices. The developer center is the starting point for all developer content within Genesys Cloud.

2. [__Genesys Cloud Developer Blog__](/blogs). The blog contains articles on various Genesys Cloud development topics. It covers a wide range of topics, including new developer tool announcements, best practices for building your contact center within Genesys Cloud and hands-on articles on how to use the Genesys Cloud APIs.

3. [__DevDrops__](/video/devdrops/). Our DevDrop series is a new video series that we released this year. Its focus is on delivering short, consumable videos (10-20 minutes in length) that are meant to be "developer-to-developer" conversations.

4. [__DevCasts__](/video/devcasts/). Our DevCasts are our more traditional Webinar topics that are approximately 45-60 minutes in lengths and allow for audience participation. They cover a wide variety of development topics and are not just limited to discussions related to platform APIs.

5. [__Blueprints__](/blueprints). Blueprints are hands-on examples of how to integrate and extend Genesys Cloud functionality with other vendor products and technologies. Blueprints are meant to showcase the art of the possible.

With that overview here, is a summary of the content we delivered this quarter:

| Content Name | Type | Description|
|--------------|------|------------|
|[Understanding your Genesys Cloud API usage](/blog/2021-01-04-API-Usage/)| Blog |An in-depth discussion on how to use the Genesys Cloud Usage API to determine the behavior of your Genesys Cloud API calls over time. |
|[Designing Architect flow data actions for resiliency](/blog/2021-02-03-Caching-in-flows/)| Blog |Sam Johnson discusses how to use caching to build resiliency in your call flows.|
|[Introducing the Genesys Cloud CLI](/2021-02-11-Introducing-the-CLI/)|Blog|A brief, high-level introduction to the new Genesys Cloud CLI. Is a great starting point for find all the content associated with our new CLI.| 
|[Introduction to Web Messaging](/2021-02-20-Introduction-to-web-messaging/)|Blog|Chat is quickly becoming the premier mechanism for interacting with your customers. Chad Hansen, one of our Genesys Cloud product managers, introduces Genesys Cloud's new Web Messaging API.|
|[Adding features to the Genesys Cloud SDKs](/2021-02-20-Introduction-to-web-messaging/)|Blog|Ronan Watkins, an engineer from the Developer Engagement team, walks through how to extend and customize the Genesys Cloud platform SDKs.|
|[Collecting and using customer information with web chat widget version 2](/blog/2021-03-08-accessing-collected-chat-v2-information/)|Blog|Jerome Saint Marc, one of Senior Developer Evangelists, walks through how to collect custom attributes and customer information via WebChat.|
|[Introduction to the Genesys Cloud Command Line Interface](https://www.youtube.com/watch?v=OnYDs5NsLpU&t=1s)|DevDrop|John Carnell, the head of Developer Engagement, walks through the basics of using the new Genesys Cloud CLI.|
|[Using the CLI to move users to different queues](https://www.youtube.com/watch?v=VmrBhVc6n1U&t=1s)|DevDrop|John Carnell, the head of Developer Engagement, walks through how to use the CLI and Python to build a simple script to move a group of users from one queue to another.|
|[Adding features to the Genesys Cloud SDK](https://www.youtube.com/watch?v=NqaIykM7r30)|DevDrop|In this DevDrop, Ronan Watkins, in a follow up to his blog on extending Genesys Cloud SDKs, shows you how to add a new feature to the SDK.|
|[Genesys Dialog Engine](https://www.youtube.com/watch?v=mjMsy_a2WdE&t=6s)|DevCast|Jim Crespino, Director of Developer Evangelism, does an in-depth walkthrough of the Genesys Cloud Dialog Engine.|
|[The Genesys Cloud CLI: A Deep Dive](none.TODO.need.final.link)|DevCast|John Carnell, the head of Developer Engagement, does a detailed walkthrough of the Genesys Cloud CLI, its architecture, philosophy and capabilities.| 
|[Update a Genesys Cloud Do Not Contact list with the Genesys Cloud for Salesforce SDK](/blueprints/genesys-cloud-for-salesforce-sdk-dnclist-example/)|Blueprint|This blueprint demonstrates how add the primary phone number from Salesforce to a Genesys Cloud "Do not call blueprint."|
|Build a chat translation assistant with the AWS Translate service|Blueprint|__Coming Soon__. This new blueprint demonstrates how to build an embedded application within Genesys Cloud and use the AWS Translate service to provide "on-the fly" translation services to a conversation between a customer and a Genesys Cloud agent.|
|Embedding Applications with Genesys Cloud|Developer Starting Guide|__Coming Soon__. This starting guide will demonstrate how to embed a third party application within Genesys Cloud. It includes a detailed walkthrough of the code from the Chat/AWS Translate blueprint and demonstrates how to send messages to and from an agent's chat window.|


# More Tools
The engineers in the Developer Engagement team have beens heads down this quarter and have delivered several new capabilities. They are looking at delivering several new development tools and capabilities. These new capabilities include:

| | |
|-|-|
|[Genesys Cloud CLI](/api/rest/command-line-interface/)|The Genesys Cloud CLI lets you perform administrative, ad-hoc queries and bulk changes from the command-line. Written in Go, it allows you to install the CLI as a single-binary (no dependencies) easily within Windows, Linux and OS X |
|[CLI Recipes](https://github.com/MyPureCloud/quick-hits-cli)|A GitHub repository containing recipes for the Genesys Cloud CLI|
|Developer Center V2|__Coming soon__. We are within weeks of delivering a new Developer Center experience that will include improved search capabilities and user interactions. In addition, the new Developer Center will provide foundations for to deliver a more personalized developer services. |
|Logging capabilities|__Coming soon__. The SDK team has been building a more consistent logging experience across all of our SDKs so that developers can more easily (and consistently) log what is being executed in our SDKs. These new logging capabilities will make it easier for the Developer Engagement and support teams to provide more context on when errors are encountered while coding with our SDKs.

# What's coming next
This is only the beginning of the year! For the rest of the year, the Developer Engagement team has large number of projects in the works including:

1. __More content__. This one is a given. We are committed to continually building out new content. Right now in our content pipeline for this next quarter, we have new Developer Starting guides for integrating with the Genesys Cloud UI, building Resilient Cloud integrations, and understanding the Genesys Cloud Developer conversation model. 

2. __A refresh on our developer tools__. Starting in Q2 of this year, the Developer Engagement team is refreshing our developer tools like the API Explorer and Analytics Query builder. Our goal is to make these teams easily embedded and accessible throughout the site. In addition, we are exploring how we can allow users to be able save their API calls and queries so they do not have to re-enter them every time they come back to the site.

3. __More value-added capabilities to the Platform SDKs__. We really want developers to use our SDKs more. So during the course of the year we are looking at introducing new features within the SDKs that will make life simpler for developers, including: consistent rate-limiting retry-logic across all of our SDK platforms, adding the ability to auto-paginate API calls, and automatic re-authentication of expired OAuth2 tokens.

4. __More CLI capabilities__. The CLI was just released, but we are looking at how we can continue to thoughtfully expose our platform API in the CLI. We specifically want to focus on how we can more fully expose our Analytics and Edge APIs in the CLI.

4. __A more personalized experience in the Developer Center__. This one is really important to me. We want to allow developers to personalize the Developer Center to meet their individual needs. We are currently exploring how we can let developers subscribe to individual page notifications so they can be notified of the APIs that are important to them. We are also looking at building out a "favorites" capability so that the APIs you work with the most are available right at the beginning of the site rather then buried below multiple pages.

We are off to a busy year, but we are excited with the support and feedback we have been getting from the Genesys Cloud developer community. It's going to be an exciting year. Let's build something great together.
