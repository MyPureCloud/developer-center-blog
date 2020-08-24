---
title: Overview of the Lex-Kendra Chatbot Deployment
date: 2020-08-24
tags: aws, webchat, lex
author: jeff.beard@genesys.com
---
##  Solution overview
This blog post provides an overview of the Lex-Kendra chatbot on Genesys Cloud. The Lex-Kendra chatbot is part of the AWS Contact Center Intelligence (CCI) accelerator. This integrated solution enhances the capabilities of Genesys Cloud with a conversational AI capability from AWS. 

Genesys Cloud uses the Genesys Cloud Lex integration to provide customers with a standard Amazon Lex chatbot. The Lex-Kendra chatbot solution combines this basic Lex chatbot with Amazon Kendra to create a Lex-Kendra self-service chatbot. This combination enables an Amazon Lex flow to invoke an AWS Lambda function to call Amazon Kendra after a customer initiates a chat and enters a triggering question. Amazon Kendra uses natural language processing and machine learning abilities to process the customer's question and search an informational database stored in Amazon S3. Amazon Kendra and AWS Lambda then route the discovered answer back into the customer chat. All of this occurs without live agent assistance.

![Genesys Cloud and the Lex-Kendra Chatbot](bpKendraOverviewMR.png)

### Solution components:

* **Genesys Cloud** - The Genesys cloud-based contact center platform. Genesys Cloud is the platform for the Lex-Kendra chatbot solution.
* **Lex Chatbot** - Amazon Lex is an AWS service for building conversational interfaces for applications using voice and text, including the Lex chatbot. You can call the Lex chatbot into inbound chat flows with Architect, the Genesys Cloud flow designer.
* **Genesys App Foundry** - The Genesys App Foundry is an app marketplace for solutions that run on the Genesys Cloud platform. You get the Amazon Lex integration used in the solution from the Genesys App Foundry.
* **AWS Cloud** - Amazon Web Services (AWS) is Amazon's cloud platform. AWS is the platform for Genesys Cloud and the Lex-Kendra chatbot solution.
* **AWS CCI** - AWS Contact Center Intelligence (CCI) is a set of integrated contact center partner solutions powered by AWS AI to improve the customer experience and accelerate operational efficiencies. The Lex-Kendra chatbot is part of the AWS CCI self-service accelerator.
* **Amazon Kendra** - Amazon Kendra is an enterprise search service powered by machine learning that delivers natural language search capabilities. The Lex-Kendra chatbot uses Kendra to search for answers to the customer's questions.
* **Amazon S3** - Amazon Simple Storage Service (S3) is an object storage service. Amazon S3 hosts the document repository searched by Kendra.
* **AWS CloudFormation** - AWS CloudFormation provides a template for you to model and provision AWS and third-party application resources in your cloud environment. An AWS CloudFormation template for the Lex-Kendra chatbot is used to deploy the AWS components of the solution.
* **AWS IAM** - AWS Identity and Access Management (IAM) manages access to AWS services and resources. You set up the permissions to allow and deny access to AWS resources for the Lex-Kendra chatbot solution in AWS IAM.
* **AWS Lambda** - AWS Lambda is a compute service in AWS. AWS Lambda executes Kendra fulfillment and other operations for the solution.

## Plan the solution
This solution requires permissions and configuration with both Genesys Cloud and AWS. It also requires installation from the Genesys AppFoundry.
### Specialized knowledge
Implementing this solution requires experience in several areas or a willingness to learn:
* Administrator-level knowledge of Genesys Cloud and the Genesys AppFoundry
* AWS Cloud Practitioner-level knowledge of AWS CloudFormation, AWS IAM, Amazon Lex, Amazon S3, and AWS Lambda
* Conceptual-level knowledge of Amazon Kendra

### Genesys Cloud account requirements

This solution requires a Genesys Cloud license. For more information on licensing, see [Genesys Cloud Pricing](https://www.genesys.com/pricing "Opens the pricing article").

Before you can obtain the Amazon Lex integration from the Genesys App Foundry, you must contact Genesys Cloud Sales to update your subscription to allow premium applications. For more information, see [What are premium applications](https://help.mypurecloud.com/?p=173966 "Opens the premium applications article").

A recommended Genesys Cloud role for the solutions engineer is Master Admin. For more information on Genesys Cloud roles and permissions, see the [Roles and permissions overview](https://help.mypurecloud.com/?p=24360 "Opens the Roles and permissions overview article").

### AWS account requirements
The solutions engineer requires an AWS account and administrator level credentials that allow:
* Working with AWS CloudFormation templates
* Working with AWS IAM permissions
* Creating an Amazon S3 bucket to store the document repository
* Creating an AWS Lambda function, Amazon Kendra indexes, and an Amazon Lex bot

## Deployment stages

The Lex-Kendra chatbot deployment has the following stages:
* Create an Amazon S3 bucket and upload the FAQ document.
* Deploy the AWS CloudFormation template.
* Create a queue in Genesys Cloud.
* Install and activate the Lex integration app on Genesys Cloud.
* Call the Lex-Kendra chatbot on inbound chat flows with Genesys Cloud Architect.
* Create a Genesys web chat widget and test the Lex-Kendra solution.
* Deploy the Lex-Kendra chatbot to your website.

## Detailed instructions
Detailed deployment instructions and solution components for the Lex-Kendra chatbot solution are located in the [aws-lex-kendra](https://github.com/MyPureCloud/aws-lex-kendra "Opens the Amazon Lex integration FAQs article") GitHub repository of Genesys Cloud Labs.
