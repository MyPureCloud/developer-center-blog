---
title: Go through sites's subpages but do not reload the web chat
date: 2017-07-18
tags: chat, webchat, ACD chat
author: dariusz.socha@genesys.com
---

Following [the PureCloud documentation](https://developer.mypurecloud.ie/api/webchat/) you can choose one of two methods of embedding a chat widget into a customer’s webpage. The first method opens the widget in a pop-up window and the second one renders it in a dedicated div element inside the webpage. The pop-up chat option has its challenges. However, often the web visitor forgets about the pop-up as it gets covered up by the main browser window and when he is finally connected to an agent he is no longer responding. This leads to a frustrating experience and also wastes agent's time. The widget embedded directly in the page seems to be much better solution as it stays in front of the customer's eyes. It can be rendered on the top most div section as a sliding or draggable page element in accordance to the latest web design trends.

### All good?
The webpage is in the background, the chat widget is on the top. The web visitor is chatting to an agent and once he clicks a link in order to navigate to another subpage then… the spell is broken. The browser reloads the page, the widget is rendered from scratch, the visitor is sent to the ACD queue again and… ‘Hi, how can I help you today?’ - a completely new agent is asking. 

### What’s wrong? 
Are you wondering why did it happen? You have embedded the chat as a part of the page that was entirely reloaded. The thing is to reload the main page but do not reload the chat widget. It's easy. Make your index.html file a kind of frameset and put your webpage and the chat widget into separate iFrames. 

### All you need are a few HTML tags:
~~~html
<html>
 <body>
  <iframe style="position:absolute; width:100%; height:100%; top:0px; right:0px; bottom:0px: left:0px; z-index:1;" src="{PATH TO YOUR WEBPAGE}"></iframe>
  <iframe style="position:absolute; top:20px; right:20px; height:400px; width:400px; z-index:9999999;" src="{PATH TO A CHAT HTML FILE}"></iframe>
 </body>
</html>
~~~
When you have webpage embedded in a separate iFrame you can go through subpages of your site and it doesn't reload the chat session. It gives much better experience for web visitors.

## Learn more
[See an example](http://chatinjector.avantago.pl/?en=mypurecloud.ie&ur=https:%2F%2Fdeveloper.mypurecloud.com%2Fblog%2F&oi=1086&on=purecloud-poland&qn=Banking-Queue&la=English%20-%20Written&wm=Welcome%20Dear%20Visitor)

[Combine a testing chat widget with any web page](http://chatinjector.avantago.pl)

[See the source code of above tool](https://bitbucket.org/eccemea/purecloud-chat-injector/src/08e22d4408697976db6479c6fc8167856b574c7c/app/?at=master)

