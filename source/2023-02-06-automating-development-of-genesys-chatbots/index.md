---
title: Automating development of Genesys chatbots
date: 2023-02-06
tags: automation, pipeline, terraform, testing
author: lucas.woodward
image: annotated-pipeline.png
category: 6
---

When developing chatbots at OVO we aim to reduce the feedback loop as much as possible, as a short feedback loop means we
can adapt to customer feedback more quickly. However, to ensure quality is maintained (even increased) we leverage
automation as much as possible. In this article, I'll explain the automation pipeline I've created that achieves this...

![Diagram of the pipeline annotated with technologies relevant to each step](annotated-pipeline.png)

The automated pipeline, known formally as a [CI/CD pipeline](https://en.wikipedia.org/wiki/CI/CD) is triggered against
every change and will:
1. Automatically deploy the bot and its dependencies to test environments
2. Run a suite of automated tests to assert the behaviour of the new functionality, and catch any regressions in existing functionality
3. Enforce that tests pass and changes are peer-reviewed before being able to progress
4. Once approved it automatically deploys changes to a User Acceptance Testing (UAT) environment
5. Notifies a QA Engineer to perform exploratory testing
6. Once approved by a QA Engineer then automatically deploy changes to production

The more obvious benefits of this are:
- Reducing the feedback loop from hours/days to seconds/minutes
- Deployments of chatbots and their dependencies that are identical across environments. If it works in UAT, it will work in Prod.
- Assurance of quality through automated tests. Every change, no matter how small is subjected to over 40 end-to-end tests - and since they are run concurrently they take less than 2 mins

## Implementation
Let's break down the pipeline and examine each part of it...

### Source-control
All the flows, chatbots, dependencies, tests, and even the definition of the pipeline itself live in
source-control - which for OVO is [GitHub](https://github.com/). This git repository forms the source of truth.

When an update or revert occurs against anything in the repository then it is tracked (by virtue of it being
in source-control) and the automated pipeline is triggered. Only when all the pipeline's checks pass will the change
make its way to production.

### Pipeline
![Diagram of pipeline, from deploying to dev, testing to deploying to production](pipeline-overview.png)

The pipeline is defined in the human-readable language YAML and is executed by CircleCI. It defines what each step
does and the order they do it.

```yaml
# Job definitions redacted

workflows:
  development:
    jobs:
      - terraform-autoapply-dev:
          filters: *ignore-main-branch
          context:
            - aws-dev
            - genesys-dev
      - test-web-messaging:
          filters: *ignore-main-branch
          requires:
            - terraform-autoapply-dev
      - test-ivr-flow:
          filters: *ignore-main-branch
          requires:
            - terraform-autoapply-dev
  main:
    jobs:
      - terraform-autoapply-uat:
          filters: *only-main-branch
          context:
            - aws-uat
            - genesys-uat
      - manual-testing:
          type: approval
          requires:
            - terraform-autoapply-uat
      - terraform-apply-prod:
          filters: *only-main-branch
          context:
            - aws-prod
            - genesys-prod
          requires:
            - manual-testing
```

### Deploy using Terraform
![Pipeline with Terraform tasks highlighted](pipeline-terraform.png)

[Terraform](https://www.terraform.io/) offers a way to declaratively define resources that you want it to deploy. This
way you know that the deployments will always match what is in source-control.

Since many [providers support Terraform](https://registry.terraform.io/browse/providers) we can define everything in
one place; from chatbots, flows, data-actions to their backend services. Here's an example of a Terraform definition:

```terraform
resource "genesyscloud_integration_action" "create_survery_data_action" {
  # Prevent any change that creates a new UUID
  lifecycle {
    prevent_destroy = true
  }
  name           = "Create Survey (created via Terraform)"
  category       = "Web Services Data Actions"
  integration_id = var.integration_id
  secure         = false
  config_request {
    // ...
  }
  config_response {
    // ...
  }
  contract_input = <<DEFINITION
        // ...
        DEFINITION
  contract_output = <<DEFINITION
        // ...
        DEFINITION
}

resource "genesyscloud_flow" "flow" {
  filepath          = var.flow_file
  file_content_hash = filesha256(var.flow_file)

  substitutions = {
    flow_name     = "${var.flow_name} - (created via Terraform)"
    flow_division = var.flow_division
    data_action_name = genesyscloud_integration_action.create_survery_data_action.name
  }
}

data "genesyscloud_webdeployments_configuration" "config" {
  name = var.web_deployments_configuration
}

resource "genesyscloud_webdeployments_deployment" "survey_deployment" {
  name              = "Survey - (created via Terraform)"
  flow_id           = genesyscloud_flow.flow.id
  allow_all_domains = true

  configuration {
    id      = data.genesyscloud_webdeployments_configuration.config.id
    version = data.genesyscloud_webdeployments_configuration.config.version
  }
}
```

### Automated testing
![Pipeline with automated testing tasks highlighted](pipeline-testing.png)

The tools we use at OVO to automate the testing of chatbots are written by me, and as such are open-source:
- [Web Messenger Tester](https://github.com/ovotech/genesys-web-messaging-tester) for testing Inbound Message flows via a Web Messenger Deployment
    - Since the WhatsApp integration uses Incoming Message Flows it means we can also test WhatsApp-specific chatbots with this tool
- [IVR Tester](https://github.com/SketchingDev/ivr-tester) for testing IVR flows
    - This can test our IVR-based chatbots flows by impersonating a customer calling OVO, interpreting what it hears, and responding accordingly to traverse the journey. Any unexpected response is flagged

Both tools define their tests in files that can be stored alongside the chatbots in source-control and act as living documentation:
```yaml
scenarios:
  "Customer asked to score experience if they say yes":
    - say: Thank you, bye
    - waitForReplyContaining: Before you go could you answer a quick survey?
    - say: yes
    - waitForReplyContaining: Overall, how satisfied or dissatisfied are you with our company?
    - say: "10"
    - waitForReplyContaining: We thank you for your time spent taking this survey. Your response has been recorded.
  "Conversation ended if they say no":
    - say: Thank you, bye
    - waitForReplyContaining: Before you go could you answer a quick survey?
    - say: no
    - waitForReplyContaining: We hope you have a nice day, goodbye
```

## Conclusion

This has been a whistle-stop tour of the pipeline and the benefits it brought us. Hopefully, it has provided enough
information for you to get started with your own pipelines.

If you have any questions, or would like to share your implementation then I'd love to hear from you
[@SketchingDev](https://twitter.com/SketchingDev).
