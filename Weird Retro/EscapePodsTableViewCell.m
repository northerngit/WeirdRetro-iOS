//
//  EscapePodsTableViewCell.m
//  Weird Retro
//
//  Created by User i7 on 03/02/15.
//  Copyright (c) 2015 Alex Dougas. All rights reserved.
//

#import "EscapePodsTableViewCell.h"
#import "Post.h"
#import "Managers.h"
#import <AFNetworking/UIKit+AFNetworking.h>

@implementation EscapePodsTableViewCell


- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(80, 10, 10, 100)];
    self.lblTitle.numberOfLines = 0;
    self.lblTitle.font = [UIFont fontWithName:@"Lato-Regular" size:14.f];
    self.lblTitle.backgroundColor = [UIColor clearColor];
    
    self.lblDescription = [[UILabel alloc] initWithFrame:CGRectMake(80, 10, 10, 100)];
    self.lblDescription.numberOfLines = 0;
    self.lblDescription.font = [UIFont fontWithName:@"Lato-Light" size:12.f];
//    self.lblDescription.backgroundColor = [UIColor redColor];
    
    [self.contentView addSubview:self.lblTitle];
    [self.contentView addSubview:self.lblDescription];
}


- (void) layoutSubviews
{
    [super layoutSubviews];
    
    self.imgThumbnail.image = nil;
    [self.imgThumbnail setImageWithURL:[NSURL URLWithString:[NETWORK.baseURL stringByAppendingPathComponent:self.post.thumbnailUrl]]];
    
    CGRect rectTitle = [self.lblTitle.text boundingRectWithSize:CGSizeMake(self.contentView.frame.size.width - 80, 100) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.lblTitle.font} context:nil];
    self.lblTitle.frame = CGRectMake(self.lblTitle.frame.origin.x, 10, rectTitle.size.width, rectTitle.size.height);
    

    rectTitle = [self.lblDescription.text boundingRectWithSize:CGSizeMake(rectTitle.size.width, 100) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.lblDescription.font} context:nil];
    
    self.lblDescription.frame = CGRectMake(self.lblDescription.frame.origin.x,
       self.lblTitle.frame.origin.y + self.lblTitle.frame.size.height + 5,
       rectTitle.size.width,
       ((self.lblDescription.frame.origin.y + rectTitle.size.height) > 90) ? (90 - self.lblDescription.frame.origin.y) : rectTitle.size.height);
}

- (void) setPost:(Post *)post
{
    _post = post;
    
    self.lblDescription.text = post.info;
    self.lblTitle.text = post.title;
}

@end
