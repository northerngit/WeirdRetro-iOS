//
//  Post.h
//  Weird Retro
//
//  Created by User i7 on 07/02/15.
//  Copyright (c) 2015 Alex Dougas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Post : NSManagedObject

@property (nonatomic, retain) id content;
@property (nonatomic, retain) NSDate * dateLastUpdated;
@property (nonatomic, retain) NSDate * dateLastView;
@property (nonatomic, retain) NSString * info;
@property (nonatomic, retain) NSString * keywords;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * thumbnailUrl;

@end
