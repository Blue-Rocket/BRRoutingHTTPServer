//
//  HTTPRequestOperation.h
//  SampleHTTPServer
//
//  Created by Matt on 9/11/13.
//  Copyright (c) 2013 Blue Rocket, Inc. Distributable under the terms of the Apache License, Version 2.0.
//

#import "AFHTTPRequestOperation.h"

@interface HTTPRequestOperation : AFHTTPRequestOperation

// init with a specific queue; if no queue provided, then use a global async queue with priority DISPATCH_QUEUE_PRIORITY_DEFAULT
- (instancetype)initWithRequest:(NSURLRequest *)requestOperation callbackQueue:(dispatch_queue_t)callbackQueue;

@end
