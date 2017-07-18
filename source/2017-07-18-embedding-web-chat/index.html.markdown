---
title: Go through sites's subpages but do not reload the web chat
date: 2017-07-18
tags: chat, webchat, ACD chat
author: dariusz.socha@genesys.com
---

Following [the PureCloud documentation](https://developer.mypurecloud.ie/api/webchat/) you can choose one of two methods of embedding a chat widget into a customer’s webpage. The first method opens the widget in a pop-up window but the second one renders it in a dedicated div element inside the webpage. The main browser window can easily cover the pop-up chat, what isn't desired from a web visitor’s experience point of view. The widget embedded directly in the page seems to be much better solution as it can be rendered on the top most div element and it gives much more possibilities. Using top most div you can show the widget as a sliding or draggable page element in accordance to the latest web design trends. 

### All good?
The webpage is in the background, the chat widget is on the top. The web visitor is chatting to an agent and once he is clicking a link in order to navigate to another subpage then… the spell was broken. The browser is reloading the page, the widget is rendered from scratch, the visitor is going to the ACD queue again and… ‘Hi, how can I help you today?’ - a completely new agent is asking. 

### What’s wrong? 
Nothing. It works as it was combined with the page. The thing is to reload the main page but do not reload the chat widget. It's easy. Make your index.html file a kind of frameset and put your webpage and the chat widget into separate iFrames. 

### All you need are a few HTML tags:
~~~html
<html>
 <body>
  <iframe style="position:absolute; width:100%; height:100%; top:0px; right:0px; bottom:0px: left:0px; z-index:1;" src="{PATH TO YOUR WEBPAGE}"></iframe>
  <iframe style="position:absolute; top:20px; right:20px; height:400px; width:400px; z-index:9999999;" src="{PATH TO A CHAT HTML FILE}"></iframe>
 </body>
</html>
~~~
Having the webpage embedded in a separate iFrame you can go through subpages of your site and it doesn't reload the chat session. It gives much better expirience for web visitors.

## Learn more
[See an example](http://chatinjector.avantago.pl/?en=mypurecloud.ie&ur=https:%2F%2Fdeveloper.mypurecloud.com%2Fblog%2F&oi=1086&on=purecloud-poland&qn=Banking-Queue&la=English%20-%20Written&wm=Welcome%20Dear%20Visitor)

[Combine a testing chat widget with any web page](http://chatinjector.avantago.pl)

[See the source code of above tool](https://bitbucket.org/eccemea/purecloud-chat-injector/src/08e22d4408697976db6479c6fc8167856b574c7c/app/?at=master)

