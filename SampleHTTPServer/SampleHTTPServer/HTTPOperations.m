//
//  HTTPOperations.m
//  SampleHTTPServer
//
//  Created by Matt on 9/11/13.
//  Copyright (c) 2013 Blue Rocket, Inc. All rights reserved.
//

#import "HTTPOperations.h"

#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "HTTPRequestOperation.h"

@implementation HTTPOperations {
	AFHTTPClient *httpClient;
}

- (instancetype)init {
	return [self initWithRootURL:nil];
}

- (instancetype)initWithRootURL:(NSURL *)rootURL {
	if ( (self = [super init]) ) {
		httpClient = [[AFHTTPClient alloc] initWithBaseURL:rootURL];
		httpClient.parameterEncoding = AFJSONParameterEncoding;
		[httpClient registerHTTPOperationClass:[HTTPRequestOperation class]]; // allow synchronous calls
	}
	return self;
}

- (NSURL *)rootURL {
	return httpClient.baseURL;
}

- (BOOL)synchronousPUT:(NSString *)path
			parameters:(NSDictionary *)parameters
			   timeout:(NSTimeInterval)timeout
			   success:(void (^)(AFHTTPRequestOperation * op, id responseObject))success
			   failure:(void (^)(AFHTTPRequestOperation * op, NSError *httpError))failure {
	__block BOOL finished = NO;
	NSCondition *condition = [NSCondition new];
	[condition lock];
	[httpClient putPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if ( success != NULL ) {
			success(operation, responseObject);
		}
		[condition lock];
		finished = YES;
		[condition signal];
		[condition unlock];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if ( failure != NULL ) {
			failure(operation, error);
		}
		[condition lock];
		[condition signal];
		[condition unlock];
	}];
	
	[condition waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:timeout]];
	[condition unlock];
	return finished;
}

- (BOOL)synchronousGET:(NSString *)path
			parameters:(NSDictionary *)parameters
			   timeout:(NSTimeInterval)timeout
			   success:(void (^)(AFHTTPRequestOperation * op, id responseObject))success
			   failure:(void (^)(AFHTTPRequestOperation * op, NSError *httpError))failure {
	__block BOOL finished = NO;
	NSCondition *condition = [NSCondition new];
	[condition lock];
	[httpClient getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if ( success != NULL ) {
			success(operation, responseObject);
		}
		[condition lock];
		finished = YES;
		[condition signal];
		[condition unlock];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if ( failure != NULL ) {
			failure(operation, error);
		}
		[condition lock];
		[condition signal];
		[condition unlock];
	}];
	
	[condition waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:timeout]];
	[condition unlock];
	return finished;
}

- (NSArray *)favoriteColors {
	__block NSArray *result = nil;
	__block NSError *error = nil;
	[self synchronousGET:@"/colors" parameters:nil timeout:10 success:^(AFHTTPRequestOperation *op, id responseObject) {
		id json = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		log4Info(@"Got color response: %@", json);
		if ( [json isKindOfClass:[NSArray class]] ) {
			result = json;
		}
	} failure:^(AFHTTPRequestOperation *op, NSError *httpError) {
		error = httpError;
	}];
	if ( error != nil ) {
		log4Error(@"Error getting colors: %@", [error localizedDescription]);
	}
	return result;
}

// save an array of color names, e.g. "red, orange, blue"
- (void)saveFavoriteColors:(NSArray *)colors {
	__block NSError *error = nil;
	[self synchronousPUT:@"/colors" parameters:@{@"colors": colors} timeout:10 success:NULL
				 failure:^(AFHTTPRequestOperation *op, NSError *httpError) {
		error = httpError;
	}];
	if ( error != nil ) {
		log4Error(@"Error saving colors: %@", [error localizedDescription]);
	}
}

@end
