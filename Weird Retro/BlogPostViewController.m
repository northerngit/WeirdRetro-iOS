//
//  PostViewController.m
//  Weird Retro
//
//  Created by User i7 on 04/02/15.
//  Copyright (c) 2015 Alex Dougas. All rights reserved.
//

#import "Managers.h"

#import "BlogPostViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <DTCoreText/DTCoreText.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

#define HEIGHT_IMAGE_PLACEHOLDER 50
#define ELEMENTS_SPACING 10


@interface BlogPostViewController ()
{
    CGFloat height;
    NSOperationQueue* queue;
}

@end


@implementation BlogPostViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    height = 20;
    queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
    
    self.post = [DATAMANAGER object:@"BlogPost" predicate:[NSPredicate predicateWithFormat:@"url = %@", self.postURL]];
    
    self.title = self.post.title;
    
    if ( self.post && self.post.content )
    {
        [self reloadPost];
    }
    else
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [DATAMANAGER updatingPostFromBackendFile:self.postURL completion:^(NSError *error) {
            [self reloadPost];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }];
    }
    
    UIBarButtonItem* menuButtonSharing = [[UIBarButtonItem alloc] initWithTitle:@"S" style:UIBarButtonItemStylePlain target:self action:@selector(shareButtonTapped:)];
    UIBarButtonItem* menuButtonComments = [[UIBarButtonItem alloc] initWithTitle:@"C" style:UIBarButtonItemStylePlain target:self action:@selector(commentsButtonTapped:)];
    self.navigationItem.rightBarButtonItems = @[menuButtonSharing, menuButtonComments];
}



- (IBAction)shareButtonTapped:(id)sender
{
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[UIActivityTypePostToFacebook, UIActivityTypeMessage, UIActivityTypePostToTwitter] applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:nil];
}


- (IBAction)commentsButtonTapped:(id)sender
{
}



- (void) reloadPost
{
    NSArray* postStructure = self.post.content;
    if ( !postStructure )
        return;
    
    [self drawTitle];
    
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
        else if ( [item[@"type"] integerValue] == 2 )
        {
            [self drawSeparator];
        }
    }
    
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, height);
}



- (void) drawSeparator
{
    UIView* separator = [[UIView alloc] initWithFrame:CGRectMake(10, height, self.view.frame.size.width-20, 1)];
    [self.scrollView addSubview:separator];
    
    separator.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    height += separator.frame.size.height + 20;
}


- (void) drawTitle
{
    UILabel* lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, height, self.view.frame.size.width-60, 300)];
    [self.scrollView addSubview:lblTitle];

    lblTitle.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:23.0];
    lblTitle.numberOfLines = 0;
    lblTitle.text = self.post.title;
    lblTitle.textAlignment = NSTextAlignmentCenter;
    
    CGRect rect = [self.post.title boundingRectWithSize:lblTitle.frame.size options:NSStringDrawingUsesLineFragmentOrigin
                               attributes:@{NSFontAttributeName:lblTitle.font} context:nil];
    
    lblTitle.frame = CGRectMake(lblTitle.frame.origin.x, lblTitle.frame.origin.y, lblTitle.frame.size.width, rect.size.height);
    height += ELEMENTS_SPACING*2 + lblTitle.frame.size.height;
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
}


- (void) drawImageItem:(NSDictionary*)item
{
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, height, self.view.frame.size.width, HEIGHT_IMAGE_PLACEHOLDER)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;

    height += HEIGHT_IMAGE_PLACEHOLDER;
    
    __weak UIImageView* _imageView = imageView;
    
    NSURLRequest* request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:[NETWORK.baseURL stringByAppendingPathComponent:item[@"src"]]]];

    if ( ![[UIImageView sharedImageCache] cachedImageForRequest:request] )
    {
        UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [imageView addSubview:indicator];
        indicator.center = CGPointMake(imageView.frame.size.width/2, imageView.frame.size.height/2);
        [indicator startAnimating];
    }

    [self.scrollView addSubview:imageView];

    
//    NSLog(@"%@", item);
    
    
    [imageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {

        [queue addOperationWithBlock:^{
            
            dispatch_queue_t mainQueue = dispatch_get_main_queue();
            dispatch_async(mainQueue, ^{
                
                CGFloat heightNeeded = self.view.frame.size.width * (image.size.height / image.size.width);
                heightNeeded = heightNeeded/1.5;

                _imageView.frame = CGRectMake(0, _imageView.frame.origin.y, self.view.frame.size.width, heightNeeded);
                _imageView.image = image;

                for (UIView* subview in _imageView.subviews)
                    [subview removeFromSuperview];
                
                for (NSUInteger i = [self.scrollView.subviews indexOfObject:_imageView]+1; i < self.scrollView.subviews.count; i++)
                {
                    CGRect r = [[self.scrollView.subviews objectAtIndex:i] frame];
                    r.origin.y += heightNeeded + 20 - HEIGHT_IMAGE_PLACEHOLDER;
                    [[self.scrollView.subviews objectAtIndex:i] setFrame:r];
                }
                
                height += heightNeeded + 20 - HEIGHT_IMAGE_PLACEHOLDER;
                self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, height);
            });
            
            
        }];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
    
}

@end
