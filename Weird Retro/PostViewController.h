//
//  PostViewController.h
//  Weird Retro
//
//  Created by User i7 on 04/02/15.
//  Copyright (c) 2015 Alex Dougas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwipeView.h"


@protocol CommonPost <NSObject>

- (NSString*) title;
- (NSArray*) content;
- (NSSet*) comments;
- (BOOL) isBlogPost;

- (NSDate*) dateLastView;
- (void) setDateLastView:(NSDate*)dateLastView;

@end


@interface PostViewController : UIViewController <SwipeViewDelegate, SwipeViewDataSource, UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView* scrollView;
@property (strong, nonatomic) NSString* postURL;

@end
