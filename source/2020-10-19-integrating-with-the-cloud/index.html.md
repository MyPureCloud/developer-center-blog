---
title: Integrating with the Cloud
tags: Genesys Cloud, Developer Engagement
date: 2020-10-19
author: john.carnell@genesys.com
---

# Introduction

Integration.  It's not the most fun part of software development, but it is one of the more critical things you need to think about as you are looking at purchasing a cloud-based product.  Cloud products are great in the sense that you don't have to manage the infrastructure yourself, you get new features quickly and you are able to convert a fixed capital cost over to a variable expense (for the MBAs's in the audience).  However, the success or failure of your cloud acquisition is going to be tied to how successful you are in integrating your new cloud platform into your overall business processes/workflows and the IT ecosystem of your organization.  You need to understand that there are different styles of integrations and every cloud provider will give you different technologies to implement these categories. 

This article is going to walk through what different styles are available for cloud integration and talk specifically about which Genesys Cloud technologies are available for each integration style.  

:::Some thoughts on integration styles
The integration styles defined in this article are meant to be a very broad-based definition of integration types.  I have not many any direct attempt to tie these broad styles into the more traditional enterprise integration patterns found in Gregor Hohope and Bobby Wolfe's seminal book on integration: [Enterprise Integration Patterns](https://www.amazon.com/o/asin/0321200683/ref=nosim/enterpriseint-20).  The patterns defined in this book are still very relevant, but tend to be more fine-grained and focused on integration patterns of systems within the four-walls of an organization.  If you are interested in finding out more about these patterns, I also recommend visiting the [companion web-site](https://www.enterpriseintegrationpatterns.com/) for the book.  
:::

There are three broad styles of integration.  These three styles are defined by what you are trying to accomplish:

1. **Behavioral**.  I want Genesys Cloud to do something on behalf of my user or process.  For example, when the user clicks on a button in my home-grown CRM, I am going to call a Genesys Cloud API to save some data and carry out a set of business logic.

2. **Data**.  I want to move data in and out of Genesys Cloud.  Examples of this include: I need to pull all of the days conversations out of Genesys Cloud for my contact center and synchronize that data with my local data warehouse or I am building a near-time alerting dashboard for shift supervisor.

3. **Presentation**. I want to embed my application within Genesys Cloud or I want part of Genesys Cloud to be embedded within my application.  I want to integrate call-controls into my home-grown CRM so agents can take and receive calls right within the CRM.

Let's walkthrough these styles in more detail.

## Behavioral Integration Style

The behavioral integration style is when you need to integrate programmatically with your cloud provider so that the provider will execute some action on your behalf.  These actions are characterized as:

1. **Focusing on having the cloud provider do something for you**.  With a behavior integration style, you are usually asking a cloud provider to take some action on behalf of an individual user or a process.  For example, you might want to call a cloud-provider to save a piece of data and apply business rules along with it or doing a look up of a customer record.

2. **Being short lived in nature**.  Behavioral integrations are application-oriented and tend to favor single calls out to an API that return very quickly from a call.

3. **Are transactionally focused, rather then data synchronization focused**.  One thing that many people find confusing is that APIs can be used for transactional actions as well as for data synchronization.  Behavioral integrations styles are not data synchronization focused.

Genesys Cloud Offers three different mechanisms for carrying out behavioral integration styles.  They include:

1. REST-based APIs
2. Data Actions

### REST-based APIs

Genesys Cloud is an API-first platformThis means all of the business logic, workflows and processes carried out in Genesys Cloud is exposed as REST-based web services.  The Genesys Cloud UI is built on the same APIs that we expose to our customers.  This means that we offer a very wide variety of APIs to carry out common business tasks and we even have some customers who have completely forgone the use of the Genesys Cloud UI and instead have built their applications on Genesys cloud.  Most of our API's are built around a synchronous request-response model.  There are several things you need to keep in mind when looking at using our API.  First, you are integrating over the internet using a distributed web protocol.  You need to take into account that failures can occur and you need to build into your application common API invocation best practices, like timeouts, retry, circuit breakers, bulkheads, fallback calls, caching when calling Genesys Cloud APIs. The second thing you need to consider is how much quickly you are going consume the Genesys Cloud APIs and at what volume.  As a general policy, Genesys Cloud does not try to monetize the invocation of their APIs.  However, we do implement [API rate limiting](/api/rest/rate_limits.html) and [API fair usage](https://help.mypurecloud.com/articles/routing-usage/) policies to protect the overall integrity of the platform and ensure that Genesys Cloud consumers are consuming APIs responsibly.  Make sure before you undertake a new integration you understand:

1.  The criticality of the API call within your workflow and protect your application appropriately.
2.  The API invocation density of your integration.  How quickly will your integration invoke an API.
3.  The API invocation volume of your integration.  Will your integration inadvertently consume your API fair use for the month.

Additional information about the Genesys Cloud platform API can be found [here](https://developer.mypurecloud.com/api/). 

### Data Actions

[Data actions](https://help.mypurecloud.com/articles/about-genesys-cloud-data-actions-integration/) allow you to declaratively invoke a third-party web-service or even a Genesys platform API from within a Genesys Cloud script, flow dialer pre-call rule.  Genesys Cloud data actions are not invoked like the Genesys Cloud REST-apis. Instead they are configured through the Genesys Cloud UI and the mapping of the request and response for the invocation is performed through JSON-Path transformations.  Genesys Cloud offers a number of pre-defined data actions for third-party vendors including:  SalesForce, ZenDesk and Adobe.  In addition, if a pre-defined data action, you can configure a generic action to another data source (including APIs within your organization).

:::Webhooks:::


## Data Integration Style
## Presentation Integration Style
## Closing thoughts
## Additional resources

Challenges of cloud integration
  - Bewildering amount of choices
  - Understanding usage patterns
  - Volume
  - Reliability
  - Vendor has multiple ways of integrating
  - Rapidness of change

Integration Styles
  Behavioral Integration
    Integration Patterns
      - Point-to-point
      - Can happen as a direct result of a user interacting with a website.  
      - Can triggered from a workflow
      - Need to plan for failure.  Unlike traditional integration mechanisms there is no two phase commits
        - Retry logic
        - Local Caching/Fallbacks
      - Data Actions and Webhooks
    
  Data Integration
    Quote: Code comes and go, but data is forever.
    Really depends on the direction of data, size of data being pushed and pulled and the data latency.
    
    - Putting data into Genesys cloud is usually done with the APIs.  However, you need to be aware of how quickly you are putting data into the cloud with the APIs.  If you are looking at a large data load, talk with our architects
      and PS folks earlier in the process.
    - Pulling data out of the cloud 
      - First understand what type of data you are trying to look at.
        - Genesys Cloud has three types data APIs: Instantaneous Observations, Aggregations and Detail records
      - If you are looking at pulling data for dashboards that are not dependent on near-time access use the APIs.
      - Ad-hoc queries and data lookups use the APIs
    - Pushing data out of the cloud (e.g. Data Synchronization)
      - For large amounts of data with low data latency requirements - Use the jobs API
      - For near-time data or data where you can not have the latency with the Jobs API use one of two mechanisms:
        - Notifications API with Web Sockets
          - Notifications does not do guaranteed retry so if the socket breaks, everything goes does.  Fortunately, you can tell when a socket goes up or down and you can use the details API to pull the data missing from the timeframe.  It sucks, but living in a distributed development world is rarely rainbows and farting unicorns.  Not pub sub.  Its an non-persistent event stream, if you done consume the messages
        - Notifications with AWS Event Bridge
          - We are in beta now for AWS Event bridge.  Event Bridge will retry message deliver up to 24 hours.  Then you can hook Kinesis up and process and persist the message for as long as you want.
    
  Presentation Integration
    - UI Based Integration
    - Embedded an application directly within Genesys Cloud  (Look at our client apps )
    - Embedded a component within a page (e.g. chat)

Closing thoughts
  - Understand what integration style you are trying to use and choose the right type implementation technology API.
  - Look at your options before jumping right to an API.  Including looking at connectors and third-party plugins. App Foundry. Also check out blueprints
  - Plan for failure

Integration Patterns
Introduction
Greetings.  I hope everyone is safe and healthy in these challenging times. Genesys Cloud has seen a tremendous amount of growth in the last three years.  As more and more organizations have seen the power of the Genesys Cloud platform and have embraced our open API approach to delivering a comprehensive customer experience, the Genesys Cloud leadership team has committed to continually invest in our development community and make sure their experiences with our product are unforgettable.  This investment includes the launching of a new team, the Genesys Cloud Developer Engagement team.

The Genesys Cloud Developer Engagement team is dedicated to connecting the Genesys Cloud development community to all of the technical expertise that exists within Genesys Cloud. Specifically, the Developer Engagement Team is responsible for: 

1. Developer Content
2. Content Management
3. Developer Tooling

In this blog post, we want to share some of the things you will be seeing throughout 2020 and 2021 from this newly formed team.

## Developer Content

**Content is king**.  We have a lot of really good content on our [Genesys Cloud developer center](https://developer.mypurecloud.com) site, but we can make it even better.  Starting now and throughout 2021, we are focused on building `Developer Starting Guides` that will comprehensively cover key development topics within Genesys Cloud.  These `Developer Starting Guides` will demonstrate in depth how to use the Genesys Cloud APIs to carry out tasks in such areas as:  User Provisioning, Analytics, Integration and Conversations.  These guides will not be the tightly focused tutorials we currently have, but will instead be much broader in their purview, showing developers how to leverage our APIs to "connect" the dots across all of our services.  

Our first `Developer Starting Guide` will cover user provisioning and will be available in the next month.  

In addition, we will be delivering more in-depth [Developer Blueprints](https://developer.mypurecloud.com/blueprints) that show you how to integrate Genesys Cloud with other vendors and really focus on delivering value faster to meet the needs of your customers.

In the end we are committed to delivering not only written tutorials, but full projects with code showing our APIs in action.  Nothing speaks truth better then working code.

## Content Management

In next 9 months, you are going to see a reorganization and relaunch of our [Genesys Cloud developer center](https://developer.mypurecloud.com) site.  Expect not only a new look and feel for the [Genesys Cloud developer center](https://developer.mypurecloud.com), but improvements to our search and navigation capabilities.  In addition, the Developer Engagement Team will be focused on how we can personalize your development experience so that no matter where you are at in developing with Genesys Cloud, we will always be presenting you with new and interesting material.

## Developer Tooling 

We get a lot of positive feedback on our developer tools.  We want to continue to build out these capabilities, by integrating them directly into our content and APIs. Our goal is to provide a seamless experience so that you can access the developer tools while reading and working through the content on the site.  In addition, we want to be able to expand our toolset by including new debugging and monitoring tools that will give you greater insight into how your applications are interacting with Genesys Cloud.

## Closing Thoughts

I am extremely excited with the formation of this new team.  Our team is considered a Research and Development group within Genesys and we are focused on changing the developer experience.  What makes this team unique, is that the members of our team are all software engineers who really love to code and share.  It's their passion and that passion is reflected in the work this new team does every day.  

I would love to hear from you and get your thoughts about our team and our mission.  Please feel to free to leave questions and comments in the discussion forum link at the bottom of this post. 
 
 **Let's build something great together.**


John Carnell <br/>
Team Lead <br/>
Developer Engagement