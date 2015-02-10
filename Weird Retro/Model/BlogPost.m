//
//  BlogPost.m
//  Weird Retro
//
//  Created by User i7 on 09/02/15.
//  Copyright (c) 2015 Alex Dougas. All rights reserved.
//

#import "BlogPost.h"
#import "Comment.h"


@implementation BlogPost

@dynamic blogPostIdentity;
@dynamic commentsCount;
@dynamic content;
@dynamic dateBlogPost;
@dynamic dateLastUpdated;
@dynamic dateLastView;
@dynamic info;
@dynamic keywords;
@dynamic thumbnailUrl;
@dynamic title;
@dynamic url;
@dynamic comments;


- (BOOL) isBlogPost
{
    return YES;
}


@end
