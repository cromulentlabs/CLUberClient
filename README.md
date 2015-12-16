# CLUberClient

This is a very simple iOS Objective-C wrapper around NSURLSession 
for use in accessing the Uber RESTful API:

https://developer.uber.com/docs/api-overview

So far the only calls implemented are:

   1. List Products
   2. Get time estimates

Although simple, it's a nice starting point for someone getting 
started with the Uber API. It has a few niceties like handling 
the auth token, localization request based on the user's current
locale, and automatically switching to the proper Uber API endpoint
in China when needed.

## Installation

### CocoaPods

CLUberClient is available on CocoaPods and can be install by adding
```
pod 'CLUberClient'
```
to your pod file.

### Manually

Alternatively, you can just copy the CLUberClient directory into 
your project.
