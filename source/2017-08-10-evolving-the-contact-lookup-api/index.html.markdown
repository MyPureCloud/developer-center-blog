---
title: Evolving the contact lookup API
date: 2017-08-10
tags: contacts
author: aaron.bickell@genesys.com
---

One of the most fundamental questions of any customer interactions is: "Which customer am I talking with?" In March of 2017, we released a revamped external contacts system geared toward answering that question. One of the most important APIs when dealing with external contacts is the contact lookup API, which identifies contacts by normalized phone numbers, email addresses, twitter handles, etc. This article will take you through the design and evolution of that API from its initial implementation to where it is today.

#### Our operating requirements

- **High volume**
  - This API can conceivably be accessed on every customer interaction

- **Consistent low latency**
  - In customer service, seconds count

- **Compliant**
  - PureCloud takes privacy and compliance very seriously, and this feature was no different

- **Eventual consistency is tolerable**
  - A few hundred milliseconds lag between a contact update and a them appearing in the lookups API is reasonable

---

## Version 1 - Elasticsearch

![Elasticsearch](Elasticsearch-Logo-Color-V.png)

At PureCloud, we're big fans of [Elasticsearch](https://www.elastic.co/) which powers everything from the company directory, to phone configuration, to our analytics platform. We have a lot of expertise managing, securing, tuning, and growing Elasicsearch clusters to handle billions of documents. And because the contacts microservice was already using Elasticsearch under the hood for its search features, it seems like a great place to start.

When a contact is created or updated, the record is synchronously stored in DynamoDB, which is our system of record, then asynchronously transformed and indexed in Elasticsearch. Elasticsearch has a very robust and easy to use query language that easily supports the kind of lookups we need. To simplify the interface, this API doesn't differentiate the source of the phone number (ie. are they calling from their home number or cell number) nor does it differentiate between email addresses or social channels. Any of these lookup values can be used to identify the customer involved in the interaction. The query as passed to Elasticsearch looks a bit like this:

~~~
boolFilterBuilder
    .should(FilterBuilders.termFilter("workPhone.e164.raw", lookupValue))
    .should(FilterBuilders.termFilter("cellPhone.e164.raw", lookupValue))
    .should(FilterBuilders.termFilter("homePhone.e164.raw", lookupValue))
    .should(FilterBuilders.termFilter("otherPhone.e164.raw", lookupValue))
    .should(FilterBuilders.termFilter("workEmail.raw", lookupValue))
    .should(FilterBuilders.termFilter("personalEmail.raw", lookupValue))
    .should(FilterBuilders.termFilter("otherEmail.raw", lookupValue))
    .should(FilterBuilders.termFilter("twitterId.screenName.raw", lookupValue));
~~~

That expression looks kinda gross, and as we add new identifiers (for other social channels as an example) won't age very well. When it comes down to it, Elasticsearch is really good at lots of things, but what separates it from other databases is how good it is at end-user searches. With builtin stemming, n-gramming, faceting, boosting, and support for synonyms, it is optimized around giving end-users scored results that make sense. Google has trained us to expect a lot out of search engines and Elasticsearch doesn't disappoint. That being said, the query above performs exact matches on simple string values, no more, no less and using Elasticsearch for this seems like a bit of an overkill. This API was going to receive heavy traffic, at least one call per interaction, possibly more. Ultimately, when we looked at our plans for scaling out the cluster, we determined that the highest traffic endpoints were ones that could be done just as well using something else. Having Elasticsearch satisfy this query was a waste of its resources. So..... lets try DynamoDB!

---

## A note about PureCloud architecture

PureCloud is platform composed of dozens of internal microservices behind a unifying public API.  This public API can execute scatter-gather API requests to the mid-tier microservices to compose the final results returned to the API client.  This approach gives us the flexibility to refactor, rework, split, combine mid-tier services in any way we want without changing the API contract presented to the caller.  All of the changes to mid-tier microservices in this article were 100% transparent to API clients.

---

## Version 2 - DynamoDB

![DynamoDB](DynamoDB-Amazon-Web-Services.png)

