---
title: Introducing **CX as Code**
tags: Genesys Cloud, Developer Engagement, CX as Code
date: 2021-04-19
author: john.carnell
category: 0
---

Greetings everyone. I hope everyone is keeping safe and healthy in these challenging times. I am excited today to introduce the newest tool to the Genesys Cloud developer ecosystem: **CX as Code**. **CX as Code** is a configuration management tool that allows you define Genesys Cloud configuration objects (e.g. Queues, Skills, Users, etc) in plain old text files and then apply that configuration to a Genesys Cloud organization. **CX as Code** is a DevOps tool that will allow you to define Genesys Cloud configuration once and then apply that configuration across multiple Genesys Cloud organizations. It is ideally suited for use in a CI/CD (Continuous Integration/Continuous Deployment) deployment pipeline.

Using the **CX as Code** promotes the following DevOps best practices.

1. __Immutable Configuration__. **CX as Code** allows you to define your Genesys Cloud configuration as text files (e.g code) and not use the UI or scripts to setup our your organization's configuration, you can ensure that your configuration is applied consistently across all of your orgs. Your core configuration becomes immutable. It takes the human being out of the deployment environment and ensure that 

2. __Declarative Configuration__. **CX as Code** allows you to describe what you want your Genesys Cloud configuration to look like without knowing how the your objects are actually created. With **CX as Code** you are able to describe the relationships that exists between objects (e.g. the users belonging to a queue) without having to worry which step in the configuration happens first. **CX as Code** figures out the relationships and dependencies and does the work for you. There was nothing stopping you from scripting this type of behavior by using the Genesys Cloud API, but you would have to know how to managed and implement these relationships dependencies.

3. __Configuration as plain old text__. All configuration managed by **CX as Code** is stored as plain old text files and can be checked into your source control system. This allows you to leverage the versioning and audit capabilities of your source control system and also means that you can deploy the configuration for Genesys Cloud with code changes that depend on it.

# What is **CX as Code** built on
One of the key lessons are own Genesys Cloud DevOps team has learned is that you should not try to build all of your DevOps tools from scratch. Instead, when feasible leverage open source frameworks that encompass industry best practices. To this end the **CX as Code** tool is built on top of HashiCorp's Terraform [[1](https://www.terraform.io/)]. Terraform is a cloud provisioning tool that was originally designed to provide a common language and framework for cloud-based providers like AWS, Azure and Google Cloud. Terraform exposes provisioning functionality through plugins (called providers) that implement how individual cloud objects are created, updated and deleted.

The **CX as Code** team has built a Genesys Cloud provider and it is registered in the Terraform Provider's Registry [[2](https://registry.terraform.io/providers/MyPureCloud/genesyscloud/latest)]. All of the documentation for the Genesys Cloud provider along with all of the objects currently exposed through the provider can be seen in the Genesys Cloud provider's documentation [[3](https://registry.terraform.io/providers/MyPureCloud/genesyscloud/latest/docs)].

**Note: The Terraform registry for **CX as Code** lists all of the Genesys Cloud objects currently available through the Genesys Cloud Terraform provider. The **CX as Code** team is still building additional objects so please check back with the registry for additional updates**

In addition, the **CX as Code** provider is open-source. This means if you want to customize the provider or even offer your own pull request you are able to do so. Pull requests are welcome by the **CX as Code** team. The **CX as Code** repository can be found in the Genesys Cloud Github repo. [[4](https://github.com/MyPureCloud/terraform-provider-genesyscloud)]

# Installing **CX as Code**
To use **CX as Code** you just simply need to install the Terraform CLI [[5](https://www.terraform.io/downloads.html)]. The Terraform CLI is a single binary that can be installed anywhere on your operating system's path. For example, when I work with Terraform, I setup a Linux server and ran the following commands:

```shell
wget https://releases.hashicorp.com/terraform/0.14.10/terraform_0.14.10_linux_amd64.zip
unzip terraform_0.14.10_linux_amd64.zip
mv terraform /usr/local/bin
```

Once you have Terraform installed, you simply need to setup the Terraform files for your Genesys Cloud organization. In your Terraform file(s) you will define that you want to use the Genesys Cloud Terraform provider. When you run Terraform, Terraform will download the Genesys Cloud provider and then begin setting up the configurations defined inside the Terraform file. 

:::{"alert":"info","title":"Using Vagrant as a Quick CX as Code test bed","autoCollapse":false}
I regularly use another Hashicorp tool called Vagrant [[6](https://www.vagrantup.com/)] t
:::


# **CX as Code** in action


# How does **CX as Code** fit into the Genesys Cloud ecosystem

# Additional Resources
1. [Terraform](https://www.terraform.io/)
2. [Genesys Cloud Provider](https://registry.terraform.io/providers/MyPureCloud/genesyscloud/latest)
3. [Genesys Cloud Provider Documentation](https://registry.terraform.io/providers/MyPureCloud/genesyscloud/latest/docs)
4. [Genesys Cloud Github Repository](https://github.com/MyPureCloud/terraform-provider-genesyscloud)]
5. [Terraform CLI](https://www.terraform.io/downloads.html)
6. [Vagrant](https://www.vagrantup.com/)])
