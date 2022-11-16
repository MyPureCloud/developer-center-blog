---
title: Introduction to the Genesys Cloud Skill Expression Groups
tags: Genesys Cloud, Developer Engagement, Skill Expression Groups, Routing, CX as Code, CLI
author: john.carnell
category: 6
---

Greetings everyone! The end of the year is fast approaching and before we know it, 2023 will be upon us. This month I want to introduce a new feature in Genesys Cloud called Skill Expression Groups. Traditionally, Genesys Cloud has only allowed you to define queue membership statically. Before the Skill Expression Group feature, queue membership was done by either assigning an agent directly to the queue or assigning the agent to a group that was assigned to the queue. Both of these mechanisms required constant administration from a Genesys Cloud Administrator if queue membership changed on a regular basis.

Skill Expression Groups allow a Genesys Cloud administrator to define group membership for a queue based on a set of "and/or/not" conditional statements. The conditional statements all focus on what skills/languages and levels an agent possesses. As new agents are added to the platform or an existing agent's skills change, they will be automatically be added or removed from a group. Skill Expression Groups offer the ability to build powerful and deep rules for determining what agents in your organization belong to a queue. 

This blog post is not going to show you how to configure the Skill Expression Group via the Genesys Cloud UI. Instead, this article is going to focus on:

1. The Skill Expression Group APIs and their corresponding API commands 
2. Understanding how divisions work with Skill Expression Groups
3. Using CX as Code to configure a Skill Expression Group