[DynamoDB](https://aws.amazon.com/dynamodb) provides consistent, sub 10ms performance at virtually any scale when searching by hash key, with no infrastructure to maintain. Dozens of microservices with PureCloud use DynamoDB. If we are big fans of Elasticsearch, we're superfans of DynamoDB. As mentioned above, we are already using DynamoDB as the contacts home of record, which begs the question:

**Question**: so... could we just add a Global Secondary Index (GSI) to our existing table?

**Answer**: no.

**Reason**: encryption.

As mentioned above, security, privacy, and compliance are very important to us, and to meet these needs, all contact data is encrypted in code as a big blob prior to being stored in DynamoDB. Doing this is great for security, but makes it impossible to create meaningful indexes on that contact data. Our solution was to create a second table that can be updated asynchronously, just like Elasticsearch, but geared toward high volume, key-based lookups. Just like any other contact data, we couldn't simply store the raw values as hash keys or range keys. Solution? Our old pal hashing.

If you have ever securely stored user passwords, you're familiar with hashing, it's a one-way cryptographic transformation of some data. In this case the we create a compound key of the identifier (phone number, email address, etc) and the organization id, apply the SHA-256 hashing algorithm and base64 encode the result. The resultant string is hash key for our table, with the range key being the entity id. At lookup time, the same hash algorithm is applied to the value being looked up, and voila, we have a nice O(1) cost to lookup our contact.

---

## Version 3 - Belt and suspenders

![With our powers combined](combined-logos.png)

Anybody can have a bad day, including DynamoDB, and in PureCloud we plan for them. With two proven implementations, why not fall back to the Elasticsearch version if DynamoDB isn't feeling well?  In practice, failures talking to DynamoDB are most frequently due to throttling when we exceed our provisioned throughput on a given table. PureCloud uses the open source project called [Dynamic DyanamoDB](https://dynamic-dynamodb.readthedocs.io) which monitors the consumed and provisioned capacity and automatically adjusts provisioning accordingly. This project has been a life saver (and a $$$ saver) by helping us keep high utilization on our tables and ensuring we have enough headroom for an increase in traffic. Increasing capacity however has a somewhat delayed reaction and can't react quickly to sudden spikes in traffic. This is where our Elasticsearch fallback comes into play.

In the case of sudden spike in traffic that exhausts our provisioned capacity, some of the requests to DynamoDB will fail. Using a project called [Hystrix](https://github.com/Netflix/Hystrix) created by [Netflix](https://github.com/Netflix), we can fail over traffic to Elasticsearch as a stop-gap while additional DynamoDB capacity is coming online. Hystrix is a fantastic project that provides bulk heading, circuit breakers, and retries for handling failures gracefully and predictably. PureCloud uses them extensively to fallback and recover, and limits the cascade of failures to other parts of the system.

---

## Future?

DynamoDB has had a few recent updates that are really interesting to us, namely [built-in autoscaling](https://aws.amazon.com/blogs/aws/auto-scale-dynamodb-with-dynamic-dynamodb/) and [DynamoDB Accelerator (DAX)](https://aws.amazon.com/dynamodb/dax/).  Both of these new features speak directly to our main concerns: scale and performance.  And best of all, they are entirely managed by AWS!

## Take aways

Evolving the contact lookup endpoint has been really instructive in several ways.

- **Properly insulating API consumers gives tons of flexibility**
    - Had the changes to the mid-tier required major changes for API consumers, we probably wouldn't have done them.  Putting a unifying layer between changes to backend services frees us to iterate much more quickly than we otherwise would be able.

- **Purpose built solutions tend to work better than general purpose ones**
  - Elasticsearch certainly has the feature set to satisfy the need, but isn't really what it was built for. Adding a purpose built solution designed around a particular access patterns and requirements gives a lot more flexibility now and in the future.

- **Security, privacy, and compliance make everything harder - so do it up front**
  - There is no way around it, if your product fails in the area of security, it won't be a product for very long. The final implementation required security considerations to be addressed up front and the success really hinged on us doing it correctly.

- **Graceful fallback requires work, but not as much as you might be afraid of**
  - Our situation was somewhat unique in that we could still return accurate results in the face of a failure, but there are often scenarios where there are options to return partial results, results from a stale cache or intelligent defaults rather than fail outright. Using a project like Hystrix provides a great framework for handling and recovering from failures.

I hope you have enjoyed this little peek behind the scenes to see how the sausage got made!
