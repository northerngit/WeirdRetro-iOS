//
//  DataManager.m
//  Weird Retro
//
//  Created by User i7 on 03/02/15.
//  Copyright (c) 2015 Alex Dougas. All rights reserved.
//

#import "Managers.h"


@implementation DataManager



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
        self.articles = [NSMutableArray new];
        self.posts = [NSMutableDictionary new];
    }
    
    return self;
}




- (void) updatingStructureFromBackendWithCompletion:(void(^)(NSError* error))completion
{
    [NETWORK loadingHTMLFile:@"memory-banks.html" withCompletion:^(NSError *error, NSString *htmlMarkup) {
        if ( !error )
        {
            [CONVERTER convertMemoryBanksToStructure:htmlMarkup withCompletion:^(NSArray *postsList) {
                
                self.articles = [NSMutableArray arrayWithArray:postsList];
                
                if ( completion )
                    completion(nil);
            }];
            
        }

        if ( completion )
            return completion(error);
    }];
}


- (void) updatingPostFromBackendFile:(NSString*)filePath completion:(void(^)(NSError* error))completion
{
    [NETWORK loadingHTMLFile:filePath withCompletion:^(NSError *error, NSString *htmlMarkup) {
        if ( !error )
        {
            [CONVERTER convertPostToStructure:htmlMarkup withCompletion:^(NSArray *postsList) {
                
                self.posts[filePath] = postsList;
                
                if ( completion )
                    completion(nil);
            }];
        }
        
        if ( completion )
            return completion(error);
    }];
}



@end
