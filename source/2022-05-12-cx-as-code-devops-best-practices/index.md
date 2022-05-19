---
title: CX as Code and DevOps Best Practices
tags: Genesys Cloud, Developer Engagement, CX as Code, DevOps
date: 2022-05-12
image: decomposed-repositories.png
author: john.carnell
category: 6
---

Greetings everyone! 2022 is flying by. The year is almost half gone. Today, I want to spend some time talking about DevOps best practices and how they can be applied to your **CX as Code** implementations. While many developers and administrators are excited by the control and capabilities that **CX as Code** provides, if they are new to the DevOps world, they often miss the context of what makes DevOps practices and tools like **CX as Code** successful. In this article, we are going to talk about the 6 best practices you should consider as you begin leveraging **CX as Code** within your own environments. Specifically, we are going to cover:

- No infrastructure monoliths
- Source control is the source of truth
- Minimize shared infrastructure between components
- Whenever possible, move forward, don't rollback
- Know your CI/CD tools
- Start small and iterate

## No infrastructure monoliths

One of the more common mistakes I see new DevOps practitioners make is that they put all of their infrastructure declarations for **CX as Code** as one or two big Terraform projects, all managed from a single source control repository. This is problematic for two reasons:

1. **You have created a single monolithic infrastructure where changes to one part of your CX infrastructure require the entire CX infrastructure to be deployed at the same time**. This means that if you have multiple teams working within your Genesys Cloud environment and the source code repositories, their changes must be deployed in lockstep because all of your CX as Code definitions reside in the same repository. This is particularly problematic because if you try to roll back a change, you roll back not only your change but also any other changes that were deployed at the same time your change went out. Different teams operate at different deployment velocities, and tying all of these teams together under a single source control repository can be an absolute productivity killer.
2. **It is easy to create implicit cross-component dependencies because your entire CX infrastructure is defined in a single project, and as a result, developers can easily reference another component (e.g. a queue, skill, language, and so on) without thinking through the implications of the changes they are making.** This means that you need to have long test cycles to do regression testing of the entire infrastructure and one developer's change can easily disrupt or break multiple components within your CX infrastructure.

