---
title: CX as Code and DevOps Best Practices
tags: Genesys Cloud, Developer Engagement, CX as Code, DevOps
date: 2022-05-12
image: decomposed-repositories.png
author: john.carnell
category: 6
---

Greetings everyone! 2022 is flying by. The year is almost half-gone. Today, I want to spend some time talking about DevOps best practices and how they can be applied to your **CX as Code** implementations. While many developers and administrators are excited by the control and capabilities that **CX as Code** provides, if they are new to the DevOps world, they often miss the context of what makes DevOps practices and tools like **CX as Code** successful. In this article, we are going to talk about the 6 best practices you should consider as you begin leveraging **CX as Code** within your own environments. Specifically, we are going to cover:

1. No infrastructure monoliths
2. Source control is the source of truth
3. Minimize shared infrastructure between components
4. Whenever possible, move forward, don't rollback
5. Know your CI/CD tools
6. Start small and iterate

## No infrastructure monoliths

One of the more common mistakes I see new DevOps practitioners make is that put all of their infrastructure declarations for **CX as Code** as one or two big Terraform project all managed from a single source-control repository. This is problematic for two reasons:

1. **You have created a single monolith infrastructure where changes to one part of your CX infrastructure require the entire CX infrastructure to be deployed at the same time**. This means that if you multiple project teams working within your Genesys Cloud environment, they must deploy in lockstep because all of your CX as Code definitions reside in the same repository. This is particularly problematic because if you try to rollback a change, you rollback not only your change, but also any other changes that were deployed at the same time your change went out. Different teams operate at different deployment velocities and tying all of these teams together under a single source control repository can be an absolute productivity killer.
2. **It is easy to create implicit cross-component dependencies because your entire CX infrastructure is defined in a single project and as a result developers can easily reference another component (e.g. a queue, skill, language, etc..) without thinking through the implications of the changes they are making.** This means that you need to have long test cycles to do regression testing of the entire infrastructure and one developer's change can easily disrupt or break multiple components within your CX infrastructure.

