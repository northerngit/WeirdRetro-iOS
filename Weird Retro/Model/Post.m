//
//  Post.m
//  Weird Retro
//
//  Created by User i7 on 07/02/15.
//  Copyright (c) 2015 Alex Dougas. All rights reserved.
//

#import "Post.h"
#import "Section.h"


@implementation Post

@dynamic content;
@dynamic dateLastUpdated;
@dynamic dateLastView;
@dynamic info;
@dynamic keywords;
@dynamic title;
@dynamic url;
@dynamic thumbnailUrl;
@dynamic order;
@dynamic section;
@dynamic orderInLast;


- (BOOL) isBlogPost
{
    return NO;
}


- (NSSet*) comments
{
    return [NSSet new];
}


@end
