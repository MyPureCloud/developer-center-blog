---
title: Building Resiliency into your Cloud Integration Patterns
tags: Genesys Cloud, Developer Engagement, Resiliency, Integration
date: 2021-06-15
author: john.carnell
category: 6
---

Greetings everyone. I hope everyone is keeping safe and healthy in these trying times. Today's blog post is on building resiliency into your Genesys Cloud integrations. On the surface, building an integration to a cloud-based platform often seems simple. Almost every cloud provider has APIs and SDKs to invoke their platform's services. For many, the conceptual work involved with designing their cloud-based integrations looks something like this:

![Simplified view of cloud integration](module_0_conceptual_view.png)

While the above diagram seems simple with a client invoking a single API as a distributed service, the reality is often much more complicated. A cloud provider's APIs represent a complex set of microservices and infrastructure working together to deliver a robust and scalable set of features. When you call Genesys Cloud's public API for example, you are not calling a singular API, but instead calling an API gateway that directs you to multiple service instances sitting on top of a number of cloud-based pieces of infrastructure. This combination of services and infrastructure is necessary to deliver a multi-tenant, cloud-based enterprise contact center solution. The diagram below illustrates some of the size, scope and complexity of the Genesys Cloud platform.

![Actual view of cloud integration](module_0_actual_view.png)

For integrations with cloud-based provider, you as a developer need to be able to handle failure scenarios that can involve not only a complete failure of the service being invoked, but also situations where the targeted service is running in a degraded fashion (e.g. running slowly or failing intermittently). Your goal as an integration developer leveraging a cloud-platform is to ensure your integrations can:

1. __Fail fast__.  If a cloud-based service provider is having issues, you want to ensure that your integration calls notice the problem quickly and ensure that your integration does not continue to call a cloud-based service that is struggling. This keeps a cloud service experiencing problems from being continually "hammered" with failing requests.

2. __Fail gracefully__. A well designed integration should fail gracefully and not completely crash when a cloud-provider it is using experience difficulties. Different mechanisms for failing gracefully include providing alternative data stores and code paths when a failure is detected and including the ability for integrations to retry and self-heal when a cloud-provider returns to full health. 

3. __Stop the spread__. Every integration internally and externally within your organization's IT ecosystem represents an opportunity for failure. As you design your integrations you want to ensure that a failure in one integration does not cause a cascading effect that causes other systems and services to fail. 

Fortunately, there have been a number of resiliency patterns identified and documented to meet the three goals outlined above. Let's walkthrough these resiliency patterns.

# Resiliency Patterns in Action

There are 6 core resiliency patterns we are going to discuss in this blog post. Each of these patterns by themselves provide value and a good developer will often use a combination of these patterns in their integrations. The diagram below shows these 6 resiliency patterns and how they can be "stacked" together:

![Patterns in Action](module_0_pattern_stack.png)

In general, resiliency patterns can be classified into two groups of patterns:  __transient patterns__ and __proactive patterns__.  Transient patterns help an integration recover in the event of small interruptions of service where the service recovers quickly. Usually transient patterns are useful when dealing with rate-limiting (e.g 429 HTT status codes) and intermittent timeouts on the service (e.g. 502, 503 and 504s). Cloud services can often determine if they are having an issue they can recover from (e.g. rate-limit or load shedding events) and use transient patterns to signal to an invoking client that the failures is retryable.

Proactive patterns are used when you have a service that is failing and the service can not signal to the client invoking it that its problems can be recovered from (e.g. a 500 status code). In this case, proactive patterns help your application fail fast and finding alternative paths for carrying out their tasks and stopping the cascading spread of a service failure.

1. __Caching__. Caching is used to minimize the number of calls to a downstream service. While caching has uses outside of resiliency, it can be used to improve resiliency by greatly reducing the calls to a cloud service provider and also allowing integrations to access data even if the downstream service is unavailable.

2. __Retry__. Retries are one of the fundamental patterns used for transient failures. With a retry pattern, you intercept key exceptions being returned by a service call and then attempt to call the targeted service X number of times with a backoff time period being applied between each call. 

3. __Timeouts__. Not all failures are spectacular incidents where a service is completely down. Instead, a service might be experiencing significant slowdowns in service calls. Timeouts allow you to kill a long-running connection before it starts tying up critical resources (e.g. threads) within your application.

4. __Circuit breakers__. Circuit breakers in software are used to protect your integration from slow and failing downstream services by detecting if a service invocation is failing and not allow the integration to continue to call the service if the service call has failed enough times. Instead, much like a circuit breaker in your home, a software circuit breaker will "pop" to prevent further calls.  The circuit break will then let occasional service invocations through to see if the service has recovered. Circuit breakers protect the resources an integration is using by failing fast and when combined with the fallback pattern, allow an integration to switch to seek alternative code paths in the event of a failure.

5. __Fallbacks__.  The Fallback pattern is used in conjunction with many other resiliency patterns (e.g. retry, timeout and circuit breaker patterns) and provides an alternative code path to be invoked when a service invocation fails within your integration. Fallbacks will typically read older data and default to less-then optimal action that will keep your integration functioning without failing completely. 

6. __Bulkheads__. The Bulkhead pattern models how cargo ships are built. A cargo ship is divided into multiple watertight compartments and if one part of the ship is breached, the entire ship will not flood because the leaking water is not allowed to spread into the other parts of the ship.  The Bulkhead pattern divides the service calls you are going to make into their own well-defined, bounded set of thread-pools. If one service's invocations are taking an extremely long time to respond, the slow-running service calls will only be able to consume the threads assigned to their thread pool. This prevents a slow running response from a service from consuming all of the resources threads with an integrations thread pool or operating system.

