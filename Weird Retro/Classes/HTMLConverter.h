//
//  HTMLConverter.h
//  Weird Retro
//
//  Created by User i7 on 03/02/15.
//  Copyright (c) 2015 Alex Dougas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTMLConverter : NSObject

+ (instancetype) sharedInstance;

- (void) convertMemoryBanksToStructure:(NSString*)htmlText withCompletion:(void(^)(NSArray* postsList))completion;
- (void) convertPostToStructure:(NSString*)htmlText withCompletion:(void(^)(NSArray* postsList))completion;


@property (nonatomic, strong) NSOperationQueue* operations;


@end
