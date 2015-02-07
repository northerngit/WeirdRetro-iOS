//
//  EscapePodsTableViewCell.h
//  Weird Retro
//
//  Created by User i7 on 03/02/15.
//  Copyright (c) 2015 Alex Dougas. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Post;

@interface EscapePodsTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel* lblTitle;
@property (strong, nonatomic) IBOutlet UILabel* lblDescription;
@property (strong, nonatomic) IBOutlet UIImageView* imgThumbnail;
@property (strong, nonatomic) Post* post;

@end
