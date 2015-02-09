//
//  ContactViewController.h
//  Weird Retro
//
//  Created by User i7 on 07/02/15.
//  Copyright (c) 2015 Alex Dougas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ECSlidingViewController/ECSlidingViewController.h>

@interface ContactViewController : UITableViewController <ECSlidingViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UITextField* tfFirstName;
@property (strong, nonatomic) IBOutlet UITextField* tfLastName;
@property (strong, nonatomic) IBOutlet UITextField* tfEmail;
@property (strong, nonatomic) IBOutlet UITextView* tvContent;
@property (strong, nonatomic) IBOutlet UIButton* commentType;

@end
