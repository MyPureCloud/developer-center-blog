---
title: Disconnecting Queued Interactions
tags: routing
date: 2018-02-07
author: kevin.glinski@genesys.com
---

This week we ran some stress tests in our testing environment with the goal to try and break the system to test how well we would recover. During one portion we were all allowed to hit the public API as hard as we could to try and get something to break. I decided to throw what I could at our ACD and conversation services by creating 50k [3rd Party Chats](/api/rest/v2/conversations/third-party-object-routing.html) as fast as I could. To my disappointment the system handled the load fine, but since I was borrowing an org to do my testing I now had to cleanup my mess.

 There isn't a way to select all interactions in a queue and disconnect them all at once, so I had to create a new script to do it. These details may come in handy if you find yourself with a ton of email spam in you queue or are routing your own 3rd party emails or chats and accidentally create too many.

 To start, we need to find which conversations we have in queue, so we'll construct a query which will have predicates that find conversations with a segment type of interact and don't have a segment or conversation end and POST this query to ```/api/v2/analytics/conversations/details/query```.


```{"language":"json"}
{
  "paging": {
    "pageSize": 100,
    "pageNumber": 1
  },
  "order": "desc",
  "segmentFilters": [
    {
      "type": "and",
      "predicates": [
        {
          "type": "dimension",
          "dimension": "segmentType",
          "operator": "matches",
          "value": "interact"
        },
        {
          "type": "dimension",
          "dimension": "queueId",
          "operator": "matches",
          "value": "9bfb36aa-cde3-4706-9744-70f0645754cf"
        },
        {
          "type": "dimension",
          "dimension": "segmentEnd",
          "operator": "notExists"
        }
      ]
    }
  ],
  "conversationFilters": [
    {
      "type": "and",
      "predicates": [
        {
          "type": "dimension",
          "dimension": "conversationEnd",
          "operator": "notExists"
        }
      ]
    }
  ],
  "interval": "2018-01-07T19:42:31.141Z/2018-02-06T19:42:31.141Z"
}
```


You could get all conversations at once, but in my case I decided to just get the first page, disconnect those conversations and then repeat and get the first page of conversations again. My goal was to disconnect all conversations at the queue, but you may want to selectively disconnect so you may need to add additional filters or post query logic.

Once I have a page of conversations I can then start disconnecting them. Do to this, I'll post the following to ```/api/v2/conversations/chats/{conversationid}```

```{"language":"json"}
{
    "state": "disconnected"
}
```

Here is my full function, it is written in [GO](https://golang.org/) and the function takes a http client that is already authenticated to PureCloud. GO has GO routines built in to handle concurrent operations, so after I get a pages of conversations, I concurrently disconnect them all at once and then wait for those requests to return before getting the next page.

```
type ConversationsResponse struct {
	Conversations []struct {
		ConversationID string `json:"conversationId"`
	} `json:"conversations"`
}

func disconnectConversations(queueId string, apiClient *http.Client) {
	for true {
		query := "{\"paging\":{\"pageSize\":100,\"pageNumber\":1},\"order\":\"desc\",\"segmentFilters\":[{\"type\":\"and\",\"predicates\":[{\"type\":\"dimension\",\"dimension\":\"segmentType\",\"operator\":\"matches\",\"value\":\"interact\"},{\"type\":\"dimension\",\"dimension\":\"queueId\",\"operator\":\"matches\",\"value\":\"" + queueId + "\"},{\"type\":\"dimension\",\"dimension\":\"segmentEnd\",\"operator\":\"notExists\"}]}],\"conversationFilters\":[{\"type\":\"and\",\"predicates\":[{\"type\":\"dimension\",\"dimension\":\"conversationEnd\",\"operator\":\"notExists\"}]}],\"interval\":\"2018-01-07T19:42:31.141Z/2018-02-06T19:42:31.141Z\"}"

		response, _ := apiClient.Post(ApiRoot+"/api/v2/analytics/conversations/details/query",
                                        "application/json",
                                        bytes.NewBuffer([]byte(query)))

		entities := &ConversationsResponse{}
		dec := json.NewDecoder(response.Body)
		dec.Decode(entities)

		if len(entities.Conversations) == 0 {
			return
		}

		wg := &sync.WaitGroup{}

		for _, conversation := range entities.Conversations {
			wg.Add(1)
			go func(id string) { //start a new goroutine
				disconnect := "{\"state\": \"disconnected\"}"
				request, err := http.NewRequest("PATCH",
                                            ApiRoot+"/api/v2/conversations/chats/"+id,
                                            bytes.NewBuffer([]byte(disconnect)))

				request.Header.Set("content-type", "application/json")
				deleteresponse, err := apiClient.Do(request)

				if err != nil {
					log.Panicf("can't disconnect %v", err)
				} else if deleteresponse.StatusCode == 429 {
					log.Print("SLEEPING")
					time.Sleep(45 * time.Second)
				} else if deleteresponse.StatusCode != 200 {
					log.Printf("Got unexpected response %v", deleteresponse.StatusCode)
				}
				wg.Done()
			}(conversation.ConversationID)
		}

		wg.Wait() // wait for all the disconnects to finish then get the next page
	}
}
```
