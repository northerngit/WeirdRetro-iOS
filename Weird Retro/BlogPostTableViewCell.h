//
//  EscapePodsTableViewCell.h
//  Weird Retro
//
//  Created by User i7 on 03/02/15.
//  Copyright (c) 2015 Alex Dougas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlogPostTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel* lblDescription;
@property (strong, nonatomic) IBOutlet UILabel* lblTitle;
@property (strong, nonatomic) IBOutlet UILabel* lblDate;
@property (strong, nonatomic) IBOutlet UIImageView* imgThumbnail;

@end
