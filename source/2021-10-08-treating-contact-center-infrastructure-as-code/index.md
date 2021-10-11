---
title: How to Begin your CX as Code Journey
tags: Genesys Cloud, CICD, CX as Code, DevOps
date: 2021-10-07
author: john.carnell
category: 6
---

Hello everyone. I hope this year has been better than last year and everyone is staying safe and healthy. Over the course of the last several months, Genesys Cloud introduced a new tool called *CX as Code*. *CX as Code* is a DevOps/configuration management tool that allows you to define Genesys Cloud objects (e.g. Queues, Skills, Users, etc) in plain old text files and then apply those objects across multiple Genesys Cloud organizations. *CX as Code* lets you define the configuration of Genesys Cloud object without caring how that configuration is actually being executed. From a technical perspective, *CX as Code* is a plugin built on top of Terraform. Terraform is open tool created by Hashicorp that allows you to provision cloud-based infrastructure in a non-vendor specific manner. 

In this article we want to:

1.  Understand the principles that drove the creation of *CX as Code*
2.  Define the benefits of using *CX as Code*
3.  Provide guidance on how to get started with *CX as Code*
4.  Discuss when you should look at **not** leveraging *CX as Code* within your organization

## The principles of CX as Code
Let me start by stating that the principles behind *CX as Code* were not uniquely created ideas here at Genesys. The *CX as Code* development team took many of the hard-learned industry lessons from building microservices, their own DevOps practice and a robust CI/CD pipeline for inspiration in designing *CX as Code*.

We derived the following principles from these experiences:

1. **Contact center interactions are often modular and represent discrete entry points in an organization**. In Genesys Cloud, contact center interactions begin with Architect flows representing one of many types of channels of communication. Architect flows often have very well defined pieces of infrastructure (e.g. Queues, Data Actions, Scripts, Languages) that must be deployed in order for the flow to function correctly. 

  :::info
  From this point forward, we will define Architect flows and their dependent infrastructure as CX infrastructure components.
  :::

2. **Discrete CX infrastructure components should be deployed to a Genesys Cloud environment as a single unit**. If an Architect flow changes, all the underlying infrastructure dependencies needs to be deployed with it. *CX as Code* will help determine if a piece of infrastructure needs to change and ensures that changes are consistently applied to a Genesys Cloud organization..

3. **The different pieces of a CX infrastructure component should live together in a single source repository**. All of the CX infrastructure pieces should be deployed at the same time using the same process every time. They should reside in a single repository and kept separate from other CX infrastructure components.

4. **CX infrastructure components should be defined in plain text files and checked into a version control system**. Version control represents a single source of truth. Any time a change is made to a CX infrastructure component, that change should be checked into version control. Version control systems provide a natural audit record of every change that has been made to a piece of configuration and who made that change.

5. **When a CX infrastructure component is deployed, it should be deployed through an automated process that involves no human interaction**. Deployments should happen every time changes are committed to your version control system. Deployment pipelines can vary from organization to organization, but usually include development, test and production environments. Automated Tests should run after deployment to any environment. For example, it's a best practice to automatically deploy to a test environment after tests run and pass in a development environment.

## What are the use cases for CX as Code?
*CX as Code* can be leveraged for a number of different use cases. However, each use case has their own design decisions that goes into them. Three common use cases we see with *CX as Code* are:

1. Provisioning of a Genesys Cloud organization's configuration
2. Deployment of CX infrastructure across multiple Genesys Cloud organizations
3. Replication of core CX infrastructure to a Disaster Recovery (DR) environment

### Provisioning of a Genesys Cloud organization's configuration
Many organizations need the ability to provision Genesys Cloud environments and then reset the configuration back to a baseline. *CX as Code* gives you the ability to provision an environment in a repeatable process. This is particularly useful in a testing or training environment where you want to set up a consistent configuration that lets users learn and experiment with Genesys Cloud and then "reset" the environment after the work is done.

When *CX as Code* is used in this fashion it is not uncommon to define not only your core CX infrastructure (e.g. your Architect flows, queues, scripts, skills, etc...), but also your user accounts, user attributes (what skills and languages the user has), and queue membership.

### Deployment of CX infrastructure across multiple Genesys Cloud organizations
This is by far the most common use case for *CX as Code*. In this use case, *CX as Code* is used to deploy CX infrastructure consistently and repeatably across multiple Genesys Cloud environments. All CX infrastructure is checked into a version control system and deployment occurs through the use of a Continuous Integration/Continuous Deployment (CI/CD) pipeline. CX infrastructure is not managed through the UI. The UI is only used for CX infrastructure in a "break glass" scenario.

