# Completing a Flow

Learn how to handle the completion of a flow.

## Overview

A ``Flow`` is considered completed once it has finished presenting all its screens.
By default, a completed flow triggers the environment’s  [dismiss](https://developer.apple.com/documentation/swiftui/dismissaction) action.

Often, flows end by collecting data from previous screens—for example, to send it to a server.
In some cases, you may want to display a final “completion” screen that shows the result of the submission.
To do this, use a ``FlowReader`` to access the data and return the appropriate screen:

@Snippet(path: "swiftui-flow-navigation/Snippets/completing-a-flow", slice: FlowReaderExample)

In other cases, you may not want to show a completion screen. 
For this, use the ``Flow/init(screens:completion:)`` initializer, which accepts a completion handler.
This handler receives a proxy containing data from all visited screens:

@Snippet(path: "swiftui-flow-navigation/Snippets/completing-a-flow", slice: CompletionExample)

The completion handler must return an action. Unless you’re explicitly removing the flow yourself, you should return `.dismiss`.
