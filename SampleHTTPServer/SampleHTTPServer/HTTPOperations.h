//
//  HTTPOperations.h
//  SampleHTTPServer
//
//  Client API for remote application access.
//
//  Created by Matt on 9/11/13.
//  Copyright (c) 2013 Blue Rocket, Inc. Distributable under the terms of the Apache License, Version 2.0.
//

#import <Foundation/Foundation.h>

@interface HTTPOperations : NSObject

@property (nonatomic, readonly) NSURL *rootURL;

- (instancetype)initWithRootURL:(NSURL *)rootURL;

// return an array of zero or more string color names, e.g. "red, orange, blue"
- (NSArray *)favoriteColors;

// save an array of color names, e.g. "red, orange, blue"
- (void)saveFavoriteColors:(NSArray *)colors;

@end