Decompose your CX infrastructure into small deployable units of work that mirror the natural communication structure of your organization. This is often referred to as [Conway's law](https://en.wikipedia.org/wiki/Conway%27s_law). If people from different Lines of Business (LOB) or functional areas work on a system, their respective software components should mirror their organizational structure: each group has a separate repository and code deployment pipeline.

To apply Conway's law, start with your Architect flows which represent the natural division of responsibility within your organization. For each Architect flow, analyze the infrastructure components it consumes (queues, data actions, and so on). Then map out the Architect flow definitions and components in **CX as Code**. Place each Architect flow and related artifacts in its own source control repository and deploy it independently.

![Decomposed Repositories](decomposed-repositories.png "Decomposed repositories")

## Source control is the source of truth
This is one of the hardest changes for many organizations to make. If you are going to use **CX as Code** to manage a piece of your Genesys Cloud infrastructure, you need to ensure that all changes to that infrastructure are managed and deployed from your source control system. In an outage situation or even when your developers are in a hurry to make a change on the behalf of their business partners, the temptation is there to log in to the console and make the change. 

By giving in to this temptation, you are introducing configuration drift and you begin an endless cycle of trying to keep your environments in sync. At first, this might not seem like a big deal. After all, you tell yourself, "hey we will circle around and make sure this change makes it into our **CX as Code** definitions." Hey, people get busy, are not infallible, and changes do not get propagated. Suddenly your environments become out of sync and your business partners begin losing confidence in the overall integrity of the different systems.

**CX as Code** is built upon Terraform, which expects to be the sole maintainer of the state of the objects that it owns. If you manually modify a Terraform-managed object and then run your Terraform script, Terraform will revert the object back to it's prior state. For example, let's say you create and manage a queue through Terraform. Then you go into the console and add additional routing rules to the queue. If you do not add those configuration changes in your **CX as Code** definitions, the next time you deploy your queue via your CI/CD pipeline, those manually-added routing rules will be lost. Long story short, manually modifying a Terraform-managed object is a bad idea and can cause an outage: don't do it.

:::{"alert":"Warning","title":"Symptoms of an anti-pattern: source control is not the truth","autoCollapse":false}
**CX as Code** does not support the ability to "snap shot" a specific version and use that snapshot to "roll back" to that version in a different organization. There is almost always some form of manual work in order to "sync" the organizations.

If you constantly have to "snapshot" your production environment and sync it back to your development and test Genesys Cloud accounts you are not using your source control system to drive changes. A healthy DevOps practitioner uses source control to drive changes instead. This ensures that development, test, and production environments retain their integrity.

**Note**: Terraform does have a good [blog post](https://www.hashicorp.com/blog/detecting-and-managing-drift-with-terraform "Terraform configuration drift blog post") talking about detecting and fixing configuration drift in one environment.
:::

Here are some key things to think about:

1. **Your development Genesys Cloud organization should be a sandbox to try things out. Once your developers have manually experimented with something, they should put their Architect flows and CX as Code definitions under source control management and then delete their manual configuration.** Infrastructure changes should always be managed via source control and a deployment pipeline. 
2. **Lock down your test and production environments so that only a very, very small number of people can make changes. Too often organizations do not take the time to properly build out their access control (particularly in the lower environments) and leave the environment open so that changes can be made quickly.** While this is a tempting practice from a convenience perspective, it can ruin your confidence in the consistency of your environments.
3. **Avoid the temptation to make changes in your test/prod environment via the console.** Seriously, don't do this unless it is a "break glass" event. You need to build the behaviors and discipline within your development organization that enforces "anything under **CX as Code** management needs to be deployed via your deployment pipeline." Also, have a documented playbook written for ensuring emergency production changes are backported to your **CX as Code** definition. 
4. **Not everything in your Genesys Cloud environment should be managed with CX as Code**. Things that change multiple times a day should not be put under **CX as Code** management because those changes will need to be handled via your deployment pipeline. For example, if you work in an environment where agent queue assignments can change multiple times a day, you probably want to define your queue definitions in **CX as Code**, but not map your agents to queues in your **CX as Code** definitions. Understanding the velocity in which data changes is key to determining whether or not a configuration should be managed by **CX as Code**.
5. **Automate, automate, automate. There should be no manual parts to your CI/CD pipeline.** Once code is committed to your source control repository, the robots (aka your deployment scripts) handle everything. There should not be a manual movement of files anywhere in your dev/test/production pipeline. There should be no manual movement of files anywhere in your dev/test/production pipeline. Avoid this temptation to not automate because every time a human being is involved in your pipeline, you leave open the opportunity for mistakes. 

## Minimize shared infrastructure components
As you tease apart configurations, minimize the number of components that are shared by your Architect flows. This practice avoids deployment dependencies. Also, don't be afraid to deploy redundant components like skills, groups, or queues that might overlap across flows. While you might end up with duplicate definitions and this duplication can complicate reporting, maintaining these definitions locally makes it much easier to deploy individual flows. A few other items to consider about shared dependencies:

1. **Group shared dependencies with high cohesion into the same repository**. Don't intermix different shared **CX as Code** resources together in the same repositories. This creates artificial deployment dependencies. For example, if you have Genesys Cloud skills that are used across multiple flows create a skills repository with all of your skills definitions and maintain them centrally. The diagram below illustrates how to tease apart shared dependencies into their own repositories:

![Shared Group Decompositions repositories](shared_group_decompositions.png "Shared Group Decompositions repositories")
2. **Remember: You manage shared dependencies separately from the objects that consume them.** This means that you can deploy shared dependencies separately, often ahead of time, with minimal risk. For example, if you have a shared definition of Genesys Cloud languages, you can deploy the language changes independently from the flows and scripts that consume them. Deploy these changes frequently and get those changes out there.
3. **Use a pull request model for changes to shared resources.** Organizations often centralize control of shared resources and allow only the members of the designated team to update them. Unless the shared resources are extremely sensitive (for example, credentials management), leverage your source control system's pull request mechanism instead to enable anyone to branch the code, make changes, and submit a pull request. The designated team should be responsible for reviewing the changes and merging them into the master branch. However, the actual work of updating the resources should go to the team who needs the updates.

## Whenever possible, move forward, don't rollback
**CX as Code** does not support the ability to roll back an environment to a specific "snap-shotted" version. If you discover a problem in your deployments, I highly recommend a "move forward" model where you make the fix in your lower environments and then promote and deploy the fix to the production environments. If you do need to roll back to a previous version keep the following in mind:

1.  **Leverage your source control system.** Each time you deploy to production, tag your build. If you need to roll back, redeploy the tagged version of the source control repository.
2. **If you are not deploying back to the previous version of your configuration, make sure you understand what has changed between the production releases.** Run a terraform plan command before doing the rollback, and make sure you don't inadvertently drop a resource that was created between releases.
3. **Leverage automated testing as part of your deployment pipeline.** Whenever possible kick off automated tests to check your code and infrastructure after it has been deployed. perform these automated tests in your production environment. These automated tests provide a quick feedback loop that confirms that your deployment worked. Simple, automated tests also reduce the risk of making hasty decisions (such as using the console to make changes) because you do not uncover a deployment issue quickly and are under pressure to fix an issue during critical business hours.

## Know your CI/CD tools 
**CX as Code** is a set of low-level primitives for building CI/CD deployment solutions with Genesys Cloud. This set of primitives does not comprise a shrink-wrapped Disaster Recovery (DR), backup, or migration tool. It can be used to help build these types of solutions, but this type of tooling is specific to your organization, takes time to be developed, and must be tested on a regular basis. Do not make assumptions about how **CX as Code** (or any CI/CD tool) works. While DevOps and CI/CD practices can provide a high level of stability and confidence in your environment, they do not eliminate or minimize the need for IT folks. DevOps is a practice within IT, not a replacement for it.

## Start small and iterate
Do not try to manage your entire infrastructure using **CX as Code** until you and your development staff have become comfortable with it and have experience with it. I often advise teams new to DevOps to start small and iterate with one Architect flow and one piece of infrastructure. Get a feel for what you want to manage and figure out how to deploy that one piece of infrastructure from the development environment to production. Make sure you understand how to not only deploy a solution but also how to roll it back. As you begin your **CX as Code** journey iterate and learn. Mistakes will be made, but it is better to make small mistakes along the way than "go big" and find out you have created a monolith that does not add value but instead adds complexity.

## Resources

1. [Install CX as Code](/devapps/CX-as-Code/ "Goes to the CX as Code page"). General Instructions for installing Terraform.
2. [CX as Code Terraform Registry](https://registry.terraform.io/providers/MyPureCloud/genesyscloud/latest/docs "Goes to the CX as Code Registry page"). This is the Terraform registry page for our Genesys Cloud Provider
3. [Introducing CX as Code](/blog/2021-04-16-cx-as-code/ "Goes to an Introducing CX as Code Blog post") Blog Post. 
4. [DevCast Tutorial 19: Managing your Customer Experience as Code: Introducing CX as Code](https://www.youtube.com/watch?v=21p6hDFipKY&t=1470s "Goes to a CX as Code Webinar") 
5. [Deploy a simple IVR using Terraform, CX as Code, and Archy Blueprint.](https://github.com/GenesysCloudBlueprints/simple-ivr-deploy-with-cx-as-code-blueprint "Goes to a Deploy a simple IVR using Terraform, CX as Code, and Archy Blueprint."). A blueprint that demonstrates how to set up a very Simple IVR with CX as Code. It is meant to be a "Hello World"-style application.
6. [Classify and route emails with Amazon Comprehend Blueprint](/blueprints/email-aws-comprehend-blueprint/ "Goes to a more complex CX as Code blueprint"). A more advanced blueprint that shows a standalone CX as Code implementation in which you deploy a flow and its dependent objects, including queues and data actions.
7. [Build a CI/CD pipeline using GitHub Actions, Terraform Cloud, CX as Code, and Archy Blueprint](/blueprints/cx-as-code-cicd-gitactions-blueprint/ "Goes to the Build a CI/CD pipeline using GitHub Actions, Terraform Cloud, CX as Code, and Archy Blueprint") This blueprint demonstrates how to build a CI/CD pipeline that deploys Genesys Cloud objects across multiple Genesys Cloud organizations.
8. [Conway's Law](https://en.wikipedia.org/wiki/Conway%27s_law "Conway's Law" "Goes to the Conway's law article in Wikipedia")
9. [How to begin your CX as Code Journey](/blog/2021-10-10-treating-contact-center-infrastructure-as-code/ "How to begin your CX as Code Journey"). A blog post that helps provide guidance to the reader about how they should begin their **CX as Code** journey.
## Feedback

If you have any feedback or questions, please reach out to us on the [developer forum](/forum/).
