//
//  Comment.h
//  Weird Retro
//
//  Created by User i7 on 09/02/15.
//  Copyright (c) 2015 Alex Dougas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BlogPost;

@interface Comment : NSManagedObject

@property (nonatomic, retain) NSString * commentId;
@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * indent;
@property (nonatomic, retain) BlogPost *blogPost;

@end
