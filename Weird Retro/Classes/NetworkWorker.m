//
//  NetworkWorker.m
//  Weird Retro
//
//  Created by User i7 on 03/02/15.
//  Copyright (c) 2015 Alex Dougas. All rights reserved.
//

#import "Managers.h"
#import <AFNetworking/AFNetworking.h>


@interface NetworkWorker ()
{
}


@end




@implementation NetworkWorker


+ (instancetype) sharedInstance
{
    static dispatch_once_t pred;
    static id sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}


- (id) init
{
    self = [super init];
    
    if ( self )
    {
        self.baseURL = @"http://www.weirdretro.org.uk";
    }
    
    return self;
}


- (void) loadingHTMLFile:(NSString*)filePath withCompletion:(void(^)(NSError* error, NSString* htmlMarkup))completion
{
//    NSURL *URL = [NSURL URLWithString:@"http://www.weirdretro.org.uk/cult-cinema.html"];
    NSURL *URL = [NSURL URLWithString:[self.baseURL stringByAppendingPathComponent:filePath]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    AFHTTPRequestOperation *downloadRequest = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [downloadRequest setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSData *data = [[NSData alloc] initWithData:responseObject];
        NSString* string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

        if ( completion )
            completion(nil, string);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        if ( completion )
            completion(error, nil);
        
    }];
    
    [downloadRequest start];
}


@end
