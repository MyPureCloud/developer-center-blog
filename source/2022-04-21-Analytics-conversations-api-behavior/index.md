---
title: How the Analytics Conversation Details Query API Works
tags: Genesys Cloud, Developer Engagement, Analytics API
date: 2022-04-21
author: ebenezer.osei
category: 6
---

Greetings everyone! The `/api/v2/analytics/conversations/details/query` is a useful API endpoint for viewing or monitoring conversations' details in your org. It offers the ability to query conversations extensively based on desired metrics. Due to the nature of conversations' data, the endpoint's responses may look unusual. ​​In this article, I will describe the irregular behavior of the endpoint and also suggest ways you can make effective API calls.

For more information about the conversation details query endpoint, checkout the [details query documentation](https://developer.genesys.cloud/analyticsdatamanagement/analytics/detail/) on the developer center.

## The Apparent Inconsistency of the Conversation Details Query Endpoint

With a low volume of conversations or a small query span, the conversation query detail API seems to work fine as you get consistent responses. It is not the same case when you have a lot of conversations going on in your org or when you are trying to query for recent conversations. The first thing you may notice is the inconsistency of the `totalHits` value from the API response. The totalHits, as the name suggests, is the count of items that fit your query parameters. Normally, that figure should be consistent if you ran the API a couple of times with the same parameters but that is not the case sometimes. The totalHits is capable of changing even after a few microseconds of an initial API request and it can keep on changing for some time depending on your query and the intensity of activities going on in your org.
There are two things that influence this behavior: Firstly, The API doesn't wait till all the requested data is accumulated before sending a response rather, it gives you what it has collected so far and keeps on updating the data at the backend. This results in the change of `totalHits` over time after the initial response. Secondly conversations may still be going on or a new one may be initiated during the processing of the query and that may cause inconsistent responses especially if your interval is recent. There is also the possibility of duplicate items because of the indefinite update of the conversations on the backend.

## Demonstration of API behavior

To give a brief demonstration about the behavior, I have a simple code snippet that calls the conversation detail query endpoint to collect MOS scores of conversations from 10 minutes ago. See below:

```golang
func getMosScore() {
	pageNumber := 1

	//Maximum number of records per page
	pageSize := 200

	currentTime := time.Now()

	//interval for past 10 minutes
	interval := fmt.Sprintf("%v/%v", currentTime.Add(time.Minute*-10).Format(time.RFC3339),currentTime.Format(time.RFC3339))


	queryBody := platformclientv2.Conversationquery{
		Interval: &interval,
		ConversationFilters: &[]platformclientv2.Conversationdetailqueryfilter{
			{
				VarType: platformclientv2.String("and"),
				Predicates: &[]platformclientv2.Conversationdetailquerypredicate{
					{
						Dimension: platformclientv2.String("mediaStatsMinConversationMos"),
						Operator:  platformclientv2.String("exists"),
					},
				},
			},
		},
		Paging: &platformclientv2.Pagingspec{
			PageSize:   &pageSize,
			PageNumber: &pageNumber,
		},
	}

	//Api call to get initial totalHits
	conversations, _, err := analyticsApi.PostAnalyticsConversationsDetailsQuery(queryBody)

	if err != nil {
		log.Println(err)
		return
	}

	duplicates := 0

	initialTotalHits := *conversations.TotalHits

	//To check for duplicates
	collectedConversations := make(map[string]float64)

	for {
		api_response, _, err := analyticsApi.PostAnalyticsConversationsDetailsQuery(queryBody)

		if err != nil {
			log.Println(err)
			return
		}

		if api_response.Conversations == nil {
			break
		}

		for _, v := range *api_response.Conversations {

			conversationMosScore := *v.MediaStatsMinConversationMos

			_, exists := collectedConversations[*v.ConversationId]

			if !exists {
				collectedConversations[*v.ConversationId] = conversationMosScore
			} else {
				duplicates++
			}
		}

		pageNumber++
	}

	fmt.Println("Initial total hits:", initialTotalHits)
	fmt.Println("Final total hits:", len(collectedConversations))
	fmt.Println("Difference:", len(collectedConversations)-initialTotalHits, "more records")
	fmt.Println("Duplicates:", duplicates)
	fmt.Println("............................................")
}

```

Here is the result after runnning the code above a couple of times:

![Before](before.png)

As you can see above, there is quite some difference between the initial total hits and the final one. This is because the API doesn't wait until all the data has been gathered before sending out a response but sends out what it has so far and keeps on updating on the backend until it's done.

Here is the result after making some changes to query body:

![After](after.png)

Notice how the difference between the total hits is smaller here. The processing time also was faster in this example. Check out how I improved the response in the next section.

Also, notice how there were duplicates in both cases. That happens due to the indefinite update of the response on the server. For example, a record is included on the 4th page during a request but may end up on the fifth page during subsequent requests hence causing it to show up as a duplicate. This mostly happens when making requests for a recent interval like I did my example.

## Recommended Practices to Improve Response Consistency

- Make sure to include `conversationEnd` filter in your query. This ensures that the API does not try to include on-going conversations in the response.

- Avoid including the current time in the interval. For example, when querying for conversations from the past 30 minute, make the interval `time.now()-30min/time.now()-1min`.

- Try checking for duplicate items if your query interval is recent. You can utilize an array or a set like I did or skip the `/api/v2/analytics/conversations/details/query` endpoint altogether and utilize the [Notification Service](https://developer.genesys.cloud/notificationsalerts/notifications/available-topics) by directly consuming data from a topic if you are looking for very recent conversations.

The main idea here is to narrow down the query request as much as possible. A specific query request results in a more consistent response and also reduces the processing time especially if you have a huge dataset.

## Resources

- [Query details documentation](https://developer.genesys.cloud/analyticsdatamanagement/analytics/detail/)

## Feedback

If you have any feedback or questions, please reach out to us on the [developer forum](/forum/).
