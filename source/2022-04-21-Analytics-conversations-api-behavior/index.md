---
title: How the Analytics Conversation Details Query API Works
tags: Genesys Cloud, Developer Engagement, Analytics API
date: 2022-04-21
author: ebenezer.osei
category: 6
---

Greetings everyone! The `/api/v2/analytics/conversations/details/query` is a useful api endpoint when you are trying to view or monitor conversations' details in your org. It offers the ability to query conversations extensively based on desired metrics. Due to the nature of conversations data, the conversations detail query works slightly different from a conventional rest endpoint. ​​In this article, I will describe the behavior of the endpoint and also suggest ways you can make effective api calls.

For more information about the conversation details query endpoint, checkout the [details query documentation](https://developer.genesys.cloud/analyticsdatamanagement/analytics/detail/) on the developer center.

## The Apparent Inconsistency of the Conversation Details Query Endpoint

With low volumes of conversations, the conversation query detail API seems to work fine as you get a consistent response. Say your query response is less than the api page limit, then you get exactly the data you are expecting. It is not the same case when you have a huge API response, for example, one that spans about 10 pages; you may see some inconsistency with the API response if that's the case. The first thing you may notice is the inconsistency of the `totalHits` value from the API response. The totalHits, as the name suggests, is the count of how many items that fits your query parameters. Normally, that figure should be consistent if you ran the API a couple of times with the same parameters but that is not the case sometimes. The totalHits is capable of changing even after a few seconds of an initial api request and it can keep on changing for some time depending on your query and the volume of data in your org. This is because after the initial request, the data keeps on updating on the backend. There are two things that cause that to happen, one is the conversation may still be going on or a new one just started. Secondly, thing, if the query covers a huge data set the processing time can be a bit long. The API doesnt wait till all the requested data is accumulated before sending a response but rather it gives you what it has collected so far and keeps on updating the data at the backend. This results in the change of `totalHits` overtime after the initial response. There is also the possibility of duplicate items because of the indefinite update of the conversations on the backend.

## Demonstration of API behavior

To give brief demonstration about the behavior, I have a simple code snippet that calls the conversation detail query endpoint to collect MOS scores of conversations within a certain interval. See below:

```golang
func getMosScore() {
	pageNumber := 1

	//Maximum number of records per page
	pageSize := 200

	currentTime := time.Now()

	//interval for past 10 minutes
	interval := fmt.Sprintf("%v/%v", currentTime.Add(time.Minute*-11).Format(time.RFC3339),currentTime.Add(time.Minute*-1).Format(time.RFC3339))


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

	log.Println("Initial total hits:", initialTotalHits)
	log.Println("Total hits:", len(collectedConversations))
	log.Println("Duplicates:", duplicates)
	log.Println("............................................")
}

```

Here is the response when I ran the code:

[Demo image goes here]

As you can see above, the `totalHits` changed after the initial totalhits. Also, there were a couple of duplicate items.

## Practices to improve consistent responses

- Make sure to include `conversationEnd` filter in your query. This ensures that the API does not try to include on-going conversations in the response.

- Avoid including the current time in the interval. For example, when querying for conversations from the past 30 minute, make the interval `time.now()-30min/time.now()-1min`.

- Try checking for duplicate items if you are consuming multiple pages like the example in the previous section.

## Resources

- [Query details documentation](https://developer.genesys.cloud/analyticsdatamanagement/analytics/detail/)

## Feedback

If you have any feedback or questions, please reach out to us on the [developer forum](/forum/).
