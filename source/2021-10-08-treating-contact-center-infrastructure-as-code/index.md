---
title: How to Begin Your CX as Code Journey
tags: Genesys Cloud, CICD, CX as Code, DevOps
date: 2021-10-08
author: john.carnell
category: 0
image: BYOCCloudtoExternalDevice.png
---

Hello everyone. I hope this year has been better than last year and everyone is staying safe and healthy. Over the course of the last several months, Genesys Cloud introduced a new set of development tools called **CX as Code**.  **CX as Code** is a configuration management tool that allows you to define Genesys Cloud configuration objects (e.g. Queues, Skills, Users, etc) in plain old text files and then apply that configuration across multiple Genesys Cloud organizations. From a technical perspective, **CX as Code** is a plugin built for the Terraform tool chain that lets your define the configuration of Genesys Cloud object without caring how that configuration actually being executed. However, to be effective with **CX as Code** you really need to understand and embrace the principles that drove the creation of **CX as Code**.

## The principles of CX as Code
Let me start by stating that the principles behind **CX as Code** where not uniquely created ideas. The **CX as Code** development team took many of the hard-learned lessons from building microservices, creating their own DevOps practice and building a robust CI/CD pipeline for inspiration in designing **CX as Code**. These principles include:

1. **Contact centers interactions are often modular and represent discrete entry points in an organization**. In Genesys Cloud, contact center interactions begin with Architect flows representing one of many types of channels of communication. Architect flows often have very well defined pieces of infrastructure (e.g. Queues, Data Actions, Scripts, Languages) that must be deployed in order for the flow to function correction. From this point forward, we will define Architect flows and their dependent infrastructure as CX infrastructure component.

2. **Discrete CX infrastructure components should be deployed to a Genesys Cloud environment as a single unit**. If an architect flow changes all the underlying infrastructure dependencies get deployed. **CX as Code** will help determine if a piece of infrastructure needs to change.

3. **The pieces of a CX infrastructure component should live in a single repository**. All of the CX infrastructure pieces should be deployed at the same time using the same process every time.

4. **CX infrastructure components should be defined in plain text files and checked into a version control system**. Version control represents a single source of truth. Any time a change is made to a CX infrastructure component, that change should be checked into source control.

5. **When a CX infrastructure component is deployed it should be deployed through an automated process that involves no human interaction**. Deployments should happen every time changes are committed to your version control system. Automated Tests should run after each deployment to determine that expected functionality for the CX infrastructure is correct. In the lower environments, if a deployment to the development environment passes it should be automatically promoted to a test environment.

## Where are the use cases for CX as Code
**CX as Code** can be leveraged for a number of different use cases. However, each use case has their own design decision that go into them. Three common use cases we see with **CX as Code** are:

1. Provisioning and teardown of disposable Genesys Cloud organizations
2. Deployment of CX infrastructure across multiple Genesys Cloud organizations
3. Replication of core CX infrastructure to a Disaster Recovery (DR) environment

### Provisioning and teardown of disposable Genesys Cloud organizations
Many organizations need the ability to provision Genesys Cloud environments for single use purposes like a demonstration or end-user training. **CX as Code** gives you the ability to create and teardown and environment in a repeatable process. This is particularly useful in a training environment where you want to setup a consistent configuration that let users learn and experiment with Genesys Cloud and then "reset" the environment after the work is done.

When **CX as Code** is used in this fashion its is not uncommon to defined not only your core CX infrastructure (e.g. your Architect flows, queues, scripts, skills, etc...), but also your user accounts, user attributes (what skills and languages the user has), and queue membership.

### Deployment of CX infrastructure across multiple Genesys Cloud organizations
This is by far the most common use case for **CX as Code**. In this use case you are looking an ensure that you can deploy CX infrastructure consistently and repeatably across multiple Genesys Cloud environments. All CX infrastructure is checked into source control and deployment occurs through the use of a Continuous Integration/Continuous Deployment (CI/CD) pipeline.  CX infrastructure is not managed through the UI. The UI would only be used for CX infrastructure in a "break glass" scenario.

If you are looking at using **CX as Code** for this type of use case, some thought needs to be made as to what Genesys Cloud objects are going to be managed with CX as Code. Usually you need to look at the velocity in which configuration is going to change and how tolerant is your organization going to be about making these changes and promoting them via a CI/CD pipeline. 

For example, even though **CX as Code** has the ability to provision users, I would rarely recommend using **CX as Code** to provision users or their attributes (e.g. which skills are assigned to them, which languages they support, or what queues they belong to) because many organizations change this type of configuration several times during the day to meeting the needs of a constantly changing business environment. Tying this configuration to a deployment pipeline can introduce lag in your environment because this data is considered high-velocity and changes frequently.

However, in most organizations, things like, Architect flows, queues definitions, skill definitions, scripts, etc... can change, but do so at a much lower velocity. Your business users can tolerate deploying these things as a slightly slower pace through a CI/CD pipelines. In addition, these type of configuration changes tend to be more tightly controlled because uncontrolled changes in these items could inadvertently cause an outage within your contact center.
### Replication of core CX infrastructure to a Disaster Recovery (DR) environment

## When not to use CX as Code
CX as Code is not a silver bullet solution for doing deployment

## What are the benefits and costs of using CX as Code
## How do I begin working with CX as Code

## Closing Thoughts
## Additional Resources


