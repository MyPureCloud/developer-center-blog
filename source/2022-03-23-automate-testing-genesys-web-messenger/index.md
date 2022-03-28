---
title: Automate testing Web Messenger
date: 2022-03-23
tags: web, messenger, testing, automation
author: lucas.woodward
twitter: SketchingDev
github: SketchingDev
linkedin: lucas-woodward-264388108
image: diagram-of-tool-using-test-script-to-test-web-messenger.png
category: 6
---

Manually testing chatbots can be a slow and error-prone process, especially when testing all potential customer journeys.
The quicker and more reliable approach to testing is to rely on automated tests, which can be triggered with a
click of a button, test all the functionality in a fraction of the time and even act as documentation.

In this article I will guide you through how to write automated tests for [Genesys' Web Messenger](https://help.mypurecloud.com/articles/about-web-messaging/)
using a tool I wrote (in the absence of any others) aptly named [Genesys Web Messaging Tester](https://github.com/ovotech/genesys-web-messaging-tester#readme).
As an aside, we use this tool at OVO as part of a CI/CD process to test our chatbots before they're deployed to
production.

If you want to see the tool and its code head on over to [Genesys Web Messaging Tester on GitHub](https://github.com/ovotech/genesys-web-messaging-tester#readme).

## Writing automated tests

The tool I've written uses [Web Messenger's guest API](https://developer.genesys.cloud/api/digital/webmessaging/websocketapi)
to simulate a customer talking to a Web Messenger Deployment. Once the tool starts an interaction it follows
instructions defined in a file called a 'test-script', which tells it what to say and what it should expect in response.
If the response deviates from the test-script then the tool flags the test as a failure, otherwise the test passes.

![Diagram showing tool using test-script to test Genesys Web Messenger](diagram-of-tool-using-test-script-to-test-web-messenger.png)

It's all pretty straight forward, and as a bonus, because the test-script looks a lot like a transcript (as you'll see
later) it can be shared with the wider business as documentation on how your messenger flow works from a customer's
perspective.

Now we have an overview let's press on with installing the tool and writing a test for a highly contrived chatbot...

### 1. Install the prerequisites

Firstly, we need to [download and install the Node.js runtime](https://nodejs.org/en/download/). This will allow you to
install and run the testing tool.

### 2. Install the tool
Next install the [Genesys Web Messaging Tester tool](https://github.com/ovotech/genesys-web-messaging-tester#readme) by
running the following in [Command Prompt for Windows](https://www.howtogeek.com/235101/10-ways-to-open-the-command-prompt-in-windows-10/),
or Terminal for Mac/Linux:

```shell
npm install -g @ovotech/genesys-web-messaging-tester-cli
```

Once installed you can run the command `web-messaging-tester --help` to see how to use the tool.

```
$ web-messaging-tester --help
Usage: index [options] <filePath>

Arguments:
  filePath                             Path of the YAML test-script file

Options:
  -id, --deployment-id <deploymentId>  Web Messenger Deployment's ID
  -r, --region <region>                Region of Genesys instance that hosts the Web Messenger Deployment
  -o, --origin <origin>                Origin domain used for restricting Web Messenger Deployment
  -p, --parallel <number>              Maximum scenarios to run in parallel (default: 1)
  -h, --help                           display help for command
```

### 3. Write a Test-Script

We are now ready to write a test-script for a Web Messenger Deployment.

The highly contrived chatbot that we'll use as the subject of our test does the following:
1. Asks the customer for their name
2. Greets them by their name and asks how it may help

![Web Messenger Conversation](web-messenger-conversation.png)

The test-script for such as simple bot is equally simple:
```yaml
# test-script.yaml

config:
  deploymentId: 12345c7d-123a-123a-1f3d-a104e02a86a7
  region: usw2.pure.cloud
scenarios:
  "Customer is greeted by the name they provide":
    - say: hi
    - waitForReplyContaining: what is your name?
    - say: Lucas
    - waitForReplyContaining: Hello Lucas, how may I help you today?
```

The test-script is written in a format known as [YAML](https://en.wikipedia.org/wiki/YAML), and consists of two
sections:

#### Config
This section contains the attributes necessary for the tool to find the Messenger Deployment it will test:
* `deploymentId` - ID for the messenger deployment taken from the [Messenger Deployment page](https://help.mypurecloud.com/articles/deploy-messenger/)
* `region` - Region of the Genesys instance that manages the Messenger Deployment ([see your region in the Genesys URL](https://help.mypurecloud.com/faqs/how-do-i-select-my-region/))

#### Scenarios
This section contains a list of scenarios that you want to test, along with the instructions of what to say/expect
beneath each of them. In this case there is only one scenario, but in reality you'd have many more.

### 4. Run the test

The final and most satisfying part is now upon us, running the tests! It's pretty straightforward, you just point the
Web Messaging Tester tool at the test-script file:

```shell
web-messaging-tester test-script.yaml
```

Then watch it test the deployment:

![Recording of Web Messenger test](terminal-recording.gif)

## Conclusion

Hopefully this article has shown how easy it is to test Web Messenger Deployments, along with the advantages that come
with automation! However, automated testing doesn't have to stop here... I'm working on another tool for 
[automating the testing of call flows](https://sketchingdev.co.uk/blog/automating-how-ivr-call-flows-are-tested.html)
which I'd like to blog about soon.

Lastly, if you have any questions about the tool discussed in this article then checkout the documentation on
its [GitHub repository](https://github.com/ovotech/genesys-web-messaging-tester#readme) or Tweet me [@SketchingDev](https://twitter.com/sketchingdev).
