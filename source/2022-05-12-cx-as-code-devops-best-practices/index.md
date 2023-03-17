---
title: CX as Code and DevOps Best Practices
tags: Genesys Cloud, Developer Engagement, CX as Code, DevOps
date: 2022-05-12
image: decomposed-repositories.png
author: john.carnell
category: 6
---

Greetings everyone! 2022 is flying by. The year is almost half gone. Today, I want to discuss DevOps best practices and how they can be applied to your **CX as Code** implementations. While many developers and administrators are excited by the control and capabilities that **CX as Code** gives, if they are new to the DevOps world, they often miss the context of what makes DevOps practices and tools like **CX as Code** successful. This article discusses the six best practices to consider when using **CX as Code** within your environments. We are going to cover the following:

- No infrastructure monoliths
- Source control is the source of truth
- Minimize shared infrastructure between components
- Whenever possible, move forward, don't roll back
- Know your CI/CD tools
- Start small and iterate

## No infrastructure monoliths
One of the common mistakes new DevOps practitioners make is that they put all of their infrastructure declarations for **CX as Code** as one or two large Terraform projects, all managed from a single source control repository. This is problematic for two reasons:

1. **You have created a single monolithic infrastructure where changes to one part of your CX infrastructure need the entire CX infrastructure to be deployed at the same time**. This means that if multiple teams work within your Genesys Cloud environment and the source code repositories, their changes must be deployed in lockstep because all of your CX as Code definitions stay in the same repository. This is problematic because if you try to roll back a change, you roll back not only your change and any other changes deployed at the same time your change went out. Different teams operate at different deployment velocities, and tying all of these teams together under a single source control repository can be an absolute productivity killer.
2. **It is easy to create implicit cross-component dependencies because your entire CX infrastructure is defined in a single project. As a result, developers can easily reference another component, for example, a queue, skill, language, etc., without thinking through the implications of the changes they are making.** This means that you must have long test cycles to do regression testing of the entire infrastructure. One developer's change can easily disrupt or break multiple components within your CX infrastructure.

