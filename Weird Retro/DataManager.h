//
//  DataManager.h
//  Weird Retro
//
//  Created by User i7 on 03/02/15.
//  Copyright (c) 2015 Alex Dougas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject

+ (instancetype) sharedInstance;

@property (nonatomic, strong) NSMutableArray* articles;
@property (nonatomic, strong) NSMutableDictionary* posts;

- (void) updatingStructureFromBackendWithCompletion:(void(^)(NSError* error))completion;
- (void) updatingPostFromBackendFile:(NSString*)filePath completion:(void(^)(NSError* error))completion;

@end
