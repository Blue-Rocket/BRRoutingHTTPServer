BRRoutingHTTPServer
===================

The [RoutingHTTPServer](https://github.com/mattstevens/RoutingHTTPServer) project
provides a great way to implement HTTP-based unit tests in iOS projects. The
`BRRoutingHTTPServer` project provides a static library framework bundle that 
simplifies integrating `RoutingHTTPServer` into your project.

Clone the repository
--------------------

First clone this repository, and initialize the submodules:

	git clone git@github.com:Blue-Rocket/BRRoutingHTTPServer.git
	git submodules update --init --recursive
	
Build the framework
-------------------

Open the `BRRoutingHTTPServer` Xcode project, and then build the 
`BRRoutingHTTPServer.framework` target. This will produce the
`BRRoutingHTTPServer/Framework/Release/HTTPServer.framework` framework bundle.

Integrate into your project
---------------------------

Copy the `HTTPServer.framework` bundle into your project and add as a required build
dependency. You'll also need to add the following frameworks:

  * `BRCocoaLumberjack.framework` (available in the `lib` directory of this project)
  * `libxml2`
  
In some situations, if you're using `BRRoutingHTTPServer` for unit testing, you may 
need to add a linker flag `-force_load` with an argument that provides the path to 
the `HTTPServer` static library file. If your unit test crashes from an error like

	+[NSNumber parseString:intoUInt64:]: unrecognized selector sent to class 0x2c8f0c

then you'll need to do this. Add a linker flag like the following:

	-force_load "$(PROJECT_DIR)/lib/HTTPServer.framework/HTTPServer"

where the actual path is appropriate to your project's environment.

If you're using `BRRoutingHTTPServer` in an actual application, you can most likely
just add the `-ObjC` linker flag, without the `-force_load` flag.

Sample unit test project
------------------------

The `SampleHTTPServer` project, included in the repository, demonstrates how to
integrate `BRRoutingHTTPServer` into another project. You must first build the
framework as described above, and then you can open this project. The project
does not contain a useful application, rather it contains example unit tests that
make use of the HTTP server provided by the `HTTPServer` framework, using the 
popular [AFNetworking](https://github.com/AFNetworking/AFNetworking) `HTTPClient`
class as the client. An example unit test method looks like this:

```objc
- (void)testGetFavoriteColors {
	[self.http handleMethod:@"GET" withPath:@"/colors" block:^(RouteRequest *request, RouteResponse *response) {
		[response setHeader:@"Content-Type" value:@"application/json"];
		[response respondWithString:@"[\"red\",\"orange\",\"blue\"]"];
	}];
	
	NSArray *colors = [operations favoriteColors];
	STAssertNotNil(colors, @"Colors");
	NSArray *expected = @[@"red", @"orange", @"blue"];
	STAssertTrue([colors isEqualToArray:expected], @"Expected colors");
}
```

The method verifies that a HTTP client class, `HTTPOperations`, correctly
calls the HTTP GET operation `/colors` and processes the JSON response into 
an array of strings. This shows the basic pattern for unit tests using this 
framework:

  1. Set up blocks to execute when specific HTTP methods and paths are requested
  2. Execute client code
  3. Verify the client processed the HTTP response correctly
  

  
