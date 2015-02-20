//
//  HTMLConverter.m
//  Weird Retro
//
//  Created by User i7 on 03/02/15.
//  Copyright (c) 2015 Alex Dougas. All rights reserved.
//

#import "Managers.h"
#import "HTMLReader.h"
#import "HTMLParser.h"

#import "HTMLConvertOperation.h"


@implementation HTMLConverter


+ (instancetype) sharedInstance
{
    static dispatch_once_t pred;
    static id sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}


- (instancetype) init
{
    self = [super init];
    
    if ( self )
    {
        self.operations = [[NSOperationQueue alloc] init];
    }

    return self;
}


- (void) convertBlogPostPage:(NSString*)htmlText withCompletion:(void(^)(WRPage* pageObject))completion
{
    HTMLConvertOperation* operation = [[HTMLConvertOperation alloc] init];
    operation.type = PageTypeBlogPage;
    operation.htmlMarkup = htmlText;
    
    operation.successFailureBlock = ^(WRPage* pageObject) {
        
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        dispatch_async(mainQueue, ^{
            
            completion(pageObject);
            
        });
        
    };
    
    [operation start];
}



- (void) convertMemoryBanksToStructure:(NSString*)htmlText withCompletion:(void(^)(WRPage* pageObject))completion
{
    HTMLConvertOperation* operation = [[HTMLConvertOperation alloc] init];
    operation.type = 0;
    operation.htmlMarkup = htmlText;
    
    operation.successFailureBlock = ^(WRPage* pageObject) {
        
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        dispatch_async(mainQueue, ^{
            
            completion(pageObject);

        });
        
    };
    
    [operation start];
}


- (void) convertPostToStructure:(NSString*)htmlText withCompletion:(void(^)(WRPage* pageObject))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void)
    {
        HTMLConvertOperation* operation = [[HTMLConvertOperation alloc] init];
        operation.type = PageTypePost;
        operation.htmlMarkup = htmlText;

        operation.successFailureBlock = ^(WRPage* pageObject) {
            
            dispatch_queue_t mainQueue = dispatch_get_main_queue();
            dispatch_async(mainQueue, ^{
                completion(pageObject);
            });
            
        };

        [operation start];
   });
    
}


- (void) convertMainPage:(NSString*)htmlText withCompletion:(void(^)(WRPage* pageObject))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void)
    {
       HTMLConvertOperation* operation = [[HTMLConvertOperation alloc] init];
       operation.type = PageTypeMainPage;
       operation.htmlMarkup = htmlText;
       
       operation.successFailureBlock = ^(WRPage* pageObject) {
           
           dispatch_queue_t mainQueue = dispatch_get_main_queue();
           dispatch_async(mainQueue, ^{
               completion(pageObject);
           });
           
       };
       
       [operation start];
   });
    
}


- (void) convertBlogPostToStructure:(NSString*)htmlText withCompletion:(void(^)(WRPage* pageObject))completion
{
    HTMLConvertOperation* operation = [[HTMLConvertOperation alloc] init];
    operation.type = PageTypeBlogPost;
    operation.htmlMarkup = htmlText;
    
    operation.successFailureBlock = ^(WRPage* pageObject) {
        
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        dispatch_async(mainQueue, ^{
            
            completion(pageObject);
            
        });
        
    };
    
    [operation start];
}



@end
