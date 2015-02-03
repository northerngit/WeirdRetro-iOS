//
//  PostViewController.m
//  Weird Retro
//
//  Created by User i7 on 04/02/15.
//  Copyright (c) 2015 Alex Dougas. All rights reserved.
//

#import "Managers.h"

#import "PostViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <DTCoreText/DTCoreText.h>
#import <AFNetworking/UIImageView+AFNetworking.h>


@interface PostViewController ()
{
    CGFloat height;
}

@end


@implementation PostViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    height = 20;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [DATAMANAGER updatingPostFromBackendFile:self.postURL completion:^(NSError *error) {
        [self reloadPost];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
    
}


- (void) reloadPost
{
    NSArray* postStructure = DATAMANAGER.posts[self.postURL];
    if ( !postStructure )
        return;
    
    for (NSDictionary* item in postStructure)
    {
        if ( [item[@"type"] integerValue] == 0 )
        {
            [self drawTextItem:item];
        }
        else if ( [item[@"type"] integerValue] == 1 )
        {
            [self drawImageItem:item];
        }
    }
    
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, height);
}


- (void) drawTextItem:(NSDictionary*)item
{
    NSDictionary *options = @{DTDefaultFontName:@"HelveticaNeue-Light",
                              DTDefaultLinkColor:[UIColor redColor],
                              DTDefaultLinkDecoration:@NO,
                              DTDefaultFontSize:@13,
                              DTUseiOS6Attributes:@YES};
    
    NSData *data = [item[@"description"] dataUsingEncoding:NSUTF8StringEncoding];

    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithHTMLData:data options:options documentAttributes:NULL];
    [attrString removeAttribute:@"CTForegroundColorFromContext" range:NSMakeRange(0, attrString.length)];
    [attrString removeAttribute:@"NSLink" range:NSMakeRange(0, attrString.length)];
    
    DTAttributedLabel* label = [[DTAttributedLabel alloc] initWithFrame:CGRectMake(15, height, self.view.frame.size.width-30, 10000)];
    label.attributedString = attrString;
    [label sizeToFit];
    
    [self.scrollView addSubview:label];
    
    height += label.frame.size.height + 20;
    
//    DTCoreTextLayouter* layouter = [[DTCoreTextLayouter alloc] initWithAttributedString:attrString];
//    DTCoreTextLayoutFrame* frame = [layouter layoutFrameWithRect:CGRectMake(0, 0, 320, 1000) range:NSMakeRange(0, 0)];
//    NSLog(@"%f", );
}


- (void) drawImageItem:(NSDictionary*)item
{
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, height, self.view.frame.size.width, self.view.frame.size.width-30)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [imageView setImageWithURL:[NSURL URLWithString:[NETWORK.baseURL stringByAppendingPathComponent:item[@"src"]]]];
    
    [self.scrollView addSubview:imageView];
    
    height += imageView.frame.size.height + 20;

    
    //    DTCoreTextLayouter* layouter = [[DTCoreTextLayouter alloc] initWithAttributedString:attrString];
    //    DTCoreTextLayoutFrame* frame = [layouter layoutFrameWithRect:CGRectMake(0, 0, 320, 1000) range:NSMakeRange(0, 0)];
    //    NSLog(@"%f", );
}



@end
