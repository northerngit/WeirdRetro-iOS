//
//  DataManager.m
//  Weird Retro
//
//  Created by User i7 on 03/02/15.
//  Copyright (c) 2015 Alex Dougas. All rights reserved.
//

#import "Managers.h"
#import "WRPage.h"


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



- (void) loadBlogPostsFromBackendWithCompletion:(void(^)(NSError* error))completion
{
    [NETWORK loadingHTMLFile:@"captains-blog" withCompletion:^(NSError *error, NSString *htmlMarkup) {
        if ( !error )
        {
//            [CONVERTER convertBlogPostPage:htmlMarkup withCompletion:^(WRPage* pageObject) {
//                
//                self.articles = [NSMutableArray arrayWithArray:pageObject.items];
//                
//                if ( completion )
//                    completion(nil);
//            }];
            
        }
        
        if ( completion )
            return completion(error);
    }];
}



- (void) updatingStructureFromBackendWithCompletion:(void(^)(NSError* error))completion
{
    [NETWORK loadingHTMLFile:@"memory-banks.html" withCompletion:^(NSError *error, NSString *htmlMarkup) {
        if ( !error )
        {
            [CONVERTER convertMemoryBanksToStructure:htmlMarkup withCompletion:^(WRPage* pageObject) {
            
                self.articles = [NSMutableArray arrayWithArray:pageObject.items];
                
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
            [CONVERTER convertPostToStructure:htmlMarkup withCompletion:^(WRPage* pageObject) {
                
                self.posts[filePath] = pageObject.items;
                
                if ( completion )
                    completion(nil);
            }];
        }
        
        if ( completion )
            return completion(error);
    }];
}



@end
