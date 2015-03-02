//
//  CustomURLCache.m
//  Weird Retro
//
//  Created by User i7 on 12/02/15.
//  Copyright (c) 2015 Alex Dougas. All rights reserved.
//

#import "CustomURLCache.h"

static NSString * const CustomURLCacheExpirationKey = @"CustomURLCacheExpiration";
static NSTimeInterval const CustomURLCacheExpirationInterval = 6000;

@implementation CustomURLCache

+ (instancetype)standardURLCache {
    static CustomURLCache *_standardURLCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _standardURLCache = [[CustomURLCache alloc]
                             initWithMemoryCapacity:(5 * 1024 * 1024)
                             diskCapacity:(100 * 1024 * 1024)
                             diskPath:nil];
    });
                  
  return _standardURLCache;
    
}

#pragma mark - NSURLCache

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request
{
    NSCachedURLResponse *cachedResponse = [super cachedResponseForRequest:request];

    if (cachedResponse)
    {
        if ([(NSDate*)cachedResponse.userInfo[CustomURLCacheExpirationKey] compare:[[NSDate date] dateByAddingTimeInterval:CustomURLCacheExpirationInterval]] == NSOrderedDescending)
        {
            [self removeCachedResponseForRequest:request];
            return nil;
        }
        
    }

    return cachedResponse;
}


- (void)storeCachedResponse:(NSCachedURLResponse *)cachedResponse forRequest:(NSURLRequest *)request
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:cachedResponse.userInfo];
    userInfo[CustomURLCacheExpirationKey] = [NSDate date];

    NSCachedURLResponse *modifiedCachedResponse = [[NSCachedURLResponse alloc] initWithResponse:cachedResponse.response data:cachedResponse.data userInfo:userInfo storagePolicy:cachedResponse.storagePolicy];

    [super storeCachedResponse:modifiedCachedResponse forRequest:request];
}

@end