:::primary
If you are interested in learning more about Genesys Cloud Groups (including the Skill Expression Group) please see the [Groups Overview](https://help.mypurecloud.com/articles/groups-overview/) on our [Genesys Cloud Resource Center](https://help.mypurecloud.com/). The [Groups Overview](https://help.mypurecloud.com/articles/groups-overview/)page also documents some important limitations you need to understand if you are building large Skill Expression Groups.
:::

## The Skill Expression Group APIs
All of the Skill Expression Group APIs can be found under the [Routing and Conversation Handling](/routing/) section of the Genesys Cloud Developer Center. The Skill Expression Group feature has 8 APIs broken into **five** categories:

1. Retrieving all Skill Expression Groups
2. Creating a Skill Expression Group
3. Updating and deleting a Skill Expression Group
4. Reading what agents are part of a Skill Expression Group
5. Divisions and Skill Expression Groups

### Retrieving all Skill Expression Groups
There is a single API for returning all of the Skill Expression Groups currently defined in your organization. This API is shown below:

<dxui:OpenAPIExplorer verb="get" path="/api/v2/routing/skillgroups"/>

Remember this API is paginated so if you have more than 25 skill groups defined, you will need to call this API endpoint for the page of data returned.

You can also use the Genesys Cloud CLI to retrieve all of the skill groups by using the following Genesys Cloud CLI:

``` 
gc routing skillgroups list -a
```

This will return a list of all of the returned Skill Expression Groups. We return all of the Skill Expression Groups (not just a page) because we are using the `-a` option. However, if you take a close look at the results, you will see that the conditions (e.g. the rules) associated with the Skill Expression Group are not returned by the API or the CLI. In order to see the conditions for a Skill Expression Group you must retrieve a specific Skill Expression Group by its `id`. To retrieve a single skill group you can use the following API:

<dxui:OpenAPIExplorer verb="get" path="/api/v2/routing/skillgroups/{skillGroupId}"/>

The corresponding Genesys Cloud CLI command is shown below:

```
gc routing skillgroups get {id}
```

If you are using **CX as Code** you can also retrieve the id of a Skill Expression Group by using the CX as Code data source [genesyscloud_routing_skill_group](https://registry.terraform.io/providers/MyPureCloud/genesyscloud/latest/docs/data-sources/routing_skill_group).  An example of this data source in action is shown below:

```
data "genesyscloud_routing_skill_group" "skill_group" {
  name = "MyDynamicGroup"
}
```

### Creating a Skill Expression Group
To create a Skill Expression Group you can use the following API:

<dxui:OpenAPIExplorer verb="post" path="/api/v2/routing/skillgroups/{skillGroupId}" source="https://api.mypurecloud.com/api/v2/docs/swagger"/>

Let's use the API above to define a Skill Expression Group where we want to capture all agents with `Series 6` skills greater than 2 and who have a language skill of `Spanish` greater than 3. To create this skill group using the Genesys Cloud API shown above you need to define a POST body that looks like this:

```
{
  "name": "Series6andSpanish",
  "description": "Capture all agents with a series 6>2 and a language skill of spanish>3",
  "skillConditions": [
    {
      "routingSkillConditions": [
        {
          "routingSkill": "Series 6",
          "comparator": "GreaterThan",
          "proficiency": 2
        }
      ],
      "languageSkillConditions": [],
      "operation": "And"
    },
    {
      "routingSkillConditions": [],
      "languageSkillConditions": [
        {
          "languageSkill": "Spanish",
          "comparator": "GreaterThan",
          "proficiency": 3
        }
      ],
      "operation": "And"
    }
  ]
}
```

Notice in the above body, there is a difference between `routingSkillConditions` and `languageSkillConditions`.  The `routingSkillConditions` capture skill expressions and `languageSkillConditions` capture language expressions.  In addition, notice the `operation` keyword where you can define `AND`, `OR`, and `NOT` conditions.


:::{"alert":"primary","title":"Pro-tip","autoCollapse":false}
Skill Expression Groups can allow for multiple levels of nesting and conditionals. Trying to build these definitions out by hand is not recommended as it leads to hours of frustration and eventually a life of unhappiness. I highly recommend that you use the Genesys Cloud Admin UI to model out your Skill Expression Group and then use the Skill Expression Group API or the Genesys Cloud CLI to pull the JSON version of Skill Expression Group and then use it for your API invocation (or CX as Code definitions).
:::

If you want to define a Skill Expression Group using CX as Code, you would use [genesys_cloud_skill_group resource](https://registry.terraform.io/providers/MyPureCloud/genesyscloud/latest/docs/resources/routing_skill_group). Below is an example of creating our series 6 and Spanish Skill Expression Group:

```
resource "genesyscloud_routing_skill_group" "skillgroup" {
  name        = "Series6andSpanish"
  description = "Capture all agents with a series 6>2 and a language skill of spanish>3"
  skill_conditions = jsonencode(
    [
      {
        "routingSkillConditions": [
          {
            "routingSkill": "Series 6",
            "comparator": "GreaterThan",
            "proficiency": 2
          }
        ],
        "languageSkillConditions": [],
        "operation": "And"
      },
      {
        "routingSkillConditions": [],
        "languageSkillConditions": [
          {
            "languageSkill": "Spanish",
            "comparator": "GreaterThan",
            "proficiency": 3
          }
        ],
        "operation": "And"
      }
  ])
}
```

:::{"alert":"primary","title":"What's with the jsonencode","autoCollapse":false}
Eagle-eyed readers will notice in the above CX as Code definition that the `skill_conditions` attribute uses a `jsencode` function around the definition of Skill Conditions. Building a complex and recursive structure into the Genesys Cloud CX as Code provider proved to be extremely difficult. Since a change in skill conditions would trigger an entire update of the body, the CX as Code development team chose to just encode the `skill_conditions` in its native JSON format.        
:::

### Updating and deleting a skill expression group
The Skill Expression Group API does not have a PUT endpoint for updating the Skill Expression Group. Instead, it has a PATCH endpoint. Remember, that a PATCH endpoint allows you to submit only the attributes that have changed instead of the entire JSON body for the record. The PATCH endpoint can be seen here:

<dxui:OpenAPIExplorer verb="PATCH" path="/api/v2/routing/skillgroups/{skillGroupId}"/>

To update a Skill Expression Group using the CLI the command you would use would be:

```
gc routing skillgroups update {skillGroupId} --file "FILE CONTAINING THE JSON BODY"
```

To delete a Skill Expression Group you can use the DELETE endpoint:

<dxui:OpenAPIExplorer verb="DELETE" path="/api/v2/routing/skillgroups/{skillGroupId}"/>

To use the CLI you would issue the following command: 

```
gc routing skillgroups delete {skillGroupId}
```

### Reading what agents are part of a skill group
Once you have defined the Skill Expression Group, you can see what agents are part of the Skill Expression Group by issuing the following API call:

<dxui:OpenAPIExplorer verb="GET" path="/api/v2/routing/skillgroups/{skillGroupId}/members"/>

The corresponding CLI command is:

`gc routing skillgroups members list {skillGroupId} -a`

### Divisions and Skill Expression Group
Genesys Cloud divisions are often one of the most understood capabilities within the platform. Most people think divisions are mechanisms for segmenting your Genesys Cloud organization so that you can cleanly delineate and group various Genesys Cloud assets into groups that can only be accessed by members of that division. A Genesys Cloud division is really a filtering mechanism. When a division is applied to a Genesys Cloud asset (e.g. a Queue, Flow, etc..), it means that a resource is only "visible" to members of that division. However, it should be not thought of as an access control mechanism. It is used in coordination with the Genesys Cloud roles permissions. 

Here are a few additional things to keep in mind about Genesys Cloud divisions:

1. Every Genesys Cloud organization has a default organization. That division is called the Home division.
2. Every "division-aware" asset in Genesys Cloud will be assigned to the division of the user creating it.  
3. An asset in Genesys Cloud can be assigned to one and only one division at a time.
4. A role can be assigned to multiple divisions and any user assigned that role can see assets in any division defined in the role. However, a user that is assigned that role can still only be assigned to one division.

One of the most common questions I am asked about Skill Expression Groups is: How can I make agents from multiple divisions visible to that Skill Expression Group? For example, I might want to have agents who have a series 7 stockbroker license from multiple divisions available to take customer calls. Skill Expression Groups allow you to do this via the UI, the Skill Expression Group APIs, and CX as Code. To add or remove divisions that are visible to the Skill Expression Group, you can use the following API:

<dxui:OpenAPIExplorer verb="POST" path="/api/v2/routing/skillgroups/{skillGroupId}/members/divisions"/>

If you want to manage Skill Expression Group visibility using CX as Code you can set the `member_division_ids` attribute on the `genesys_cloud_skill_groups` resource.  This optional attribute accepts a list of `division_ids` that will be made visible to Skill Expression Group.

To see the divisions made visible to the Skill Expression Group you can use the following API:

<dxui:OpenAPIExplorer verb="GET" path="/api/v2/routing/skillgroups/{skillGroupId}/members/divisions"/>

## Final Thoughts
That's it!  The new Genesys Cloud Skill Expression Group capability is a welcome edition because it shifts managing Genesys Cloud groups statically to dynamically. However, it does add a layer of complexity if you want to manage the Skill Expression Group pragmatically via the API or declaratively via CX as Code. Remember, trying to write the conditional rules by hand is painful. Use the UI to model the rule and then capture the rule's JSON using the CLI or API.  Also, remember that Skill Expression Groups can pull members across multiple divisions

## Additional Resources
1. [Skill Expression Group - Resource Center](https://help.mypurecloud.com/articles/groups-overview/)
2. [Skill Expression Group API Code](/routing/routing/). This is part of the routing API, so filter on the keyword skillgroup if you want to just see these APIs.
3. [Skill Expression Group Terraform Resource](https://registry.terraform.io/providers/MyPureCloud/genesyscloud/latest/docs/resources/routing_skill_group)
4. [Genesys Cloud Resource Center](https://help.mypurecloud.com/)
5. [Genesys Cloud Developer Center](https://developer.genesys.cloud/)
6. [CX as Code](https://developer.genesys.cloud/devapps/cx-as-code/)
