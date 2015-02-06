//
//  PostViewController.h
//  Weird Retro
//
//  Created by User i7 on 04/02/15.
//  Copyright (c) 2015 Alex Dougas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlogPost.h"


@interface BlogPostViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIScrollView* scrollView;
@property (strong, nonatomic) NSString* postURL;
@property (strong, nonatomic) BlogPost* post;


@end