Decompose your CX infrastructure down into small deployable units of work that mirror the natural communication structure of your organization. This is often referred to an [Conway's law](https://en.wikipedia.org/wiki/Conway%27s_law). This means that if you have multiple Lines of Business (LOB) or functional areas working on a system, the software components they are building should mirror the the organizational structure with each group having separate repositories and code deployment pipelines rather then a single monolithic repository.

To apply Conway's law and look at how you contact centers code maps to a functional area, I recommend you start with your Architect flows. Your Architect flows represent a natural division of responsibility within your organization. Take each of your Architect flows and map out the infrastructure they consume (e.g. queues, Data Actions, etc...). Place the Architect flow definitions along with the components they consume and map them out in CX as Code. These items should then be placed in their own source control repositories and deployed independently of one another.

The diagram below illustrates this decomposition is action:

![Decomposed Repositories](decomposed-repositories.png "Decomposed repositories")

This way different pieces of code (e.g. your flows) can be deployed independently of one another.

## Source control is the source of truth
This is one of the hardest changes for many organizations to make. If you are going to use **CX as Code** to manage a piece of your Genesys Cloud infrastructure, you need to ensure that all changes to that infrastructure are managed through the source control system **and** all changes are deployed from the source control system. In an outage situation or even when your developers are in a hurry to make a change on the behalf of their business partners, the temptation is there to just log in to the console and make the change. 

By giving in to this temptation, you are introducing configuration drift and you begin an endless cycle of trying to keep your environments in sync. At first this might not seem like a big deal. After all you tell yourself, "hey we will circle around make sure this change makes it into our **CX as Code** definitions." However, people get busy and they are not infallible and changes do not get propagated. Suddenly your environments become out of sync and your business partners begin losing confidence in the overall integrity of the different environments.

Terraform, the technology **CX as Code** is built on, expects to be the sole maintainer of the state of objects that it owns. If you manually modify an object that Terraform/**CX as Code** maintains the next time your run your Terraform script, Terraform will update the object back to the state it is expecting it to be in. So for example, let's say you create and manage a queue through Terraform. If you go into the console and add additional routing rules to the queue, if you do not add those configuration changes in your **CX as Code** definitions, the next time you doa deploy via your CI/CD pipeline, those manually added definitions will be lost. Long story short, manually modifying a Terraform managed object is a bad idea and can cause an outage.  **Don't do it.**

:::{"alert":"Warning","title":"Symptoms of an Anti-Pattern: Source Control is not the Truth","autoCollapse":true}
Genesys Cloud's **CX as Code** provider (and Terraform) does not support the ability to "snapshot" or "rollback" to specific versions of Genesys Cloud between organizations. Snapshotting and reconciling multiple Genesys Cloud's organizations tends to be a combination of using the **CX as Code** export functionality and then re-applying the exported Terraform file from one environment to the other.  However, there are almost always some form of manual work that needs to be done that involves dropping and recreating objects if relationships exist between the objects.

If you are constantly have to "snapshot" your production environment and sync it back your development and test Genesys Cloud accounts you are not using your source control system to drive changes. A healthy DevOps practice will not involve syncing of infrastructure/configuration back from a higher level environment back to a lower level environment.

**Note**: Terraform does have a good [blog post](https://www.hashicorp.com/blog/detecting-and-managing-drift-with-terraform "Terraform configuration drift blog post") talking about detecting and fixing configuration drift in one environment.
:::

Here are some key things to think about:

1. **Your development Genesys Cloud organization should be a sandbox to try things out. Once your developers have manually experimented with something, they should put their Architect flows and CX as Code definitions under source control management and then delete their manual configuration.** Infrastructure changes should always be managed via source control and a deployment pipeline. 
2. **Lockdown your test and production environments so that only a very, very small number of people can make changes. Too often organizations do not take time to properly build out their Access Control (particularly in the lower environments) and leave the environment open so that changes can be made quickly.** While this is a tempting practice from a convenience perspective, it can ruin the confidence you have that your environments are consistent.
3. **Avoid the temptation to make changes in your test/prod environment via the console.** Seriously, don't do this unless it is "break glass" event. You need to build the behaviors and discipline within your development organization that enforces "anything under **CX as Code** management needs to be deployed via your deployment pipeline."  Also, have a documented playbook written for ensuring emergency production changes are backported to your **CX as Code** definition. 
4. **Not everything in your Genesys Cloud environment should be managed with CX as Code**. Things that change multiple times a day should not be put under **CX as Code** management because those changes will need to be handled via your deployment pipeline. For example, if you work in an environment where agent queue assignments can change multiple times a day you probably want to define your queue definitions in **CX as Code**, but not map your agents to queues in your **CX as Code** definitions. Understanding the velocity in which data changes is key to determining whether or not a configuration should be managed by **CX as Code**.
5. **Automate, automate, automate. There should be no manual parts to your CI/CD pipeline.** Once code is committed to your source control repository, the robots (aka your deployment scripts). There should be not manual movement of files anywhere in your dev/test/production pipeline. This would seem to be a intuitive statement, but I have frequently found that many organizations will automate to 80% of their pipeline and then not finish the last 20% of automation because it is difficult to do. Avoid this temptation to not automate because every time a human being is in involved in your pipeline, there is an opportunity for mistakes. 

## Minimize shared infrastructure components
As you tease apart configurations minimize the amount of shared components between your Architect flows. Minimizing these shared dependencies avoids deployment dependencies. Also, don't be afraid to deploy redundant components like skills, groups or queues that might overlap across flows. While you might end up with duplicate definitions and it can complicate reporting, maintaining these definitions locally makes it much easier to deploy individual flows. A few other items to consider about shared dependencies:

1. **Group shared dependencies with high cohesion into the same repository**. For example, if you have skills that are used across multiple flows create a skills repository with all of your skills definitions and maintain them centrally. Don't intermix different shared CX as Code resources together in the same repositories. This creates artificial deployment dependencies. The diagram below illustrates how to tease apart shared dependencies into their own repositories:

![alt text](shared_group_decompositions.png "Shared Group Decompositions repositories")
2. **Remember many shared dependencies can be deploy independently of the things consuming them and get often be deployed ahead of time with minimal risk**. So for instance, if you have a shared definition of languages, the language changes can often be deployed independently of the flows or scripts consuming them. Deploy these changes frequently and get those changes out there.
3. **Use a pull request model for changes to shared resources**. Often times organizations will centralize control of shared resources and only allow those resources to be directly changed by that group. Unless the resources are extremely sensitive (e.g. credentials management), leverage your source control system's pull request system to allow the individuals who want the change to branch the code and submit a pull request. The centralized group should be responsible for reviewing the changes and merging them into the master branch. The actual work of doing the configuration should go to the team doing the work.

## Whenever possible, move forward, don't rollback
**CX as Code** (and the Terraform project it is built on) does not have the concept of environmental snapshots and the ability to rollback code to a specific version. If you discover a problem in your deployments, I highly recommend a "move forward" model where you make the fix in your lower environments and then promote and deploy the fix to the production environments. If you do need to rollback to a previous version keep the following in mind:

1. **Leverage your source control system.** Each time you deploy to production tag your build. If you need to rollback, redeploy that version of the source control repository. 
2. **If you are not deploying back to the previous version of your configuration, make sure you understand what has changed between between the production releases**. Run a `terraform plan` before doing the rollback and make sure you don't inadvertently drop a resource that was created between releases. 
3. **Leverage automated testing as part of your deployment pipeline.** Whenever possible kickoff automated tests to check your code and infrastructure after it has been deployed. This includes in production. These automated tests provide a quick feedback loop that your deployment worked and reduces the risk of making hasty decisions (e.g. using the console to make changes) because you are under pressure to fix an issue during critical business hours.

## Know your CI/CD tools 
**CX as Code** is a set of low-level primitives for building CI/CD deployment solutions with Genesys Cloud. It is not a shrink-wrapped Disaster Recovery (DR), backup, or migration tool. It can be used to help build these type of solutions, but this type of tooling will need to be specific to your organization, takes time to be developed and must be tested on a regular basis. Do not make assumptions about how **CX as Code** (or any CI/CD tool) works. While DevOps and CI/CD practices can provide a high-level of stability and confidence in your environment, they do not eliminate or minimize the need for IT folks. DevOps is a practice within IT, not a replacement for it.

## Start small and iterate
Do not try to manage your entire infrastructure using **CX as Code** until you and your development staff have become comfortable with it and have experience with it. I often advise teams new to DevOps to start small and iterate with one Architect flow and one piece of infrastructure. Get a feel for what you want to manage and figure out how to deploy that one piece of infrastructure from the development environment to production. Make sure you understand how to not only deploy a solution, but also how to roll it back. As you begin your **CX as Code**
journey iterate and learn. Mistakes will be made, but it is better to make small mistakes along the way then try to "go big" and then find out you have created a monolith that does not add value, but instead adds complexity.

## Resources

1. [Install CX as Code](/devapps/CX-as-Code/). General Instructions for installing Terraform.
2. [CX as Code Terraform Registry](https://registry.terraform.io/providers/MyPureCloud/genesyscloud/latest/docs). This is the Terraform registry page for our Genesys Cloud Provider
3. [Introducing CX as Code](/blog/2021-04-16-cx-as-code/) Blog Post. 
4. [Managing your customer experience as code](https://www.youtube.com/watch?v=21p6hDFipKY&t=1470s) 
5. [HelloWorld CX as Code Blueprint](https://github.com/GenesysCloudBlueprints/simple-ivr-deploy-with-cx-as-code-blueprint). A blueprint that demonstrates how to set up a very Simple IVR with CX as Code. It is meant to be a hello world style application.
6. [Standalone CX as Code Blueprint](/blueprints/email-aws-comprehend-blueprint/). A more advanced blueprint that shows deploying a flow and its dependent objects, including queues and data actions.
7. [CI/CD Example with CX as Code Blueprint](/blueprints/cx-as-code-cicd-gitactions-blueprint/). This blueprint demonstrates how to build a CI/CD pipeline using Github Actions, Terraform Cloud, and CX as Code.
8. [Conway's Law](https://en.wikipedia.org/wiki/Conway%27s_law "Conway's Law")
9. [How to begin your CX as Code Journey](/blog/2021-10-10-treating-contact-center-infrastructure-as-code/ "How to begin your CX as Code Journey"). A blog post that helps provide guidance to the reader about how they should begin their **CX as Code** journey.
## Feedback

If you have any feedback or questions, please reach out to us on the [developer forum](/forum/).
