---
title: How Generative AI is used in Genesys Agent Assist
tags: ai, generativeAI
date: 2023-05-08
author: ram.sundaram
category: 0
---

## Introduction

Generative AI is used in Genesys Agent Assist to automatically summarize conversations between customers and agents. The service processes the entire conversation in near real time as part of the agent After Call Work (ACW). The first version supports English only, additional languages are being considered. This service is the first Generative AI component built by the Genesys Cloud team. This [article](https://help.mypurecloud.com/articles/create-a-conversation-summary-with-genesys-agent-assist/) describes how Generative AI is used in Agent Assist to create an automatic conversation summary.

## Modeling Approach

As we all know, since 2019, Transformers based approaches (such as OpenAI's GPT, GPT-3 and now GPT-4) have taken the NLP world by storm. GPT-3 was built to handle back and forth conversations and cover a wide range of applications – writing blogs, emails, songs, and more. By putting a UI on top of GPT-3, OpenAI brought the power of Generative AI to the masses.

At a high level, Transformer architecture typically consists of an encoder and decoder. Encoder encodes the input text to a vector representation and can be considered an array of floating-point numbers. The decoder consumes these vectors to generate text again. Hence the name, Transformer, as we transform the input text to an output text for various purposes.

This image shows how this Transformer architecture is applied to a translation use case:
![Translation via LLM](translate.png "Translation via LLM")

Typicaly, only the encoder is used in NLP applications like text classification, sentiment analysis, and question answering. In those applications, there is no need to formulate a response through the model. The response is based on the output of the encoder with additional layers as output. For applications that produce alternative text, both the encoder and decoder are used. The class of models used for summarization are called **Seq2SeqLM** models, since the input and the output are both text. There are transformer models where the input is text, and the output is an image.

The Genesys Agent Assist's Generative AI service uses Seq2Seq modeling adapted and customized based on an open-source model from **HuggingFace**, a respected open-source community that enterprise developers commonly use. We chose HuggingFace because training a Generative AI model from scratch is costly from a time and data perspective. Using open-source models is a common practice to reduce time to market.

We chose a model specifically tuned for summarization. When evaluating which model to use as a starting point, we considered the following:

- The model should perform well on agent-customer conversation data
- Should have a good trade-off between latency and accuracy
- Should be supported well and be transparent about what data was used to train the model

The code was adapted to our needs and only known and vetted data was used during training.

The following diagram shows how the service works:

![Genesys Agent Assist Generative AI Service](GenerativeAIService.png "Genesys Agent Assist Generative AI Service")

## Pre/Post Processing

Preprocessing and post processing are very important to ensure we extract maximum accuracy from the model. Some of what agents and customers type during a conversation may confuse the model. For example, some words and concepts have multiple meanings, numbers are sometimes captured as words vs. digits, and other inconsistencies. While we cannot guarantee 100% accuracy, processing the data before it's fed into the model and after it's returned by the model helps. Some of the processing steps include:

- Removing emojis from the text
- Text normalization

We are working on adding additional processing such as ensuring gender neutrality in the summary itself. These processing tasks are an area of active development.

## Handling Inappropriate Content: Swear Words, Racial Slurs, etc.

We need to be careful and control the kind of text the model generates. We know this is data that is likely to be part of the customer record and used by supervisors and other stakeholders. Most commercially available models have little built-in constraint and they generate whatever content the algorithms produce with no filter. Models must be trained specifically to recognize and deal with offensive language. This is true especially if the input conversation contains swear words, racial slurs, and other offensive content. The model will summarize that content verbatim.

Given the role these summaries play for our customers, we wanted to avoid that. As part of the summary generation process, we suppress a global list of swear/offensive words. This list will be enhanced as we learn more about how this feature is used.

## Architecture and Flow

This service uses several components that are already part of Genesys Cloud. Here is a quick description of how the service works:

1. Once the agent ends the conversation in the UI, the Generative AI service receives the conversation details
2. Conversation transcripts are then fetched for processing
3. The conversation is pre-processed using standard NLP Techniques
4. The core engine leverages **seq2seq** modeling approach to summarize the conversation
5. The output is post-processed
6. After all processes are complete, we let the consuming services know that the summary is available
7. The summary is presented to the agent through their desktop for validation and modification

## Next Steps

With Genesys Agent Assist automatic summarization Generative AI service, we have taken an important first step towards embracing Generative AI within our platform. We are continually exploring other applications and use cases and will share our progress as our roadmap evolves. And of course, ChatGPT (and now BARD) changed everything. While big LLMs like ChatGPT are great, they also suffer from a couple of issues. They tend to be expensive (processing costs) because they are built to do a lot of tasks, vs just the ones that we need to enable. There are also issues with legal challenges and terms of service limitations that may preclude the use of these components in applications like Genesys. This is an area of rapid innovation, and we are constantly learning and experimenting. With Summarization, we are trying to focus on one task and do it better.

If you want to try Agent Assist's auto-summary feature, you can do so through [AppFoundry](https://appfoundry.genesys.com/filter/genesyscloud/listing/16ec8bdd-acd9-4aa0-a05e-e4b927603475).
