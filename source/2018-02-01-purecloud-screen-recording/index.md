---
title: PureCloud Screen Recording Powered by WebRTC
tags: webrtc, screen-recording, howwedoit
date: 2018-02-01
author: xander.dumaine
category: 0
---

PureCloud [recently announced the availability of Screen Recording](http://blog.genesys.com/announcing-purecloud-screen-recording/). The new functionality enables the recording of agent desktop activity. Synchronized playback of audio and screen recording enhances quality management capabilities and provides a 360-degree view of agent activity.

Read more about screen recording: http://blog.genesys.com/announcing-purecloud-screen-recording/

## Doubling Down with WebRTC

PureCloud uses WebRTC to power multiple features on the platform, including the [web-based softphone](https://help.mypurecloud.com/articles/about-purecloud-webrtc-phones/), [customer screen sharing](https://help.mypurecloud.com/articles/screen-share-overview/), and now agent screen recording.

PureCloud is able to capture the screen automatically using the PureCloud desktop app, which enables us to control permissions. Then, the screen is streamed securely to PureCloud's [AWS-based media services](https://help.mypurecloud.com/articles/about-the-purecloud-platform/), making use of the WebRTC APIs that power our growing list of real-time media features. Once streamed, the screen capture is encoded and stored for later playback, synchronized with interaction media.

By leveraging open source software and building on top of the open WebRTC project, we're able to provide features like these at low cost, with low maintenance - no software to install and manage.
