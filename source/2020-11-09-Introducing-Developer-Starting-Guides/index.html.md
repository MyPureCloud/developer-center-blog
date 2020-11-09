---
title: Introducing our first developer starting guide
tags: Genesys Cloud, Developer Engagement
date: 2020-11-09
author: john.carnell@genesys.com
---

Greetings. I hope everyone continues to stay safe and healthy in these challenging times. The Developer Engagement team has been busy at work, laying the foundation for the relaunch of the Genesys Cloud Developer Center.  Expect next year to see a new look and feel for the site, new developer tools and most importantly new content.  Genesys Cloud is a big platform and while we have a deep repository of API-level documentation, we do not have a lot of content that helps developers who are new to Genesys Cloud "connect" the dots with our APIs.  As a result, new developers have to piece together things through developer forum posts, experimentation and yes, fits of "rage" coding.  

We want change that.  I am pleased to announce the release of our first in a series of new content: [Developer Starting Guides](Developer Starting Guide](/startingguides/).  These guides take a use-case driven approach that focuses on a real-world problem a Genesys Cloud developer might encounter.  Every Developer Starting Guide includes:

1. A full-length tutorial that covers significantly more detail then what has been found in our more traditional tutorials.
2. Insights about developing with Genesys Cloud APIs and an examination of when our APIs can be used inefficiently or inappropriately.
3. A complete GitHub project that a developer can explore and extend.  

All of our Developer Starting Guide projects are open source and can be used as you see fit within your own organization.

Our first [Developer Starting Guide](/startingguides/user-provisioning/) shows developers how to programmatically provision users within Genesys Cloud.  In the User Provisioning guide, you will the Genesys Cloud APIS for:

1. Authenticating your application with Genesys Cloud using OAuth 2.0 client credentials.
2. Creating a user.
3. Adding a user to a group.
4. Adding a user to a role.
5. Creating a WebRTC Phone for the user.
6. Assigning the newly created phone as a default station for the user.

The project is written as a node.js project and includes not only the source code for the projects, but unit tests examples of all the functionality.  The user-provisioning project can be found [here](https://github.com/MyPureCloud/user-provisioning-scripts-js).  

In the next year we will be writing a number of additional Developer Starting guides including:

1. How to integrate with Genesys Cloud 
2. Introduction to the Genesys Cloud Conversation Model
3. Understanding Genesys Cloud Analytics
4. Extending the Genesys Cloud User Interface

Even if you are an experienced Genesys Cloud developer, I hope you take the time to the look this first guide.  Your feedback is always welcome.

Lets build something together.

Thanks,
   John Carnell 
   Manager, Developer Engagement

