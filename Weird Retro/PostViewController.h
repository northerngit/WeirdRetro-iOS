//
//  PostViewController.h
//  Weird Retro
//
//  Created by User i7 on 04/02/15.
//  Copyright (c) 2015 Alex Dougas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwipeView.h"
#import <DTCoreText/DTCoreText.h>


@protocol CommonPost <NSObject>

- (NSString*) title;
- (NSArray*) content;
- (NSSet*) comments;
- (BOOL) isBlogPost;

- (NSDate*) dateLastView;
- (void) setDateLastView:(NSDate*)dateLastView;

@end


@interface PostViewController : UIViewController <SwipeViewDelegate, SwipeViewDataSource, UIWebViewDelegate, DTAttributedTextContentViewDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView* scrollView;
@property (strong, nonatomic) NSString* postURL;

@property (assign, nonatomic) BOOL blogPost;

@end
