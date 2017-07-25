---
title: How we Build and Deploy the PureCloud Developer Center
date: 2017-03-27
tags: devcenter, howwedoit
author: kevin.glinski@genesys.com
---

Back in 2015 our API documentation was launched on a Developer Center that was built on Wordpress.  We quickly realized that while Wordpress is good a what it was designed to do, our requirements were quickly outgrowing that functionality.  Today, the Developer Center is comprised of a number of different pieces deployed to Amazon Web Service and the goal of this article is to explain how those pieces come together and why we chose the architecture that we did.

## Basic architecture

Internally for PureCloud, we use BitBucket to host our source code so most of the Developer Center source code lives there so that anyone in PureCloud development can make changes as they see fit. We try to maintain an environment where service owners are responsible for all areas of their service all the way down to documentation so various service owners will contribute to the documentation on the Developer Center to provide clarification on their resources.

At the same time, we want to open source as much as we can to be available to our partners and customers. We use [Github](https://github.com/mypurecloud/) to host these open source pieces such as the [tutorials](https://developer.mypurecloud.com/api/tutorials.html) and our [Platform API SDKs](https://developer.mypurecloud.com/api/rest/client-libraries/). We make these fully open source because the raw source code can be valuable and also so that we can accept contributions from anyone.

In the Developer Center we use [Discourse](https://www.discourse.org/) for our forum and [Middleman](https://middlemanapp.com/) for the static documentation pages. Discourse is an open source forum that we picked because of how we could deploy it to AWS EC2 instances and since it was open source, we could customize it to fit our needs with custom styling and using PureCloud as a login provider. Middleman was picked so that we could author content in markdown, reuse page layouts and page content, and since it is also open source we could customize it as needed. Our Platform API is documented by the [Open API specification](https://www.openapis.org/) which defines all operations in a json file.  Using this file, we can generate partial html pages using the [Mustache](https://mustache.github.io/) templating engine. At build time, we take these generated API docs and pull in content from different repos then let Middleman generate static html that has a consistent style across all pages.

 This gives us an architecture that looks similar to this diagram.

![Developer Center Architecture](highlevelarchitecture.png "Developer Center Architecture")

## Amazon Web Service Architecture

Once we have all of our static content, we now have to deploy to Amazon Web Services and the deployment looks like this diagram.

![AWS Architecture](aws.png "AWS Architecture")

Requests to developer.mypurecloud.com start by hitting [Route53](https://aws.amazon.com/route53/) which is Amazon Web Service's DNS service.  From there requests go to [Cloudfront](https://aws.amazon.com/cloudfront/) which is Amazon Web Service's CDN.  Cloudfront does two things in our architecture, the first is it handles path based routing so that requests to different parts of the Developer Center can go to different backend services. The second benefit of Cloudfront is that it will globally cache static files.  This cache makes page load times faster because the content is often already at one of Cloudfront's many worldwide server, closer to the requestor. The Developer Center's css and javascript assets also have cache headers set on them so once they are requested once they will remain client side.  HTML pages have don't have client caching headers but are still cached by Cloudfront so the first time the page is requested from one of the edge locations the edge location will have to get it out of S3 located in the US-East region, but any subsequent call for that HTML page will be served by the cached copy in the Cloudfront edge location.

This leads us into where the static files actually reside. The HTML pages are stored in Amazon Web Service's object storage service called [S3](https://aws.amazon.com/s3/). The html pages are stored in one bucket in S3 and every time the Developer Center is built, those html pages are replaced by the newer ones. The static assets are placed in a separate bucket and are placed in a path with the build number in them. Then the html pages reference that specific build number. This is all done to help improve the caching. If you look at the network traffic as the Developer Center loads, you'll see requests that look like **https://d3a63qt71m2kua.cloudfront.net/developercenter/796/**, these are getting the static assets out of the folder from build 796 and will then be cached locally. Different parts of the website are actually deployed to different S3 buckets. The Developer Center doesn't build and deploy as one site, but as a set of microsites, using Cloudfront and S3 to make them seem as one.

The forum is hosted on a set of [EC2](https://aws.amazon.com/ec2/) servers running in a load balancing configuration. They are setup to scale up with more servers to handle more traffic and also to automatically replace servers in the group if one gets into a bad state.

The last piece of the puzzle comes from [AWS Lambda](https://aws.amazon.com/lambda/) which lets us run server side code without having to have actual server running. The site uses back end calls for things like page feedback and the calls are very infrequent so it is much more cost effective to go with lambda over running dedicated EC2 instances.

## Summary

Combining the open source solutions of Middleman and Discourse with the deployment flexibility of Amazon Web Services has allowed us to build the Developer Center to meet all our needs and special use cases. Looking back at our architecture over a year in production, there aren't many things we wished we did differently.