<br/><br/>

# Resiliency pattern implementations
I am not going to walkthrough each of the patterns listed above in detail in this blog post. Instead, I have created a sample project that shows how these patterns can be used with the Genesys Cloud Java SDK running with Spring Boot and Resilience4j. The sample project containing these implementations can be found [here](https://github.com/MyPureCloud/resiliency-patterns-examples).  The specific implementations for each of the resiliency patterns listed above can be found at:

1. [Caching](https://github.com/MyPureCloud/resiliency-patterns-examples/tree/main/src/main/java/com/genesys/resiliency/service/QueueServiceCacheFacade.java)
2. [Retrys](https://github.com/MyPureCloud/resiliency-patterns-examples/tree/main/src/main/java/com/genesys/resiliency/service/QueueServiceRetryFacade.java)
3. [Timeouts](https://github.com/MyPureCloud/resiliency-patterns-examples/tree/main/src/main/java/com/genesys/resiliency/service/QueueServiceTimeoutFacade.java)
4. [Circuit Breakers](https://github.com/MyPureCloud/resiliency-patterns-examples/tree/main/src/main/java/com/genesys/resiliency/service/QueueServiceCircuitBreakerFacade.java)
5. [Fallbacks](https://github.com/MyPureCloud/resiliency-patterns-examples/tree/main/src/main/java/com/genesys/resiliency/service/QueueServiceFallbackFacade.java)
6. [Bulkheads](https://github.com/MyPureCloud/resiliency-patterns-examples/tree/main/src/main/java/com/genesys/resiliency/service/QueueServiceStackedFacade.java)
7. [Combining the patterns together](https://github.com/MyPureCloud/resiliency-patterns-examples/tree/main/src/main/java/com/genesys/resiliency/service/QueueServiceStackedFacade.java)

<br/>
In addition to the sample implementation, the Developer Engagement team also put together some additional source material around the topic of building resilient applications:

|Title| Description|
|-----|------------|
|[Building resilient apps in Genesys Cloud](https://www.youtube.com/watch?v=0Y37xlfZLtg&t=1962s) | This is an approximately 60 minute webinar recorded on June 3rd, 2021 that walks through each of the resiliency patterns listed above in detail. |
|[Rate-limiting and the Genesys Cloud Platform API](https://youtu.be/_Ugol0NZMbk)| This DevDrop covers one of the most common problems new developers with Genesys Cloud runs into, rate-limiting. We cover Genesys Cloud's philosophy on rate-limits and how to handle them when your code encounters them. | 
|[Using the Genesys Cloud Java SDK's retry logic for rate limits](https://youtu.be/QfwXZOOUWi0)| This DevDrops walks through how to activate the retry logic built into the Genesys Cloud Java SDK. |
|[Using caching to mitigate rate-limiting](https://youtu.be/ze3qFp5pGeA)| This DevDrop covers how to quickly setup caching within your Spring Boot application using the Caffeine caching library. | 

<br/><br/>


# Additional resiliency frameworks
If you are not developing your code using a JVM-based language there are still resiliency libraries specific to your application development language. Below is a non-exhaustive list of different resiliency frameworks.

|Language| Framework|Additional Notes |
|--------|----------|-----------------|
|.NET    | [Polly](https://github.com/App-vNext/Polly)| Full-fledged resilience library for .NET                |
|Golang  | [goresilience](https://github.com/slok/goresilience)| Implements most of the resiliency patterns uses in this starting guide          |
|Python  | [pybreaker](https://pypi.org/project/pybreaker/)|      Implements circuit breakers but not much else         |
|Node    | [Cocktiel](https://github.com/connor4312/cockatiel)|   Robust resiliency pattern library for Javascript              |
|Other   | [Envoy](https://www.envoyproxy.io/)        |     Alternative approach that uses a sidecar to implement resiliency patterns.  Language independent, but a more complex solution.            |
|Other   | [Istio](https://istio.io/)                 |   Alternative approach that uses a sidecar to implement resiliency patterns.  Runs well in a Kubernetes environment.  Highly complex, but extremely powerful.          |

<br/><br/>

# Additional Resources
I want to close this blog post with a few other resources related to resiliency patterns and the technologies we used in this blog post.
|||
|-|-|
|[Release IT!, 2nd Edition](https://www.amazon.com/Release-Design-Deploy-Production-Ready-Software-ebook/dp/B079YWMY2V/ref=sr_1_1?dchild=1&keywords=release+it%21&qid=1623272868&sr=8-1)| Michael Nygard's seminal book on building resiliency into your application. Any developer should have this book on their bookshelf.|
|[Spring Microservices in Action, 2nd Edition](https://www.amazon.com/Spring-Microservices-Action-Second-Carnell/dp/1617296953/ref=sr_1_4?crid=YKNIUOMJXEE8&dchild=1&keywords=spring+microservices+in+action&qid=1623273135&sprefix=Spring+Microserv%2Caps%2C155&sr=8-4) |A comprehensive guide to building microservices using Spring Boot and Spring Cloud. This book was written by the author of this blog post. | 
|[Spring Boot](https://spring.io/projects/spring-boot)| A full-featured JVM based framework for building scalable and robust Spring-based microservices.|
|[Caffeine Cache](https://github.com/ben-manes/caffeine)| A simple, but powerful framework for integrating caching into your Java-based applications.|
|[Resiliency 4J](https://github.com/resilience4j/resilience4j)| The de facto resiliency framework for Java-based applications.