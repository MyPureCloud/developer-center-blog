---
title: How the Analytics Conversation Details Query API Works
tags: Genesys Cloud, Developer Engagement, Analytics API
date: 2022-04-21
author: ebenezer.osei
category: 6
---

Greetings everyone! `POST /api/v2/analytics/conversations/details/query` is a useful API endpoint for viewing or monitoring conversations details in an organization. It offers the ability to query conversations extensively based on desired metrics. Due to the nature of conversation data, the endpoint's responses may seem to act unusual sometimes. In this article, I will describe the endpoint's irregular behavior and suggest ways you can make effective API calls.

For more information about the conversation details query endpoint, see the [conversations detail query](https://developer.genesys.cloud/analyticsdatamanagement/analytics/detail/conversation-query "Goes to the Conversation details query page") in the Genesys Cloud Developer Center.

If you have any feedback or questions, please reach out to us on the [Genesys Cloud developer forum](https://developer.genesys.cloud/forum/ "Goes to the Genesys Cloud developer forum") in the Genesys Cloud Developer Center.

## Apparent inconsistency of the Conversation Details Query endpoint
When querying the `POST /api/v2/analytics/conversations/details/query`, the totalHits counter reflects the approximate number of matching conversations for the given query body. If the interval covers a date span that contains data that's receiving new traffic from an organization, the totalHits counter can be a constantly changing value due to continuous data that is fed into the backend in real-time. Consequently, if paging through result sets for an interval is necessary, deduplication of the results could be required as the contents of early pages could arrive on a subsequent page pull due to the data set continually updating. Every API request reflects data the system is aware of when the request was made. When querying an interval receiving new information, the totalHits count and contents of particular pages will change along with that new data.

To receive data in real-time, we recommend using the [Notifications](https://developer.genesys.cloud/analyticsdatamanagement/analytics/notifications "Goes to the Notifications page") where applicable.

## Demonstration of API behavior
To demonstrate the behavior, I have a simple code snippet that calls the conversation detail query endpoint to collect the mean opinion score(MOS) of conversations from 10 minutes ago. [Mean Opinion Score (MOS)](https://developer.genesys.cloud/analyticsdatamanagement/analytics/detail/call-quality#mean-opinion-score--mos- "Goes to the Mean Opinion Score (MOS) page") is a measure of audio quality at a specific measurement point of voice interaction.

```go
func getMos() {
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

Listed is the result after running the code a couple of times.

![Before](before.png)

Above, you can see some differences between the initial total hits and the final ones.

Here is the result after making some changes to the query body.

![After](after.png)

Notice the total hits are smaller here. The processing time also was faster in this example. Check out how I improved the response in the next section.

Also, notice how there were duplicates in both cases. For example, a record included on the fourth page during a request may end up on the fifth page during subsequent requests, causing it to show up as a duplicate. That happens due to the indefinite update of the response on the server.

## Recommended practices to improve response consistency
- Make sure to include `conversationEnd` filter in your query if you want to avoid ongoing conversations.
- Avoid including the current time in the interval. For example, when querying for conversations from the past 30 minutes, make the interval `time.now()-30min/time.now()-1min`.

The main idea is to narrow the query request as much as possible. A specific query request results in a more consistent response and reduces processing time, especially if you have a huge dataset. For more performance tips, see [here](https://developer.genesys.cloud/analyticsdatamanagement/analytics/detail/#performance-tips "Goes to the Introduction page") in the Genesys Cloud Developer Center.

## Additional resources
- [Conversations Detail Query](https://developer.genesys.cloud/analyticsdatamanagement/analytics/detail/conversation-query "Goes to the Conversations Detail Query page") in the Genesys Cloud Developer Center.

- [Notifications](https://developer.genesys.cloud/analyticsdatamanagement/analytics/notifications "Goes to the Notifications page") in the Genesys Cloud Developer Center.

