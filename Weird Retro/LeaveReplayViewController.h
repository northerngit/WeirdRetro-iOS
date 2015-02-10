//
//  LeaveReplayViewController.h
//  Weird Retro
//
//  Created by User i7 on 10/02/15.
//  Copyright (c) 2015 Alex Dougas. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BlogPost;
@class Comment;

@interface LeaveReplayViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UITextField* tfName;
@property (strong, nonatomic) IBOutlet UITextField* tfEmail;
@property (strong, nonatomic) IBOutlet UITextField* tfWebsite;
@property (strong, nonatomic) IBOutlet UITextView* tvComment;

- (IBAction)clickDone:(id)sender;
- (IBAction)clickCancel:(id)sender;

@property (strong, nonatomic) BlogPost* blogPost;
@property (strong, nonatomic) Comment* comment;


@end
