Pod::Spec.new do |s|
  s.name         = "CLUberClient"
  s.version      = "0.0.1"
  s.summary      = "Wrapper around NSURLSession to access the Uber REST API"
  s.description  = <<-DESC
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
                   DESC
  s.homepage     = "https://github.com/cromulentlabs/CLUberClient"
  s.license      = "Apache License, Version 2.0"
  s.author       = "Greg Gardner"
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/cromulentlabs/CLUberClient.git", :tag => "#{s.version}" }
  s.source_files = "CLUberClient"
  s.frameworks   = "Foundation"
  s.requires_arc = true
end