If you are looking at using *CX as Code* for this type of use case, some thought needs to be made as to what Genesys Cloud objects are going to be managed with CX as Code. Usually, you need to look at the velocity in which configuration is going to change and how tolerant your organization is about making contact center changes via a CI/CD pipeline rather then directly via a platform administrator. 

For example, even though *CX as Code* can provision users, I would rarely recommend using *CX as Code* to provision users or their attributes (e.g. which skills are assigned to them, which languages they support, or what queues they 
belong to) because many organizations change this type of configuration several times during the day to meet the needs of a constantly changing business environment. Tying this configuration to a deployment pipeline can introduce lag in your environment 
because this data is considered high-velocity and changes frequently. Instead, I would recommend you use the Genesys Cloud [SCIM](https://help.mypurecloud.com/articles/about-genesys-cloud-scim-identity-management/) functionality for user provisioning and identity management.

However, in most organizations, things like, Architect flows, queues definitions, skill definitions, scripts, etc... can change, but do so at a much lower velocity. Your business users can tolerate deploying these things at a slightly slower pace through a 
CI/CD pipeline. In addition, these types of configuration changes tend to be more tightly controlled because uncontrolled changes in these items could inadvertently cause an outage within your contact center.

### Replication of core CX infrastructure to a Disaster Recovery (DR) environment
The third latest use case Genesys for *CX as Code* can be used as part of a Business Continuity Planning (BCP) or Disaster Recovery (DR) scenario. *CX as Code* can be used for these types of solutions, but I have to call out certain key 
facts. *CX as Code* can be used as part of a BCP or DR solution, but it is **not** a complete BCP or DR solution. *CX as Code* is the target for automated deployment of key infrastructure components. So while *CX as Code* can be used to 
replicate core pieces of your contact center to a BCP/DR environment (e.g. architect flows, queues, etc....), it is not designed to move transactional data like recordings, call traffic, etc...

Just remember that BCP/DR solutions can be notoriously complicated to build, maintain, **and** test. *CX as Code* can help you implement a piece of your BCP/DRs solution, but it should be considered only as a component of your overall BCP strategy.

## What are the benefits of using CX as Code
Using *CX as Code* offers a number of benefits including:

1. **Immutability**. *CX as Code* allows a developer to define their contact center infrastructure as plain old text files and check those files into version control. The definitions can then be applied against a Genesys Cloud environment without any direct human intervention. This makes core contact center infrastructure immutable because changes are promoted from environment to environment rather than executed by a developer or administrator.

2. **Modularity**. *CX as Code* encourages developers to break down their infrastructure into well-defined modular components that can be deployed independently of one another. Without a declarative approach to infrastructure, platforms like contact 
centers usually become a monolithic "ball of mud" with interlocking dependencies that make it difficult to test and deploy changes quickly.

3. **Continuous Integration**. Since all configuration changes in *CX as Code* are captured in version control, it becomes simple to kick off and deploy configuration changes to a lower environment immediately. In a more traditional model, 
configuration changes can remain in a development environment for weeks before changes are deployed to a test environment. The more changes that accumulate in a lower environment before being promoted, the harder it is to reason about what has broken 
and when it broke. Automated deployments between lower environments (e.g. development, test, etc...) allow you to surface, respond, and resolve defects quickly.

4. **Controlled repeatable process, not centralized control**. Since all configuration for core infrastructure is kept under version control and all deployments for said infrastructure are done through automation, you have a repeatable process that does not require top-down oversight. This allows teams to move quickly to build and deploy new features without having heavy involvement of a centralized operations team. Even with moving to production where the deployment is not automated, teams can 
leverage the inherent immutability of *CX as Code* to ensure that the same changes that were made to the lower environment are also moved to production.

## How do I begin working with CX as Code
One of the biggest challenges associated with adopting *CX as Code* is knowing exactly where to start. There can be a lot of moving parts and trying to integrate your Architect flow and Terraform components into a CI/CD pipeline can be overwhelming. Here is where I recommend you start:

1. **Don't go big**. One of the first mistakes people make in any kind of Infrastructure As Code (IAC) project is that they try to do too much upfront. Focus on one small project and give your development team time to learn. If you try to do too much, too early, the first time you run into a problem, your team will not have the experience to work through it and they will more than likely get frustrated and quit.

  :::info
  I also advise that you "Don't go big" with your CI/CD infrastructure for your *CX as Code* implementations. Modern cloud-based version control systems (e.g. GitHub/Bitbucket/AWS/Azure) already support the ability to build CI/CD pipelines right within the version control. Leverage cloud vendors to manage your CI/CD pipelines and Terraform (e.g. Terraform cloud). These vendors are often very inexpensive and you do not have to build out and support your own source control repository and build tools (e.g. Jenkins).
  ::: 

2.  **Start from the top down**. I recommend you take one of your Architect flows and work your way down. Identify all the dependencies for that flow. Once you have gone through this de-composition exercise, you now have a list of Genesys Cloud objects to build a *CX as Code* definitions.

3.  **Create source code repositories to contain related Architect flows and the CX as Code definitions**. Many developers will be tempted to put all of their Architect flows and *CX as Code* definitions into a single repository. Instead, focus on breaking your flows into related groups and manage them across multiple repositories. For example, you might consider breaking Architect flows and their dependencies from a a single line of business (LOB) into their own source control repository.

There are two problems with putting all of your flows and their dependencies into a single source control repository. First, many organizations have hundreds of Architect flows and Genesys Cloud objects. A single repository results in a single source of complexity and makes it more difficult to reason about or manage your flows. Second, putting multiple Architect flows and Genesys Cloud objects into a single repository can create artificial dependencies in your deployments, where a change to one flow can force re-deployment of all the other flows and objects.

  :::info
  I highly recommend that you incorporate automated testing into your deployment pipeline. Architect flows and their configuration are code and should be treated as such. Testing your flows immediately after a deployment helps ensure that you do not accidentally introduce defects into your code and helps minimize the opportunities for outages.
  :::

5.  **Build out the CX as Code definitions locally**. Once you have identified a flow and dependencies begin building out your Genesys Cloud definitions incrementally and iteratively. Do not build them out all at once. Instead, iteratively build out your definitions, checking that they are correct before building the flows out. Run everything locally against your Genesys Cloud organization. 

6.  **Only build your CI/CD pipeline once you are happy with your CX as Code definitions**. Do not build your *CX as Code* definitions the same time you are trying to build out your pipeline. Trying to debug both of your *CX as Code* definitions and a new CI/CD pipeline can be extremely painful. Always go back to point #1 "Don't go big".

7.  **As you build out your CI/CD pipeline deploy to one environment at a time and validate**. Do not buildout your CI/CD pipeline all at once. Deploy to your development environment first and validate your CI/CD pipeline and your *CX as Code* definitions. Only after you have validated everything begin working on the test environment and then production. If you try to deploy your CI/CD pipeline too early, it is easy to introduce misconfiguration and not notice it until you have several pieces of code in place. 

## Closing Thoughts
*CX as Code* is a tool and, like all tools, it has a time, place and context for its use. Throughout this article we have talked about the use cases in which *CX as Code* is application and the benefits associated with it. Now let's talk about when you should **not** use *CX as Code*:

1. **You are looking for a low-code, no-code environment**. *CX as Code* is a set of lower-level primitives for deploying your contact center infrastructure in a CI/CD pipeline. It is not a shrink-wrapped, pre-packaged deployment solution that does not require technical time and talent. If you do not have the staff or time to really dig into *CX as Code* don't implement it or it will end in frustration for you and your team.

2. **You have not begun your DevOps journey**. *CX as Code* is a DevOps tool that should be used in teams that are adopting DevOps principles. DevOps requires you to rethink the who and how you deploy software. DevOps is not about centralized control, but about giving teams the freedom and responsibility to deploy software. If you are not ready to embrace the principles of DevOps or you do not have the time and space to allow your development teams to learn *CX as Code* and DevOps you should hold off on leveraging *CX as Code*.

3. **The complexity of your environment**. Genesys Cloud is usable in the smallest organizations to the largest enterprise. If you are a small-to-medium size company with only one Genesys Cloud organization, *CX as Code* might not be the right tool for you. Successful use of *CX as Code* balances the complexity of building and maintaining with *CX as Code* definitions and a CI/CD pipeline with the velocity you achieve with having a consistent and repeatable build and deployment process.

## Additional Resources

1. [Terraform](https://terraform.io)
2. [CX as Code documentation](/api/rest/CX-as-Code/)
3. [CX as Code/Terraform Registry](https://registry.terraform.io/providers/MyPureCloud/genesyscloud/latest)
4. [Terraform Cloud](https://www.terraform.io/cloud)