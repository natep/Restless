A type-safe HTTP client for iOS, inspired by Retrofit.

# Introduction

Restless turns your HTTP API into an Objective-C protocol.

Just define a protocol that inherits from `DRWebService`.

```objective-c
@protocol GitHubService <DRWebService>

@GET("/users/{user}/repos")
- (NSURLSessionDataTask*)listRepos:(NSString*)user
                          callback:DR_CALLBACK(NSArray<GitHubRepo*>*)callback;

@end
```

The `DRRestAdapter` class generates an implementation of the `GitHubService` protocol.

```objective-c
DRRestAdapter* ra = [DRRestAdapter restAdapterWithBlock:^(DRRestAdapterBuilder *builder) {
    builder.endPoint = [NSURL URLWithString:@"https://api.github.com"];
}];

NSObject<GitHubService>* service = [ra create:@protocol(GitHubService)];
```

Each `NSURLSessionTask` returned from the created `GitHubService` can make an asynchronous HTTP request to the remote webserver.

```objective-c
NSURLSessionDataTask* task = [service listRepos:@"natep"
                                       callback:^(NSArray<GitHubRepo*>* result,
                                                  NSURLResponse *response,
                                                  NSError *error)
{
    // response handling ...
}];
    
[task resume];
```

Use annotations to describe the HTTP request.

# API Declaration

Annotations on the interface methods and its parameters indicate how a request will be handled.

#### REQUEST METHOD

Every method must have an HTTP annotation that provides the request method and relative URL. There are six built-in annotations: GET, POST, PUT, DELETE, HEAD and PATCH. The relative URL of the resource is specified in the annotation.

```objective-c
@GET("/users/list")
```

You can also specify query parameters in the URL.

```objective-c
@GET("/users/list?sort=desc")
```

#### URL MANIPULATION

A request URL can be updated dynamically using replacement blocks and parameters on the method. A replacement block is an alphanumeric string surrounded by { and }. The method will look for a parameter name that matches that string, and substitute in its value.

```objective-c
@GET("/users/{user}/repos")
- (NSURLSessionDataTask*)listRepos:(NSString*)user
                          callback:DR_CALLBACK(NSArray<GitHubRepo*>*)callback;
```

Any parameters to the method that are not otherwise consumed (for instance, used in a substitution) are included in the URL as a query item.

#### REQUEST BODY

An object can be specified for use as an HTTP request body with a `@Body` method annotation containing the parameter name.

```objective-c
@POST("/users/new")
@Body("user")
- (NSURLSessionUploadTask*)createUser:(User*)user 
                             callback:DR_CALLBACK(User*)callback;
```

The object will also be converted using a converter specified on the `DRRestAdapter` instance. A JSON converter is used by default.

#### CALLBACK

`DR_CALLBACK()` is a special macro that takes the type of object that you want to be returned, and creates a `NSURLSessionTask`-style callback where the first callback parameter is an object of that type. In the `listRepos:callback:` example above, a callback type of `NSArray<GitHubRepo*>*` is specified. When you call the `listRepos:callback:` method, code completion will automatically expand that to the following callback:

```objective-c
^(NSArray<GitHubRepo*>* result, NSURLResponse *response, NSError *error)
```

The library will attempt to convert the response into the type of object you specified, using the converter that was specifed in the builder. In this case, an `NSArray` of `GitHubRepo` objects.

The callback should always be the last parameter of your method.

#### NSURLSessionTask

The return type of the method defines what type of `NSURLSessionTask` you want the method to build for you.

`NSURLSessionDataTask`, `NSURLSessionDownloadTask`, and `NSURLSessionUploadTask` are all supported, but you should make sure that the value you pass to `DR_CALLBACK()` is appropriate for the task. For instance, you should pass `NSURL*` when requesting an `NSURLSessionDownloadTask`. Upon completion that parameter of the callback will be a URL to a temporary file containing the download.

#### HEADER MANIPULATION

You can set static headers for a method using the `@Headers` annotation.

```objective-c
@Headers({ "Accept": "application/vnd.github.v3.full+json", "User-Agent": "Restless-Sample-App" })
@GET("/users/{username}")
- (NSURLSessionDataTask*)getUser:(NSString*)username
                        callback:DR_CALLBACK(User*)callback;
```

The value of the `@Headers` parameter should always be a JSON object (aka, a dictionary). The value of a header may also use parameter substitution.

# Limitations

- Although this library is inspired by Retrofit, it does not yet have complete feature parity. In particular, neither multi-part nor form-encoded bodies are natively supported yet.

- The current parsing logic does not handle multi-line annotations. So you cannot have a single annotation that spans multiple lines.

- The current parsing logic is primitive, and does not understand macros. So you should not use them in your web service protocol declaration. Typedefs may or may not work.

- Performance has not yet been evaluated. This will be a focus of future releases.

# Installation

It is recommended that you install this library via Cocoapods

```ruby
pod 'Restless'
```

After installation, you will need to add a new Run Script Build Phase to your project, that runs this command:

```bash
"${PODS_ROOT}"/Restless/Restless/Scripts/generate.sh
```

# License

```
Copyright (c) 2015 Digital Rickshaw LLC
    
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
    
The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.
    
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```
