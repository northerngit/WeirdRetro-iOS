//
//  NetworkWorker.h
//  Weird Retro
//
//  Created by User i7 on 03/02/15.
//  Copyright (c) 2015 Alex Dougas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkWorker : NSObject

@property (nonatomic, strong) NSString* baseURL;

+ (instancetype) sharedInstance;

- (void) loadingHTMLFile:(NSString*)filePath withCompletion:(void(^)(NSError* error, NSString* htmlMarkup))completion;


@end
