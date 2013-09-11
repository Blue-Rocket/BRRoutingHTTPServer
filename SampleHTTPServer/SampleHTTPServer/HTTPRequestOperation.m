//
//  HTTPRequestOperation.m
//  SampleHTTPServer
//
//  Created by Matt on 9/11/13.
//  Copyright (c) 2013 Blue Rocket, Inc. All rights reserved.
//

#import "HTTPRequestOperation.h"

@implementation HTTPRequestOperation

- (instancetype)initWithRequest:(NSURLRequest *)request
				  callbackQueue:(dispatch_queue_t)callbackQueue {
	if ( (self = [super initWithRequest:request]) ) {
		self.successCallbackQueue = (callbackQueue == NULL ? dispatch_get_main_queue() : callbackQueue);
		self.failureCallbackQueue = (callbackQueue == NULL ? dispatch_get_main_queue() : callbackQueue);
	}
	return self;
}

- (instancetype)initWithRequest:(NSURLRequest *)request {
	return [self initWithRequest:request callbackQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

+ (BOOL)canProcessRequest:(NSURLRequest *)urlRequest {
	return YES;
}

@end
