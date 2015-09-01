//
//  EscapePodsTableViewCell.m
//  Weird Retro
//
//  Created by User i7 on 03/02/15.
//  Copyright (c) 2015 Alex Dougas. All rights reserved.
//

#import "BlogPostTableViewCell.h"
#import "Managers.h"
#import <AFNetworking/UIKit+AFNetworking.h>


@implementation BlogPostTableViewCell


- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(80, 10, 10, 100)];
    self.lblTitle.numberOfLines = 0;
    self.lblTitle.font = [UIFont fontWithName:@"Lato-Regular" size:14.f];
    
    self.lblDescription = [[UILabel alloc] initWithFrame:CGRectMake(80, 10, 10, 100)];
    self.lblDescription.numberOfLines = 0;
    self.lblDescription.font = [UIFont fontWithName:@"Lato-Light" size:12.f];

    self.lblDate = [[UILabel alloc] initWithFrame:CGRectMake(80, 10, 10, 20)];
    self.lblDate.numberOfLines = 1;
    self.lblDate.font = [UIFont fontWithName:@"Lato-Medium" size:9.f];
    
    [self.contentView addSubview:self.lblTitle];
    [self.contentView addSubview:self.lblDate];
    [self.contentView addSubview:self.lblDescription];
    
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
}


- (void) layoutSubviews
{
    [super layoutSubviews];
    
    self.imgThumbnail.image = nil;
//    [self.imgThumbnail setImageWithURL:[NSURL URLWithString:[NETWORK.baseURL stringByAppendingPathComponent:self.blogPost.thumbnailUrl]]];
    
    CGRect rectTitle = [self.lblTitle.text boundingRectWithSize:CGSizeMake(self.contentView.frame.size.width - 80, 100) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.lblTitle.font} context:nil];

    self.lblTitle.frame = CGRectMake(self.lblTitle.frame.origin.x, 10, rectTitle.size.width, rectTitle.size.height);

    
    self.lblDate.frame = CGRectMake(self.lblTitle.frame.origin.x,
                                    self.lblTitle.frame.origin.y + self.lblTitle.frame.size.height + 5,
                                    self.contentView.frame.size.width - 80,
                                    10);
    
    ///////////////////
    
    CGFloat descriptionOrigin = self.lblDate.frame.origin.y + self.lblDate.frame.size.height + 3;
    CGFloat maxHeight = 100 - descriptionOrigin;
    
    rectTitle = [self.lblDescription.text boundingRectWithSize:CGSizeMake(self.contentView.frame.size.width - 80, maxHeight) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:self.lblDescription.font} context:nil];

    self.lblDescription.frame = CGRectMake(self.lblDescription.frame.origin.x,
                                           descriptionOrigin,
                                           rectTitle.size.width,
                                           rectTitle.size.height);
    
}

- (void) setBlogPost:(BlogPost *)blogPost
{
    _blogPost = blogPost;
    
    self.lblDescription.text = _blogPost.info;
    self.lblTitle.text = _blogPost.title;
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"dd/MM/yyyy";
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    self.lblDate.text = [NSString stringWithFormat:@"%@ Comments | %@", _blogPost.commentsCount, [formatter stringFromDate:_blogPost.dateBlogPost]];
}

@end
