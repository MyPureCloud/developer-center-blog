---
title: Go SDK Notification Service
date: 2021-12-03
tags: golang, developer engagement, notification service, sdk
author: michael.roddy
image: ./blog-img.png
category: 9
---

With the Genesys Cloud Notification Service, you can create a notifications channel, subscribe the channel to a topic (or multiple topics) and listen for notification events from Genesys Cloud by opeing a web socket connection to the notifications channel. You can subscribe the notifications channel to topics such as user topics, conversation topics, workforce management topics and many more. Today we are going to look at building a notification service with the Go SDK and in this example we will be using the Factory Pattern and the Command Pattern to process incoming requests. The Factory Pattern is a creational design pattern used to determine which objects to create without exposing the object creation logic to the client or user. In the notification service, we will be using the Factory pattern to determine which concrete command objects we want to instantiate based on the incoming notification message type. The Command Pattern, is a behavioural design pattern that is used to decouple the object that invokes an operation from the object that actually executes the operation, achieveing abstraction. Basically, the invoker of a command does not need to know about the object that actually executes the command, all of the information needed to do so is encapsulated in the object itself. And in part two of this blog post, we will look how you can modify the sequential notification service to process up to 10 incoming requests conncurrently by using Go routines and channels. So stay tuned!


## Getting Started

Before we write any code, you will need to install and configure the `Go` SDK. 

