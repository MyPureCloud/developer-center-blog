title: Introducing Genesys Cloud TF export in CX as Code
tags: Genesys Cloud, Developer Engagement, CX as Code
date: 2024-03-15
author: jenissa.barrera
category: 6
---

Greetings, everyone! The Developer Engagement team has been tirelessy working on improving CX as Code functionalities, recently the team have added significant amount of new functionality which is the developer export capabilities. With this feature, you can selectively export specific resources from your Genesys Cloud organization. 

Here are some reasons why individuals might utilize the export capabilities:

1. Export can be used to bring a non-terraform app into Terraform management.
2. It provides a means to back up a current configuration. This is extremely useful when you are about to do some kind of mass update via script and you need to have a mechanism to catch the data.
3. Exporting configuration to promote to another environment.

Let's explore how it works.


## Usage


1. The syntax for specifying resources is flexible. You can export all resources of a single type (e.g., users) or even filter resources by name using regular expressions.
2. In your Terraform configuration, you can specify which resources you want to export. For instance, if you’re interested in queues ending in “dev” or “test,” you can include them in your export.

```hcl

resource "genesyscloud_tf_export" "export" {
  directory = "./terraform"
  include_filter_resources = ["genesyscloud_user", "genesyscloud_routing_queue"]
  include_state_file       = true
  exclude_attributes       = ["genesyscloud_user.skills"]
}

```

The above configuration exports resources related to users and queues. The include_filter_resources parameter specifies the resource types and filters based on regular expressions. You can also choose to include the state file (include_state_file) and exclude specific attributes (exclude_attributes).

### Resource Filtering with Regular Expressions


In your Terraform configuration, you can use regular expressions to selectively include or exclude specific resources. Here’s how you can achieve this concisely:

#### Include Filter:

To include resources that start or end with “dev” or “test,” use the following syntax:

```hcl

resource "genesyscloud_tf_export" "include-filter" {
  directory = "./genesyscloud/include-filter"
  export_as_hcl = true
  log_permission_errors = true
  include_filter_resources = ["genesyscloud_group::.*(?:dev|test)$"]
}
```

In the above example, the include_filter_resources parameter specifies that we want to export resources of type “genesyscloud_group” where the name matches the regular expression .*(?:dev|test)$.

#### Exclude Filter:
If you want to exclude certain resources, you can use a similar approach:

```hcl
resource "genesyscloud_tf_export" "exclude-filter" {
  directory = "./genesyscloud/exclude-filter"
  export_as_hcl = true
  log_permission_errors = true
  exclude_filter_resources = ["genesyscloud_routing_queue"]
}

```

The exclude_filter_resources parameter ensures that resources of type “genesyscloud_routing_queue” are excluded from the export. In your Terraform configuration, you can use regular expressions to selectively include or exclude specific resources. 

Please take note that the resources include_filter and exclude_filter cannot be used simultaneously. They are mutually exclusive in the same export operation.


For both include and exclude filters, directory is where the config and state files will be exported. Defaults will go to ```./genesyscloud```

#### Supported Formats for Export:


When ```export_as_hcl ``` is set to ```true```,the export format will be HCL. Conversely, if this is set to ```false```, the format will be JSON. This setting allows you to control whether everything is exported as a single large file or divided into smaller files. 


#### Replace Data Source:

If you want to replace an exported resource as a data source. There are several scenarios that might necessitate this approach.

1. You have multiple Terraform projects each with their own backing state. You might need to look up a resource to reference in your project, but you don't want to export the reference object. Instead you want to convert it to a data source.

2. You need to reference an item in your export that you don't want to export but still need to reference.

 You may do so using this sample:

```hcl
resource "genesyscloud_tf_export" "export" {
  directory = "./genesyscloud/datasource"

  replace_with_datasource = [
    "genesyscloud_group::Test_Group"
  ]

  include_state_file     = true
  export_as_hcl          = true
  log_permission_errors  = true
  enable_dependency_resolution = false
}
```

Take note that in this code sample, genesyscloud_group refers to the exported resource ID.

#### Enable Dependency Resolution:

By default, Terraform exports only the dependencies explicitly listed in your configuration. For example, if you export a queue that references a skill, Terraform will include the queue but only reference the GUID of the dependent skill group.

To export additional dependencies automatically, set ```enable_dependency_resolution ``` to ```true```. When turned on, Terraform will export not only the queue but also the associated skill group.  Terraform also considers static dependencies associated with an architecture flow. These are exported automatically when ```enable_dependency_resolution ``` is active.  Sometimes you need to exclude specific fields from an export. For instance, if you want to omit division references, use the ```exclude_attributes``` option.


To export existing resources, you may refer to this [documentation](https://registry.terraform.io/providers/MyPureCloud/genesyscloud/latest/docs/guides/export)



Remember to experiment with different regular expressions to match your specific use case. Happy exporting!

# Additional Resources
1. [genesys_cloud_tf_export](https://registry.terraform.io/providers/MyPureCloud/genesyscloud/latest/docs/resources/tf_export#replace_with_datasource)