Decompose your CX infrastructure into small deployable units of work that mirror the natural communication structure of your organization. If different Lines of Business (LOB) or functional areas work on a system, their respective software components should mirror their organizational structure: each group has a separate repository and code deployment pipeline. This is often referred to as [Conway's law](https://en.wikipedia.org/wiki/Conway%27s_law "Goes to Conway's law page").

To apply Conway's law, start with your Architect flows representing your organization's natural division of responsibility. For each Architect flow, analyze the infrastructure components it consumes (queues, data actions, etc. Then map out the Architect flow definitions and components in **CX as Code**. Place each Architect flow and related artifacts in its own source control repository and deploy it independently.

![Decomposed Repositories](decomposed-repositories.png "Decomposed repositories")

## Source control is the source of truth
This is one of the most complex changes for many organizations to make. If you are going to use **CX as Code** to manage a piece of your Genesys Cloud infrastructure, you need to ensure that all changes to that infrastructure are managed and deployed from your source control system. During an outage or when developers are in a hurry to make a business partner change, the temptation is to log in to the console to make the change. 

By giving in to this temptation, you introduce configuration drift and begin an endless cycle of trying to keep your environments in sync. At first, this might not seem like a big deal. After all, you tell yourself, "hey we circle around and ensure that this change makes it into our **CX as Code** definitions." Hey, people get busy, are not infallible, and change is not propagated. Suddenly your environments become out of sync, and your business partners begin losing confidence in the overall integrity of the different systems.

**CX as Code** is built upon Terraform, which expects to be the sole maintainer of the state of the objects that it owns. If you manually modify a Terraform-managed object and then run your Terraform script, Terraform reverts the object to its initial state. For example, you create and manage a queue through Terraform. Then you go into the console and add extra routing rules to the queue. If you do not add those configuration changes in your **CX as Code** definitions, the next time you deploy your queue via your CI/CD pipeline, those manually-added routing rules will be lost. Manually modifying a Terraform-managed object is bad and can cause an outage: don't do it.

:::{"alert":"Warning","title":"Symptoms of an anti-pattern: source control is not the truth","autoCollapse":false}
**CX as Code** does not support the ability to "snapshot" a specific version and use that snapshot to "roll back" to that version in a different organization. There is almost always some form of manual work to "sync" the organizations.

You are not using your source control system to drive changes if you constantly have to "snapshot" your production environment, sync it back to your development and test Genesys Cloud accounts. A healthy DevOps practitioner uses source control to drive changes instead. This ensures that development, test, and production environments keep their integrity.

**Note**: Terraform does have a good [blog post](https://www.hashicorp.com/blog/detecting-and-managing-drift-with-terraform "Goes to the Detecting and Managing Drift with Terraform") that discusses detecting and fixing configuration drift in one environment.
:::

Here are some key things to think about:

* **Your development Genesys Cloud organization should be a sandbox to try out things. Once your developers have manually experimented with something, they should put their Architect flows, and CX as Code definitions under source control management and then delete their manual configuration.** Infrastructure changes should always be managed via source control and a deployment pipeline. 
* **Lock down your test and production environments so that only a few people can make changes. Too often, organizations do not take the time to properly build out their access control (especially in the lower environments) and leave the environment open so that changes can be made quickly.** While this is a tempting practice from a convenience perspective, it can ruin your confidence in the consistency of your environment.
* **Avoid changing your test/prod environment via the console.** Don't do this unless it is a "break glass" event. Build the behaviors and discipline within your development organization that enforces "anything under **CX as Code** management needs to be deployed via your deployment pipeline." Also, have a documented playbook written to ensure emergency production changes are backported to your **CX as Code** definition. 
* **Not everything in your Genesys Cloud environment should be managed with CX as Code**. Things that change multiple times a day should not be put under **CX as Code** management because those changes need to be handled via your deployment pipeline. For example, if you work in an environment where agent queue assignments can change multiple times a day, you probably want to define your queue definitions in **CX as Code**. Understanding the velocity at which data changes is critical in determining whether **a configuration should be managed by CX as Code**.
* **Automate, automate, automate. There should be no manual parts to your CI/CD pipeline.** Once code is committed to your source control repository, the robots (aka your deployment scripts) handle everything. There should not be a manual movement of files anywhere in your dev/test/production pipeline. There should be no manual movement of files anywhere in your dev/test/production pipeline. Avoid this temptation not to automate because every time a human is involved in your pipeline, you leave the chance for mistakes. 

## Minimize shared infrastructure components
Minimize the number of components shared by your Architect flows as you tease apart configurations. This practice avoids deployment dependencies. Also, don't be afraid to deploy redundant components like skills, groups, or queues that might overlap across flows. While you might end up with duplicate definitions, and this duplication can complicate reporting, maintaining these definitions locally makes it much easier to deploy individual flows. A few other items to consider about shared dependencies:

* **Group shared dependencies with high cohesion into the same repository**. Don't intermix shared **CX as Code** resources in the same repositories. This creates artificial deployment dependencies. For example, if you have Genesys Cloud skills  used across multiple flows, create a skills repository with all your skills definitions and maintain them centrally. The following diagram illustrates how to tease apart shared dependencies into their repositories:

![Shared Group Decompositions repositories](shared_group_decompositions.png "Shared Group Decompositions repositories")

* **Remember: You manage shared dependencies separately from the objects that consume them.** This means that you can deploy shared dependencies separately, often ahead of time, with minimal risk. For example, if you have a shared definition of Genesys Cloud languages, you can deploy the language changes independently from the flows and scripts that consume them. Deploy these changes often and get those changes out.
* **Use a pull request model for changes to shared resources.** Organizations often centralize control of shared resources and allow only the designated team members to update them. Unless the shared resources are very sensitive (for example, credentials management), using your source control system's pull request mechanism instead to enable anyone to branch the code, make changes, and submit a pull request. The designated team should review the changes and merge them into the master branch. However, the actual work for updating the resources should go to the team that needs the updates.

## Whenever possible, move forward, don't roll back
**CX as Code** does not support the ability to roll back an environment to a specific "snap-shotted" version. If you discover a problem in your deployments, I highly recommend a "move forward" model where you make the fix in your lower environments and then promote and deploy the fix to the production environments. If you need to roll back to a previous version, keep this in mind:

* **Using your source control system.** Each time you deploy to production, tag your build. If you need to roll back, redeploy the tagged version of the source control repository.
* **If you are not deploying to the previous version of your configuration, ensure you understand what has changed between the production releases.** Run a terraform plan command before rolling back, and ensure that you don't accidentally drop a resource that was created between releases.
* **Using automated testing as part of your deployment pipeline.** Whenever possible, kick off automated tests to check your code and infrastructure after it has been deployed. Perform these automated tests in your production environment. These automated tests gives a quick feedback loop that confirms your deployment worked. Automated tests also reduce the risk of making quick decisions (such as using the console to make changes) because you do not uncover a deployment issue quickly and are under pressure to fix an issue during critical business hours.

## Know your CI/CD tools 
**CX as Code** is a set of low-level primitives for building CI/CD deployment solutions with Genesys Cloud. This set of primitives does not comprise a shrink-wrapped Disaster Recovery (DR), backup, or migration tool. It can be used to help build these solutions, but this type of tooling is specific to your organization, takes time to be developed, and must be tested regularly. Do not make assumptions about how **CX as Code** (or any CI/CD tool) works. While DevOps and CI/CD practices can give a high level of stability and confidence in your environment, they do not eliminate or minimize the need for IT folks. DevOps is a practice within IT, not a replacement.

## Start small and iterate
Do not try to manage your entire infrastructure using **CX as Code** until you and your development staff have become comfortable and have experience with it. I often advise new DevOps teams to start small and iterate with one Architect flow and one piece of infrastructure. Get a feel for what you want to manage and figure out how to deploy that one piece of infrastructure from the development environment to production. Ensure you understand how not to deploy a solution but also how to roll it back. Iterate and learn as you begin your **CX as Code** journey. Mistakes are made, but it is better to make small mistakes along the way than "go big" and find out you have created a monolith that does not add value but instead adds complexity.

## Additional resources
* [CX as Code](https://developer.genesys.cloud/devapps/cx-as-code/ "Goes to the CX as Code page") in the Genesys Developer Center.
* [Genesys Cloud Provider](https://registry.terraform.io/providers/MyPureCloud/genesyscloud/latest/docs "Goes to the Genesys Cloud Provider page") on the Terraform website. 
* [Introducing CX as Code](/blog/2021-04-16-cx-as-code/ "Goes to Introducing CX as Code blog repository") in GitHub. 
* [DevCast Tutorial 19: Managing your Customer Experience as Code: Introducing CX as Code](https://www.youtube.com/watch?v=21p6hDFipKY&t=1470s "Goes to DevCast Tutorial 19: Managing your Customer Experience as Code: Introducing CX as Code video") on YouTube. 
* [Deploy a simple IVR using Terraform, CX as Code, and Archy](https://github.com/GenesysCloudBlueprints/simple-ivr-deploy-with-cx-as-code-blueprint "Goes to Deploy a simple IVR using Terraform, CX as Code, and Archy blueprint repository") in GitHub.
* [Classify and route emails with Amazon Comprehend blueprint](https://developer.genesys.cloud/blueprints/email-aws-comprehend-blueprint/ "Goes to Classify and route emails with Amazon Comprehend blueprint repository") in the Genesys Cloud Developer Center. 
* [Build a CI/CD pipeline using GitHub Actions, Terraform Cloud, CX as Code, and Archy blueprint](/blueprints/cx-as-code-cicd-gitactions-blueprint/ "Goes to Build a CI/CD pipeline using GitHub Actions, Terraform Cloud, CX as Code, and Archy blueprint") in GitHub.
* [Conway's Law](https://en.wikipedia.org/wiki/Conway%27s_law "Goes to the Conway's law article") in Wikipedia.
* [How to begin your CX as Code Journey](https://github.com/MyPureCloud/developer-center-blog/blob/master/source/2021-10-10-treating-contact-center-infrastructure-as-code/index.md "Goes to How to begin your CX as Code Journey blog") in GitHub.

## Feedback
If you have any feedback or questions, please reach out to us on the [developer forum](/forum/).