See the [Go SDK documentation](https://developer.genesys.cloud/api/rest/client-libraries/go/) for instructions on how to install and configure the SDK.

You can retrieve the package from [https://github.com/MyPureCloud/platform-client-sdk-go](https://github.com/MyPureCloud/platform-client-sdk-go) using `go get`.

```go
go get github.com/mypurecloud/platform-client-sdk-go/v57/platformclientv2
```

### Using The SDK

To use the SDK, you will need to import the package.

```go
import "github.com/mypurecloud/platform-client-sdk-go/v57/platformclientv2"
```

### Project Structure

This is the basic structure of the project. 

- We will be using packages to organise our code with seperate packages for the **command factory**, **command interface**, and **concrete command** logic. 

- Here you can see we have a notification service interface `./notification_service_interface/notification_service_interface.go`. We will be using an interface to define the methods that our notification service must implement.

```go
./golang-sdk-notification-service
	./command_factory
		command_factory.go
	./command_interface
		command_interface.go
	./concrete_command
		heartbeat.go
		routing_queues_id_users.go
		users_id_presence.go
	./notificatin_service_interface
		notification_service_interface.go
	./sequential_notification_service
		sequential_notification_service.go
	main.go
```

## The Notification Service Interface

Lets begin by writing the `notification_service_interface.go` file. 

- `Authenticate()` will take the default configuration instance. 

- `CreateChannel()` will take the notifications API instance and return two strings, the **channel ID** and the **connect URI**. 

- `SubscribeToTopic()` will take the notifications API instance and the channel ID. 

- `Listen()` will take the connect URI.

`./notification_service_interface/notification_service_interface.go`

```go
package notification_service_interface

import "github.com/mypurecloud/platform-client-sdk-go/v56/platformclientv2"

type NotificationService interface {
	Authenticate(config *platformclientv2.Configuration)
	CreateChannel(notificationsApi *platformclientv2.NotificationsApi) (string, string)
	SubscribeToTopic(notificationsApi *platformclientv2.NotificationsApi, channelId string)
	Listen(connectUri string)
}
```

Now that we have the notification service interface we can write the squential notification service and implement the interface methods.

## Sequential Notification Service

The sequential notification service will implement the methods from above and process incoming notifications one by one.

`./sequential_notification_service/sequential_notification_service.go`

To begin, lets create the notification service struct. Here you can see that the sequential notification service `struct` contains a `topics` variable of type `[]string`. The `topics` variable will hold our **topics**.

```go
type sequentialNotificationService struct {
	topics []string
}
```

Now lets write the constructor function that will be used to create an instance of the sequential notification service in our main function. The constructor function will be passed a slice of **topics** which will be assigned to the `topics` variable in the sequential notification service object.

```go
func NewSequentialNotificationService(topicList []string) *sequentialNotificationService {
	return &sequentialNotificationService{
		topics: topicList,
	}
}
```

Now that we have the sequential notification service `struct` and the constrcutor function, we can implement the interface methods and write the method logic.

### Authenticating

Lets implement `Authenticate()`. 

**Note:** In `Go`, interface methods are implemeted implicitly so there is no need to explicitly say that your file implements the interface like you might have seen in other language such as as Java.

Here you can see why `Authenticate()` takes the default configuration instance. It is used to call `AuthorizeClientCredentials()` and authorize our client application. The request will return one value `error`, if the request is not successful.

```go
func (sns *sequentialNotificationService) Authenticate(config *platformclientv2.Configuration) {
	fmt.Println("authenticating")
	err := config.AuthorizeClientCredentials(os.Getenv("GENESYSCLOUD_OAUTHCLIENT_ID"), os.Getenv("GENESYSCLOUD_OAUTHCLIENT_SECRET"))
	if err != nil {
		log.Fatalf("error authenticating: %v", err)
	}
}
```

### Creating The Channel

In `CreateChannel()` we are using the notifications API instance to call `PostNotificationsChannels()` which will go ahead and create a new channel for us. 

The request will return three values `*Channel`, `*APIResponse` and `error` but what we need from here is just the **connect URI** and the **channel ID** as these values will be used when subscribing to **topics** and opening the web socket connection.

```go
func (sns *sequentialNotificationService) CreateChannel(notificationsApi *platformclientv2.NotificationsApi) (string, string) {
	fmt.Println("creating the notifications channel")
	channel, _, err := notificationsApi.PostNotificationsChannels()
	if err != nil {
		log.Fatalf("error creating notifications channel: %v", err)
	}
	return *channel.Id, *channel.ConnectUri
}
```


### Subscribing To Topics.

Now that we have our channel, we can subscribe the channel to our **topics**. You can see the list of available topics on the [developer center](https://developer.genesys.cloud/api/rest/v2/notifications/available_topics).

Or to see the list of available topics in your Genesys Cloud organization, call `GET /api/v2/notifications/availabletopics`.

In `SubscribeToTopic()` you can see I have declared a variable `reqBody` of type `[]platformclientv2.Channeltopic`. `reqBody` is a slice that will hold the topic objects.

Then we loop over the slice of topics and append an object of type `platformclientv2.Channeltopic` (for each topic in the slice) onto the end of `reqbody`. Assigning the value of our topics to the `platformclientv2.Channel` objects `Id` attribute.

**Note:** That we are assigning the value of the topic by writing `&sns.topics[i]`, to the `platformclientv2.Channeltopic` object, using the index to acces this value and not just the value of the copy that is created in the `for` loop.

```go
func (sns *sequentialNotificationService) SubscribeToTopic(notificationsApi *platformclientv2.NotificationsApi, channelId string) {
	var reqBody []platformclientv2.Channeltopic
	for i, topic := range sns.topics {
		fmt.Println("subscribing to topic: " + topic)
		reqBody = append(reqBody, platformclientv2.Channeltopic{Id: &sns.topics[i], SelfUri: nil})
	}
	_, _, err := notificationsApi.PostNotificationsChannelSubscriptions(channelId, reqBody)
	if err != nil {
		log.Fatalf("error subscribing to topics: %v", err)
	}
}
```

For example, your topics slice might look like:

```go
const topic1 = "v2.routing.queues.a6ab52ba-d915-49f3-bf6e-b4f0567eac82.users"
const topic2 = "users.a6ab52ba-d915-49f3-bf6e-b4f0567eac82.presence"

topics := []string{
	topci1,
	topci2,
}
```

So `reqbody` would look like this after we finishing looping over the `topics` and appending the **topic** objects.

```go
reqBody := []platformclientv2.Channeltopic{
	{Id: &topic1, SelfUri: nil},
	{Id: &topic2, SelfUri: nil},
}
```

Then we call `PostNotificationsChannelSubscriptions()` and pass in the `reqbody` and the `channelId`. The request returns three values, `*Channeltopicentitylisting`, `*APIResponse` and `error`, but we only care about the error return value because if everything goes smoothly, our channel we will be subscribed to the topics, otherwise, we will log the error and exit the application.

### Listening For Notifications

To listen for notification events, we need to open a web socket connection to the notifcations channel. In this example we will be using **Gorilla WebSockets** which is *"A fast, well-tested and widely used WebSocket implementation for Go".* See the [Gorilla WebSockets documentation](https://github.com/gorilla/websocket) for more info.

you can install Gorilla WebSockets with:

```go
go get github.com/gorilla/websocket
```

To begin, lets create a channel of type `os.Signal`. The channel will be used to send `os.Signal` values  as we want to close our web socket connection and exit the program on `SIGINT` or `ctrl^C`. Take a look at the `for` loop at the bottom of the method. We will infinitely loop and use the `select` key word which blocks until one of its cases match and in our case it will be `SIGINT`. Then we will close the websocket connection, return and exit the application.

Now we can build the `URL`. In the example below, we are substringing the **connect URI** in three different places to extract out the **scheme**, **host** and **path**.

Then we can call `Defaultdialer.Dial()` and pass in the `URL` as a `string`. If all goes well, the request will return the web socket connection object.

```go
func (sns *sequentialNotificationService) Listen(connectUri string) {
	interrupt := make(chan os.Signal, 1)
	signal.Notify(interrupt, os.Interrupt)

	u := url.URL{Scheme: connectUri[0:3], Host: connectUri[6:31], Path: connectUri[32:]}

	connection, resp, err := websocket.DefaultDialer.Dial(u.String(), nil)
	if err != nil {
		log.Fatalf("handshake failed with status %v: error %v", resp.StatusCode, err)
	}
	fmt.Println("connected to server")

	// close the connection when function returns
	defer connection.Close()

	// process incoming messages with factory and command pattern
	go readMessages(connection)

	for  {
		select {
		case <-interrupt:
			// send close message to the server
			err := connection.WriteMessage(websocket.CloseMessage, websocket.FormatCloseMessage(websocket.CloseNormalClosure, ""))
			if err != nil {
				log.Printf("error closing connection: %v", err)
				return
			}
		}
	}

}
```

Next we will look at `readMessages()` which will handle reading messages from the web socket connection.

To keep the connection open we will use an infinite loop, continuously looping and reading messages from the web socket.

To read the messages we can call `connection.ReadMessage()`. 

`connection.ReadMessage()` returns three values, but we are only concered with the message instelf and the `error`.

The next step is optional, but here we are formatting the messages nicely as `JSON` with the **pretty** package. See the [pretty documentation](https://github.com/tidwall/pretty) for more info. And trimming new lines at the end of the `string`.


```go
func readMessages(connection *websocket.Conn) {
	for {
		_, message, err := connection.ReadMessage()
		if err != nil {
			log.Fatalf("error reading message: %v", err)
		}
		// format message
		prettyMsg := fmt.Sprintf("%s", pretty.Pretty(message))
		msg := strings.TrimSuffix(prettyMsg, "\n")
		messageType, err := getMessageType(msg)
		if err != nil {
			log.Fatalf("error getting message type: %v", err)
		}
		commandFactory := command_factory.NewCommandFactory()
		command, err := commandFactory.GetCommand(messageType, msg)
		if err != nil {
			log.Fatalf("error getting command: %v", err)
		}
		command.Execute()
	}
}
```

Then we can pass the message to the `getMessageType()` helper function which will return the type of the incoming message, i.e is it `users.{id}.presence` or `routing.queues.{id}.users` etc..

**Note:** The type of messages will depend on what topics you have subscribed to. In this case we have subscribed to `v2.routing.queues.{id}.users` and `v2.users.{id}.presence`. Also we have a case for `WebSocket Heartbeat` messages.

`getMessageType()` macthes the message `string` against three different patterns and returns the corresponding message type if the pattern macthes. If the pattern does not match, the `error` is returned.

```go
func getMessageType(message string) (string, error) {
	if match, _ := regexp.MatchString(`routing\.queues\.(.+)\.users`, message); match {
		return "routing.queues.{id}.users", nil
	}
	if match, _ := regexp.MatchString(`users\.(.+)\.presence`, message); match {
		return "users.{id}.presence", nil
	}
	if match, _ := regexp.MatchString(`WebSocket\sHeartbeat`, message); match {
		return "WebSocket Heartbeat", nil
	}
	return "", fmt.Errorf("%v", "message type not found")
}
```

Now we will create an instance of the **Command Factory** and call `commandFactory.GetCommand()` and pass in the message type and the message itself. The **Command Factory** will determine which **command** to create based on the message type.


```go
commandFactory := command_factory.NewCommandFactory()
command, err := commandFactory.GetCommand(messageType, msg)
if err != nil {
    log.Fatalf("error getting command: %v", err)
}
```

### The Run Method

Finally, lets write one more method in the sequential notification service. `RunSequentialNotificationService()`, which will call the methods that we defined above and will be called itself from the main function in our program.

```go
func (sns *sequentialNotificationService) RunSequentialNotificationService() {
	fmt.Println("=== running sequential notification service ===")
	config := platformclientv2.GetDefaultConfiguration()
	sns.Authenticate(config)
	notificationsApi := platformclientv2.NewNotificationsApi()
	channelId, connectUri := sns.CreateChannel(notificationsApi)
	sns.SubscribeToTopic(notificationsApi, channelId)
	sns.Listen(connectUri)
}
```

Now that we have the sequential notification service code written and we have seen how we will be using the **Factory Pattern** and the **Command pattern** in the notification service. Lets take a look at the code for the **Factory Pattern** and the **Command Pattern** in more detail.

## The Factory Pattern

The **Factory Pattern** is a creational design pattern used to determine which objects to create without exposing the object creation logic to the client or user. In the notification service, we are using the **Factory Pattern** to determine which **concrete command** objects we want to create based on the incoming message type.

Here you can see `GetCommand()` which returns a command depending on the message type. We are also passing the message to the command objects. The return value might look strange as we are returning the `command_interface.Command` type and not the actual object type itself, but a value can be of two different types. Because the **concrete command objects** implement the **command interface**, they are of type `command_interface.Command` and of their own object type as well.

```go
package command_factory

import (
	"fmt"
	"github.com/MyPureCloud/golang-sdk-notification-service.git/command_interface"
	"github.com/MyPureCloud/golang-sdk-notification-service.git/concrete_command"

)

type commandFactory struct {}

func NewCommandFactory() *commandFactory {
	return &commandFactory{}
}

func (cf *commandFactory) GetCommand(messageType string, message string) (command_interface.Command, error) {
	if messageType == "users.{id}.presence" {
		return concrete_command.NewUsersIdPresence(message), nil
	}
	if messageType == "routing.queues.{id}.users" {
		return concrete_command.NewRoutingQueuesIdUsers(message), nil
	}
	if messageType == "WebSocket Heartbeat" {
		return concrete_command.NewHeartbeat(message), nil
	}
	return nil, fmt.Errorf("%s", "command not found")
}

```

Now that we have seen the **Command Factory**, lets have a look at the **Command Pattern** and the **concrete commands**.

## The Command Pattern

The **Command Pattern**, is a behavioural design pattern that is used to decouple the object that invokes an operation from the object that actually executes the operation, achieveing abstraction. Basically, the invoker of a command does not need to know about the object that actually executes the command, all of the information needed to do so is encapsulated in the object itself.

As we saw earlier, the invoker `readMessages()` does not know anything about the the object that executes the command. we are only exposing what is necessary to the client and nothing more.

Lets take a look at code in more detail.

To begin with the **Command Pattern**, we need to create a **command interface** that defines a single method called `Execute()`.

`./command_interface/command_interface.go`

```go
package command_interface

type Command interface {
	Execute()
}
```

Next we need to create our **concrete commands** which will implement `Execute()`.

**Note**: As mentioned above, in `Go`, interface methods are implemeted implicitly so there is no need to explicitly say that your file implements the interface like you might have seen in other language such as as Java.

Here are three examples of **concrete commands** that will call `Execute()` and carry out the operation after being invoked by the client.

`./concrete_command/heartbeat.go`

```go
package concrete_command

import "fmt"

type heartbeat struct {
	message string
}

func NewHeartbeat(message string) *heartbeat {
	return &heartbeat{
		message: message,
	}
}

func (hb *heartbeat) Execute() {
	fmt.Println("calling heartbeat Execute()")
	fmt.Println(hb.message)
}
```

`./concrete_command/routing_queues_id_users.go`

```go
package concrete_command

import "fmt"

type routingQueuesIdUsers struct {
	message string
}

func NewRoutingQueuesIdUsers(message string) *routingQueuesIdUsers {
	return &routingQueuesIdUsers{
		message: message,
	}
}

func (rqiu *routingQueuesIdUsers) Execute() {
	fmt.Println("calling routing.queues.{id}.users Execute()")
	fmt.Println(rqiu.message)
}
```

`./concrete_command/users_id_presence.go`

```go
package concrete_command

import "fmt"

type usersIdPresence struct {
	message string
}

func NewUsersIdPresence(message string) *usersIdPresence {
	return &usersIdPresence{
		message: message,
	}
}

func (uip *usersIdPresence) Execute() {
	fmt.Println("calling users.{id}.presence Execute()")
	fmt.Println(uip.message)
}
```

These are the **commands** that we saw returned from `commandFactory.GetCommand()` which will in turn have their `Execute()` method called by the client.

Then we call `Execute()` on the command and print the messaage to the terminal.

```go
command.Execute()
```

## The Main function

Finally, lets take a look at the main function, the entry point of our notification service.

Here I have the topics I want to subscribe to set as environment variables on my system.

Then, we create a slice of type `string` and add our topics to the slice.

Next, we set a flag called `-ns` that will take the notification service that we want to run. Currently we just have the sequential notification service, but this flag will come in handy in my next blog post when we look at building a concurrent notification service so we can run either the sequential or the concurrent version.

```go
package main

import (
	"flag"
	"github.com/MyPureCloud/golang-sdk-notification-service.git/sequential_notification_service"
	"os"
)

func main() {
	topic1 := os.Getenv("USERS_ID_PRESENCE")
	topic2 := os.Getenv("ROUTING_QUEUES_ID_USERS")

	topics := []string{topic1, topic2}

	ns := flag.String("ns", "", "notification service: supported values: sequential")

	flag.Parse()

	if *ns == "" {
		flag.Usage()
	}

	if *ns == "sequential" {
		sns := sequential_notification_service.NewSequentialNotificationService(topics)
		sns.RunSequentialNotificationService()
	}
}
```

If **sequential** is passed to the `-ns` flag, we will create an instance of the sequential notification service and call `sns.RunSequentialNotificationService()`.

So to run the sequential notification service:

```go
go run main.go -ns sequential
```

## Final Thoughts

With the Genesys Cloud notification service you can view status updates on topics such as user status changes, incoming calls, converations, membership changes on queues and much more. To use the notification service, you need to create a channel, subscribe the channel to topics and open a web socket connection the notifications channel to listen for notification events from Genesys Cloud. Our SDKs make using the notification service painless and allow you to easily interface with the Genesys Cloud public APIs. In this blog post we covered how to use the notification service with the `Go` SDK and also implemented the Factory Pattern and the Command Pattern for processing incoming messages. I hope you found this blog post informative and stay tuned for part two where we will be modifying the sequential notification service code to process up to 10 incoming requests concurrently! Thanks for reading. If you have an issues or questions, please feel free to reach out to us on the [developer forum](https://developer.genesys.cloud/forum/).


## Additional Resources

1. [Go SDK Documentaion](https://developer.genesys.cloud/api/rest/client-libraries/go/). Instrcutions for using the Go SDK.
2. [Software Development Kits (SDKs)](https://developer.genesys.cloud/api/rest/client-libraries/). Our client libraries.
3. [The Genesys Cloud Notifications Service](https://developer.genesys.cloud/api/rest/v2/notifications/notification_service). Instrcutions for using the Notifications Service.
4. [Developer Forum](https://developer.genesys.cloud/forum/). Reach out to us on the Developer Forum