---
title: Introducing the Genesys Cloud CLI 
tags: Genesys Cloud, Developer Engagement, CLI, Integration
date: 2021-02-11
author: john.carnell@genesys.com
---

Greetings and welcome to 2021. I want to introduce you to a new tool we are getting ready to release for a limited customer beta this month: Our Genesys Command Line Interface (CLI). Our new CLI will allow you to perform administrative tasks against your Genesys Cloud organization without having to constantly access the Genesys Cloud UI. In addition, the CLI will allow you to easily perform ad-hoc data extracts of common Genesys Cloud object.

## Why does a CLI matter to you
One of the most common questions, I get from developers who have not had to do large scale platform administration is "Why do I need a CLI?". There are three answers to this question:

1. **Simplification and automation of common administrative tasks.** As an administrator on a cloud platform like Genesys Cloud, you will often find yourself having to constantly do day-to-day administrative tasks, like adding new queues or adding users to a skill. If you have to do this type of administrative work with just the UI, it can be tedious and time-consuming. You can write scripts or call our APIs to do this work, but it is much easier to do some lightweight automation with a CLI than writing boilerplate code with our SDK for simple tasks.

2. **Ad-hoc data queries for analysis.** As an administrator for a large amount of infrastructure, I have lost count of the number of times I have gotten requests that go something like this: "Can you extract all of the users who are inactive? We need a CSV file so we can compare that data against our user directory for an audit." When I gave the answer: "Sure, but I will need a couple of days to write the code and test it." I almost always got a look of disappointment, with the reply being, "Can you get it done by tomorrow morning?" Sure, it can, but I have to spend the rest of day (and the evening) to write and test the script. CLIs allow you to perform this type of work with minimal coding effort.

3. **Allows developers to interact with the platform without interrupting their development flow.** There are often times when I am writing code and I need to see the "shape" of the data being returned from an API call or look up an id for a type of record I am working with. CLI's allow me as the developer to perform these actions directly in the IDE or terminal without breaking my flow by having to open up a web browser, navigate to the page, login and then navigate to the object I want to look up.

## The philosophy behind our CLI
There were a lot of internal discussions about how should we build the Genesys Cloud CLI and what we wanted to put in it. Before we started writing the CLI, we documented the principles we wanted to write the CLI with. These principles describe the behavior we wanted in the CLI. They include:

1. **Small with no predefined notions of how it will be used.** We did not want to expose every API command available in our platform API in the CLI. Our API is deep and wide, with many small nooks and crannies. Just blindly copying our API into the CLI would result in an unwieldy and confusing experience for developers. (We actually went through an exercise of generating our API purely off our Swagger documentation. The generated CLI covered everything but was hard to use). As such we have only exposed key Genesys Cloud objects in our API. All data coming in and out of the CLI is JSON. We did not want to try to build complicated workflows within our CLI.

2. **Consistency with our API.** Our goal was to expose our API in an intelligent manner. We strove whenever possible to keep the inputs and outputs for our CLI consistent with the API. The only exception we made to this is when that when we return back lists of object, we automatically aggregate the results of the "list" calls back into a single JSON array. This was done for ease of consumption of the data and avoid forcing the user to make multiple calls with the CLI to get all their data back.

3. **Consistently Discoverable.** We want the CLI to be navigable with the help built into the CLI. In addition, almost all of the commands in our CLI support 5 basic commands: create (create an object), get (get a single object by its id), list (return all of the objects of a particular type) and delete (delete an object). The goal is that even if you have never used a particular Genesys Cloud object before, you could figure out how to use a CLI command with minimal effort.

3. **Easily deployable and performant.** We want to make the CLI as simple as possible to deploy and fast in execution. To this end we decided to build the API using GO. All of our code for the CLI is open source and we currently compile the CLI as a single binary. We pre-compiled binaries for OS X, Linux, and Windows. To install the CLI, you just need to drop the binary into a directory that is in your path.

## How to get the CLI
We are opening up the customer beta for the CLI at the beginning of February. While this beta will be open to all customers, there will be limited support for the CLI until we exit the beta.To download the Genesys Cloud CLI and see instructions on how to setup the CLI, please visit the Genesys Cloud CLI page in the [Developer Center](/api/rest/command-line-interface/).

## Our CLI in Action
Rather then walk through all of the basics of the CLI in written form, we have decided to launch our new video series **Developer Drop** with the first video being an overview of our Genesys Cloud CLI. The **Developer Drop** series is a 10-15 minute series done by developers for developers. It is meant to be extremely informal and covers a single API or topic. The Genesys Cloud CLI **Developer Drop** video can be found [here](https://www.youtube.com/watch?v=OnYDs5NsLpU&list=PL01cVFOkuN70Rk8xgI8pk_tKMcTW4FesF). In this video we demonstrate the CLI to carry out basic tasks and how to combine the CLI with [jq](https://github.com/mikefarah/yq), a JSON transformation, query and filtering command line tool and [yq](https://github.com/mikefarah/yq) a YAML-JSON conversion tool to carry out some pretty standard administration tasks.

In addition, the team has been building a repository of Genesys Cloud CLI [recipes](https://github.com/MyPureCloud/quick-hits-cli). This repository provides several examples of how to use the Genesys Cloud CLI. Right now the examples are very *nix oriented, but we would love to see some PowerShell examples. Pull Requests are welcome.

## Closing Thoughts
We want our Genesys Cloud CLI follow the Unix principles around CLIs and have it be a small sharp tool that can be combined with other command line tools to carry out tasks. As we move forward in our CLI journey, I welcome feedback on this tool. I am specifically looking for areas we might have missed or overlook. Also, in the coming months the Developer Engagement team will be building a repository where you can find common CLI recipes that you can download and use or contribute your own ideas to them. In addition, we will begin working on another set of features for the CLI. Specifically, we are looking at adding commands for performing analytic queries using our APIs and handling the ability to process multiple files of data on a single CLI call.

## Additional Resources
1. [Genesys Cloud CLI](/api/rest/command-line-interface/)
2. [Genesys Cloud CLI Recipes]((https://github.com/MyPureCloud/quick-hits-cli)
3. [Genesys Cloud CLI Developer Drop](https://www.youtube.com/watch?v=OnYDs5NsLpU&list=PL01cVFOkuN70Rk8xgI8pk_tKMcTW4FesF)
4. [jq](https://stedolan.github.io/jq/) 
5. [yq](https://github.com/mikefarah/yq)


