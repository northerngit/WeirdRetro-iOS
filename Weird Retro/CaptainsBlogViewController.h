//
//  EscapePodsViewController.h
//  Weird Retro
//
//  Created by User i7 on 03/02/15.
//  Copyright (c) 2015 Alex Dougas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ECSlidingViewController/ECSlidingViewController.h>
#import "RootViewController.h"

@interface CaptainsBlogViewController : RootViewController <ECSlidingViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView* tableView;

@end
