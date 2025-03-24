# Getting Started

Getting Started with FlowNavigation

## Overview

FlowNavigation is a lightweight and type-safe way to build multi-screen flows in SwiftUI. 
This article will walk you through the basics of defining screens, composing flows, and reading data from earlier steps.

### Defining a Screen

In FlowNavigation, a screen is just a SwiftUI view that conforms to ``FlowScreen`` instead of View.

Here’s an example of a simple name input screen:

@Snippet(path: "swiftui-flow-navigation/Snippets/getting-started", slice: NameFlowScreen)

To show the screen in a flow:

@Snippet(path: "swiftui-flow-navigation/Snippets/getting-started", slice: Flow1)

The `control.next(_:)` method moves the user to the next screen in the flow and passes along the screen’s output.

### Reusing Screens with Aliases

Many screens follow similar patterns — for example, collecting text input. 
You can generalize these using screen parameters and ``FlowScreen/alias(_:)`` to differentiate them in the flow.

@Snippet(path: "swiftui-flow-navigation/Snippets/getting-started", slice: TextInputFlowScreen)

You can reuse this screen with different titles and assign aliases to distinguish their outputs:

@Snippet(path: "swiftui-flow-navigation/Snippets/getting-started", slice: Flow2)

### Reading Flow Data with FlowReader

To access data from previous screens, use FlowReader. 
It provides a proxy object that lets you read screen output in a type-safe way.

@Snippet(path: "swiftui-flow-navigation/Snippets/getting-started", slice: Flow3)

FlowReader enforces correct types and will catch mismatches at compile time.
You can also perform asynchronous work inside a FlowReader before returning the screen:

@Snippet(path: "swiftui-flow-navigation/Snippets/getting-started", slice: Flow4)

This allows dynamic flow branching or data fetching based on earlier input.
