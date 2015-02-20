//
//  WRPage.h
//  Weird Retro
//
//  Created by User i7 on 05/02/15.
//  Copyright (c) 2015 Alex Dougas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HTMLReader/HTMLReader.h>


typedef NS_ENUM(NSUInteger, PageType) {
    PageTypeMemories,
    PageTypePost,
    PageTypeBlogPage,
    PageTypeBlogPost,
    PageTypeMainPage,
};


@interface WRPage : NSObject

@property (copy, nonatomic) NSString* title;
@property (copy, nonatomic) NSString* url;
@property (copy, nonatomic) NSString* info;
@property (copy, nonatomic) NSString* keywords;
@property (copy, nonatomic) NSString* thumbnailUrl;

@property (strong, nonatomic) NSArray* items;
@property (strong, nonatomic) NSArray* items2;

@property (copy, nonatomic) NSString* blogPostDate;

@property (assign, nonatomic) NSInteger blogPostCountComments;
@property (copy, nonatomic) NSString* blogPostId;
@property (copy, nonatomic) NSString* blogUserId;
@property (copy, nonatomic) NSString* blogBlogId;
@property (strong, nonatomic) NSArray* blogComments;

@property (assign, nonatomic) PageType type;

@end
