//
//  HTTPOperationsTests.m
//  SampleHTTPServerTests
//
//  Created by Matt on 9/11/13.
//  Copyright (c) 2013 Blue Rocket, Inc. All rights reserved.
//

#import "HTTPOperationsTests.h"

// NOTE: to work with some HTTPServer categories (e.g. DDNumber), we must add the
// -force_load "$(PROJECT_DIR)/../BRRoutingHTTPServer/Framework/Release/HTTPServer.framework/HTTPServer"
// linker flag, otherwise we get runtime "missing selector" crashes
#import <HTTPServer/RoutingHTTPServer.h>
#import "HTTPOperations.h"

@implementation HTTPOperationsTests {
	NSBundle *bundle;
	RoutingHTTPServer *http;
	HTTPOperations *operations;
}

- (NSURL *)rootURL {
	return [NSURL URLWithString:[@"http://localhost:" stringByAppendingFormat:@"%u/", [self.http listeningPort]]];
}

- (void)setUp {
	http = nil;
	operations = [[HTTPOperations alloc] initWithRootURL:[self rootURL]];
	BRLoggingSetupDefaultLoggingWithBundle([NSBundle bundleForClass:[self class]]);
}

- (void)tearDown {
	[http stop];
}

- (RoutingHTTPServer *)http {
	if ( http == nil ) {
		http = [[RoutingHTTPServer alloc] init];
		[http setDefaultHeader:@"Server" value:@"UnitTests/1.0"];
		[http start:nil];
	}
	return http;
}

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

- (void)testSaveFavoriteColors {
	__block BOOL gotExpectedData = NO;
	[self.http handleMethod:@"PUT" withPath:@"/colors" block:^(RouteRequest *request, RouteResponse *response) {
		NSError *error = nil;
		id json = [NSJSONSerialization JSONObjectWithData:[request body] options:0 error:&error];
		NSLog(@"Got data: %@", json);
		NSArray *expected = @[@"green", @"red", @"yellow"];
		STAssertTrue([json isKindOfClass:[NSDictionary class]], @"Dictionary data PUT");
		NSArray *colors = json[@"colors"];
		gotExpectedData = [expected isEqualToArray:colors];
		if ( gotExpectedData ) {
			[response setStatusCode:201]; // Created
		} else {
			[response setStatusCode:422]; // Unprocessable Entity
		}
	}];
	
	[operations saveFavoriteColors:@[@"green", @"red", @"yellow"]];
	STAssertTrue(gotExpectedData, @"PUT colors equal");
}

@end
