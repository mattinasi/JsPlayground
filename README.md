# JS Playground
Sometimes you just have to play with stuff to understand it... here we have JavaScript and Swift playing together

Here we have a simple experiment involving using JS to manage a model, so that it can be shared with Android

There is a singleton JSManager that creates the JS context, and provides a semantic interface for managing a simplistic data model. 

Data Model is exposed as Swift classes, so it is easy to consume in ViewController and such, however the in-memory and on-disk storage is all in Javascript.

This is just a Proof of Concept to help get a feel for whether or not it is worth the effort to build the model-layer in JS

Most of the usage is in the Unit Tests currently - will expose more in the test app soon, unless we decide to abandon this approach ;-)

https://github.com/mattinasi/JsPlayground/blob/master/JsPlaygroundTests/JsPlaygroundTests.swift


See related project which does the same thing in Android, using the same JS model script: https://github.com/mattinasi/JSPlaygroundAndroid

