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
}


//- (void) layoutSubviews
//{
//    self.imgThumbnail.image = nil;
//    [self.imgThumbnail setImageWithURL:[NSURL URLWithString:[NETWORK.baseURL stringByAppendingPathComponent:self.post.thumbnailUrl]]];
//    
//    CGRect rectTitle = [self.lblTitle.text boundingRectWithSize:self.lblTitle.frame.size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.lblTitle.font} context:nil];
//    self.lblTitle.frame = CGRectMake(self.lblTitle.frame.origin.x, 40, rectTitle.size.width, rectTitle.size.height);
//    
//    self.lblDescription.frame = CGRectMake(self.lblDescription.frame.origin.x, 0, self.lblDescription.frame.size.width, self.lblDescription.frame.size.height);
//}
//
//- (void) setPost:(Post *)post
//{
//    _post = post;
//    
//    self.lblDescription.text = self.post.info;
//    self.lblTitle.text = self.post.title;
//
//}

@end
