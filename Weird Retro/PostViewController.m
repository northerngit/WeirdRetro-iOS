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
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "LeaveReplayViewController.h"
#import "ButtonURL.h"
#import <CJAMacros/CJAMacros.h>

#define HEIGHT_IMAGE_PLACEHOLDER 50
#define ELEMENTS_SPACING 10


@interface PostViewController ()
{
    CGFloat height;
    NSOperationQueue* queue;
    BOOL firstOpen;
    BOOL updatingComments;
    NSString* tmpUrlString;
}

@property (strong, nonatomic) NSManagedObject<CommonPost>* post;
@property (strong, nonatomic) UIView* commentsPlaceholder;
@property (strong, nonatomic) NSMutableArray* slidesItems;


@end


@implementation PostViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg"]];
    
    queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;

    self.slidesItems = [NSMutableArray new];

    self.post = [DATAMANAGER object:@"Post" predicate:[NSPredicate predicateWithFormat:@"url = %@", self.postURL]];
    firstOpen = NO;
    
    if ( ![self.post dateLastView] )
        firstOpen = YES;
    
    [self.post setDateLastView:[NSDate date]];
    [DATAMANAGER saveWithSuccess:nil failure:nil];
    
    if ( !self.post )
    {
        self.post = [DATAMANAGER object:@"BlogPost" predicate:[NSPredicate predicateWithFormat:@"url = %@", self.postURL]];
    }
    
    self.title = [self.post title];
    
    if ( self.post && [self.post content] )
    {
        if ( [self.post isBlogPost] )
        {
            updatingComments = YES;
            [DATAMANAGER updatingBlogPostFromBackendFile:self.postURL completion:^(NSError *error) {
                self->updatingComments = NO;
                [self refreshComments];
            }];
        }
    }
    else
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [DATAMANAGER updatingPostFromBackendFile:self.postURL completion:^(NSError *error) {
            [self reloadPost];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }];
    }
    
    
    // Navigation items
    UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped:)];
    self.navigationItem.leftBarButtonItem = backButton;
    self.navigationItem.hidesBackButton = YES;
    
    NSMutableArray* buttonsArray = [NSMutableArray new];
    if ( [self.post isBlogPost] )
    {
        UIBarButtonItem* replyButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reply"] style:UIBarButtonItemStylePlain target:self action:@selector(replyButtonTapped:)];
        [buttonsArray addObject:replyButton];
    }
    
    UIBarButtonItem* shareButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share"] style:UIBarButtonItemStylePlain target:self action:@selector(shareButtonTapped:)];
    [buttonsArray addObject:shareButton];
    
    if ( [self.post isBlogPost] )
    {
        shareButton.imageInsets = UIEdgeInsetsMake(0, 20, 0, -20);
    }
    
    self.navigationItem.rightBarButtonItems = buttonsArray;

}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadPost];
}


- (IBAction)backButtonTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}




- (IBAction)shareButtonTapped:(id)sender
{
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[UIActivityTypePostToFacebook, UIActivityTypeMessage, UIActivityTypePostToTwitter] applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:nil];
}


- (IBAction)replyButtonTapped:(id)sender
{
    LeaveReplayViewController* replyViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LeaveReplayViewController"];
    replyViewController.blogPost = (BlogPost*)self.post;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:replyViewController];
    
    navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:navController animated:YES completion:^{
    }];
}

- (void) reloadPost
{
    height = 20;

    [self.slidesItems removeAllObjects];

    for (UIView* itemViews in self.scrollView.subviews)
    {
        if ([itemViews isKindOfClass:[UIWebView class]])
            [(UIWebView*)itemViews stopLoading];
        
        [itemViews removeFromSuperview];
    }

    
    NSArray* postStructure = [self.post content];
    if ( !postStructure )
        return;
    
//    NSLog(@"%@", postStructure);
    
    if ( self.blogPost )
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
        else if ( [item[@"type"] integerValue] == 3 )
        {
            [self drawLinkItem:item];
        }
        else if ( [item[@"type"] integerValue] == 4 )
        {
            [self drawYoutube:item];
        }
        else if ( [item[@"type"] integerValue] == 5 )
        {
            [self drawSlides:item];
        }
        else if ( [item[@"type"] integerValue] == 6 )
        {
            [self drawMap:item];
        }
        else if ( [item[@"type"] integerValue] == 7 )
        {
            [self drawTitleElement:item];
        }
    }
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, height);
    
    if ( [self.post isBlogPost] )
        [self drawComments];

}


- (void) drawTitleElement:(NSDictionary*)item
{
    NSDictionary *options = kTitleTextOptions;
    NSData *data = [item[@"html"] dataUsingEncoding:NSUTF8StringEncoding];

    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithHTMLData:data options:options documentAttributes:NULL];

    DTAttributedLabel* label = [[DTAttributedLabel alloc] initWithFrame:CGRectMake(15, height, self.view.frame.size.width-30, 10000)];
    label.attributedString = attrString;
    label.delegate = self;
    label.backgroundColor = [UIColor clearColor];
    [label sizeToFit];

    [self.scrollView addSubview:label];

    height += label.frame.size.height + 20;
    
    ////////
    
    
//    UILabel* lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, height, self.view.frame.size.width-60, 300)];
//    [self.scrollView addSubview:lblTitle];
//    
//    lblTitle.font = [UIFont fontWithName:@"KomikaAxis" size:18.0];
//    lblTitle.numberOfLines = 0;
//    lblTitle.text = item[@"html"];
//    lblTitle.textAlignment = NSTextAlignmentCenter;
//    
//    CGRect rect = [item[@"html"] boundingRectWithSize:lblTitle.frame.size options:NSStringDrawingUsesLineFragmentOrigin
//                                             attributes:@{NSFontAttributeName:lblTitle.font} context:nil];
//    
//    lblTitle.frame = CGRectMake(lblTitle.frame.origin.x, lblTitle.frame.origin.y, lblTitle.frame.size.width, rect.size.height);
//    height += ELEMENTS_SPACING*2 + lblTitle.frame.size.height;
}



- (void) drawYoutube:(NSDictionary*)item
{
    UIWebView* view = [[UIWebView alloc] initWithFrame:CGRectMake(0, height, self.view.frame.size.width, 200)];
    view.hidden = YES;
    view.delegate = self;
    
    [view loadRequest:[[NSURLRequest alloc]initWithURL:[NSURL URLWithString:[@"http:" stringByAppendingString:item[@"src"]]]]];
    
    [self.scrollView addSubview:view];
    height += view.frame.size.height + ELEMENTS_SPACING;
}


- (void) drawMap:(NSDictionary*)item
{
    UIWebView* view = [[UIWebView alloc] initWithFrame:CGRectMake(0, height, self.view.frame.size.width, 250)];
    view.hidden = YES;
    view.delegate = self;
    
    [view loadRequest:[[NSURLRequest alloc]initWithURL:[NSURL URLWithString:[@"http:" stringByAppendingString:item[@"src"]]]]];
    
    [self.scrollView addSubview:view];
    height += view.frame.size.height + ELEMENTS_SPACING;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    webView.hidden = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    DLog(@"%@", error);
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

    lblTitle.font = [UIFont fontWithName:@"KomikaAxis" size:23.0];
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
    NSDictionary *options = kMainTextOptions;
    NSData *data = [item[@"description"] dataUsingEncoding:NSUTF8StringEncoding];

    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithHTMLData:data options:options documentAttributes:NULL];
    
    DTAttributedLabel* label = [[DTAttributedLabel alloc] initWithFrame:CGRectMake(15, height, self.view.frame.size.width-30, 10000)];
    label.attributedString = attrString;
    label.delegate = self;
    label.backgroundColor = [UIColor clearColor];
    [label sizeToFit];
    
    [self.scrollView addSubview:label];
    
    height += label.frame.size.height + 20;
}


- (UIView *) attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForLink:(NSURL *)url identifier:(NSString *)identifier frame:(CGRect)frame
{
    ButtonURL* buttonURL = [ButtonURL buttonWithType:UIButtonTypeCustom];
    buttonURL.frame = frame;
    buttonURL.backgroundColor = [UIColor clearColor];
    buttonURL.stringURL = url.path;
    [buttonURL addTarget:self action:@selector(clickURLButton:) forControlEvents:UIControlEventTouchUpInside];
    
    return buttonURL;
}


- (void) clickURLButton:(ButtonURL*)button
{
    if (!button.stringURL || button.stringURL.length == 0)
        return;

    NSString* urlString = button.stringURL;
    
    if ( [urlString hasPrefix:@"/captains-blog/"] )
    {
        urlString = [[NETWORK baseURL] stringByAppendingString:urlString];
    }
    
    Post* post = [DATAMANAGER object:@"Post" predicate:[NSPredicate predicateWithFormat:@"url = %@", urlString]];
    
    if ( post )
    {
        PostViewController* postController = [self.storyboard instantiateViewControllerWithIdentifier:@"PostViewer"];
        postController.postURL = urlString;
        [self.navigationController pushViewController:postController animated:YES];
    }
    else if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(_iOS_8_0) )
    {
        UIAlertController *openView = [UIAlertController alertControllerWithTitle:@"Open an External Link" message:@"This link will be opened in the Safari" preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Open" style:UIAlertActionStyleDefault  handler:^(UIAlertAction * action)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
            [openView dismissViewControllerAnimated:YES completion:nil];
        }];
        
        UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action)
        {
            [openView dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [openView addAction:ok];
        [openView addAction:cancel];
        
        [self presentViewController:openView animated:YES completion:nil];
    }
    else
    {
        tmpUrlString = urlString;
        UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"This link will be opened in the Safari" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Open", nil];
        [actionSheet showInView:self.view];
    }
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( buttonIndex == 0 )
    {
        tmpUrlString = nil;
    }
    else if ( tmpUrlString )
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:tmpUrlString]];
    }
}


- (void) drawLinkItem:(NSDictionary*)item
{
    NSDictionary *options = @{DTDefaultFontName:@"Lato-Light",
                              DTDefaultLinkColor:[UIColor colorWithRed:190.f/255.f green:160.f/255.f blue:0 alpha:1.0],
                              DTDefaultLinkDecoration:@NO,
                              DTDefaultFontSize:@12,
                              DTUseiOS6Attributes:@YES};
    
    NSData *data = [item[@"fullContent"] dataUsingEncoding:NSUTF8StringEncoding];

    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithHTMLData:data options:options documentAttributes:NULL];
    [attrString removeAttribute:@"CTForegroundColorFromContext" range:NSMakeRange(0, attrString.length)];
    [attrString removeAttribute:@"NSLink" range:NSMakeRange(0, attrString.length)];

    DTAttributedLabel* label = [[DTAttributedLabel alloc] initWithFrame:CGRectMake(95, height, self.view.frame.size.width-120, 10000)];
    label.attributedString = attrString;
    label.backgroundColor = [UIColor clearColor];
    [label sizeToFit];

    /////////
    
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, height, 60, 60)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [imageView setImageWithURL:[NSURL URLWithString:[NETWORK.baseURL stringByAppendingPathComponent:item[@"src"]]]];
    height += label.frame.size.height + 20;
    
    [self.scrollView addSubview:label];
    [self.scrollView addSubview:imageView];
    

    ButtonURL* button = [ButtonURL buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectUnion(label.frame, imageView.frame);
    [button addTarget:self action:@selector(clickURLButton:) forControlEvents:UIControlEventTouchUpInside];
    button.stringURL = item[@"link"];
    [self.scrollView addSubview:button];
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
    else
    {
        imageView.image = [[UIImageView sharedImageCache] cachedImageForRequest:request];
        
        CGFloat heightNeeded = self.view.frame.size.width * (imageView.image.size.height / imageView.image.size.width);
        if ( heightNeeded > imageView.image.size.height)
            heightNeeded = imageView.image.size.height;
        
        CGFloat widthNeeded = heightNeeded * (imageView.image.size.width / imageView.image.size.height);
        if ( widthNeeded < 200 )
            heightNeeded = 200 * (imageView.image.size.height / imageView.image.size.width);
        
        imageView.frame = CGRectMake(0, _imageView.frame.origin.y, self.view.frame.size.width, heightNeeded);
        
        height += heightNeeded + 20 - HEIGHT_IMAGE_PLACEHOLDER;
        [self.scrollView addSubview:imageView];
        return;
        
    }

    [self.scrollView addSubview:imageView];

    
    
    [imageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *requestImageView, NSHTTPURLResponse *response, UIImage *image) {

        [self->queue addOperationWithBlock:^{
            
            dispatch_queue_t mainQueue = dispatch_get_main_queue();
            dispatch_async(mainQueue, ^{
                
                CGFloat heightNeeded = self.view.frame.size.width * (image.size.height / image.size.width);
                if ( heightNeeded > image.size.height)
                    heightNeeded = image.size.height;
                
                CGFloat widthNeeded = heightNeeded * (image.size.width / image.size.height);
                if ( widthNeeded < 200 )
                    heightNeeded = 200 * (image.size.height / image.size.width);
                
                _imageView.frame = CGRectMake(0, _imageView.frame.origin.y, self.view.frame.size.width, heightNeeded);
                _imageView.image = image;

                for (UIView* subview in _imageView.subviews)
                    [subview removeFromSuperview];
                
                for (NSUInteger i = [self.scrollView.subviews indexOfObject:_imageView]+1; i < self.scrollView.subviews.count; i++)
                {
                    CGRect r = [(self.scrollView.subviews)[i] frame];
                    r.origin.y += heightNeeded + 20 - HEIGHT_IMAGE_PLACEHOLDER;
                    [(self.scrollView.subviews)[i] setFrame:r];
                }
                
                self->height += heightNeeded + 20 - HEIGHT_IMAGE_PLACEHOLDER;
                
                self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self->height);
            });
            
        }];
        
    } failure:^(NSURLRequest *requestImageView, NSHTTPURLResponse *response, NSError *error) {
        
    }];
    
}


- (void) drawSlides:(NSDictionary*)item
{
    
    CGFloat avgHeight = 0;
    for (NSDictionary* imageParameters in item[@"images"])
        if ( imageParameters[@"fullHeight"] )
        {
            CGFloat fullHeight = [imageParameters[@"fullHeight"] floatValue];
            avgHeight += fullHeight;
            avgHeight /= 2;
        }
    
    
    CGFloat minWidth = LONG_MAX;
    for (NSDictionary* imageParameters in item[@"images"])
        if ( imageParameters[@"fullWidth"] && [imageParameters[@"fullWidth"] integerValue] < minWidth )
            minWidth = [imageParameters[@"fullWidth"] floatValue];
    
    
    CGFloat resolution = minWidth / (self.view.frame.size.width * 0.8f);
    CGFloat neededHeight = avgHeight / resolution;

    
    [self.slidesItems addObject:item];
    
    
    SwipeView *swipeView = [[SwipeView alloc] initWithFrame:CGRectMake(0, height, self.view.frame.size.width, neededHeight)];
    swipeView.delegate = self;
    swipeView.dataSource = self;
    swipeView.tag = (NSInteger)self.slidesItems.count - 1;
    [self.scrollView addSubview:swipeView];

    height += ELEMENTS_SPACING*2 + swipeView.frame.size.height + 20;
}





- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    return (NSInteger)[self.slidesItems[(NSUInteger)swipeView.tag][@"images"] count];
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{

    UIImageView* imageView = [[UIImageView alloc] initWithFrame:swipeView.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    NSDictionary* params = self.slidesItems[(NSUInteger)swipeView.tag][@"images"][(NSUInteger)index];

    [imageView setImageWithURL:[NSURL URLWithString:[@"http://www.weirdretro.org.uk/uploads" stringByAppendingPathComponent:params[@"url"]]]];
    
    return imageView;
}

- (CGSize)swipeViewItemSize:(SwipeView *)swipeView
{
    return CGSizeMake(swipeView.bounds.size.width*0.8f, swipeView.bounds.size.height);
}





- (void) drawComments
{
    UILabel* lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, height, self.view.frame.size.width-60, 300)];
    [self.scrollView addSubview:lblTitle];
    
    lblTitle.font = [UIFont fontWithName:@"KomikaAxis" size:20.0];
    lblTitle.numberOfLines = 0;
    lblTitle.text = @"Comments";
    lblTitle.textAlignment = NSTextAlignmentCenter;
    
    CGRect rect = [lblTitle.text boundingRectWithSize:lblTitle.frame.size options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{NSFontAttributeName:lblTitle.font} context:nil];
    
    lblTitle.frame = CGRectMake(lblTitle.frame.origin.x, lblTitle.frame.origin.y, lblTitle.frame.size.width, rect.size.height);
    height += lblTitle.frame.size.height;

    if ( !self.commentsPlaceholder )
        self.commentsPlaceholder = [[UIView alloc] initWithFrame:CGRectMake(0, height, self.view.frame.size.width, 30)];
    else
        self.commentsPlaceholder.frame = CGRectMake(0, height, self.view.frame.size.width, self.commentsPlaceholder.frame.size.height);
    
    if ( !self.commentsPlaceholder.superview )
        [self.scrollView addSubview:self.commentsPlaceholder];
    
    [self refreshComments];
}



- (void) refreshComments
{
    if ( !self.post.isBlogPost )
        return;
    
    if ( [self.post comments] && [[self.post comments] count] )
    {
        for (UIView* subview in self.commentsPlaceholder.subviews)
            [subview removeFromSuperview];

        NSSortDescriptor* descriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
        NSArray* commentsSorted = [[self.post comments] sortedArrayUsingDescriptors:@[descriptor]];
        
        CGFloat heightComments = 5;
        
        NSDateFormatter* formatterComment = [[NSDateFormatter alloc] init];
        formatterComment.dateFormat = @"dd/MM/yyyy HH:mm";

        for (Comment* comment in commentsSorted)
        {
//            [DTCoreTextFontDescriptor setOverrideFontName:@"Lato-Bold" forFontFamily:@"Lato-Regular" bold:YES italic:NO];
            
//            CTFontRef font = CTFontCreateWithName(CFSTR("Lato-Thin"), 20, NULL);
//            NSLog(@"%@", font);
            
//            DTCoreTextFontDescriptor *newDesc = [[DTCoreTextFontDescriptor alloc] initWithCTFont:font];
//            NSLog(@"%@", [newDesc cssStyleRepresentation]);
            
            NSString* text = [NSString stringWithFormat:@"<span style='font-family: \"Lato\"; font-weight: bold; font-style: normal;'>%@</span> <span style='font-size:10.0; color:#aaa;'>(%@)</span><br/>%@", comment.name, [formatterComment stringFromDate:comment.date], comment.comment];
            NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
            
            NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithHTMLData:data options:kMainTextOptions documentAttributes:NULL];
            [attrString removeAttribute:@"CTForegroundColorFromContext" range:NSMakeRange(0, attrString.length)];
            [attrString removeAttribute:@"NSLink" range:NSMakeRange(0, attrString.length)];
            
            DTAttributedLabel* label = [[DTAttributedLabel alloc] initWithFrame:CGRectMake(20 + 15 * [comment.indent integerValue], heightComments, self.view.frame.size.width-20 - (20 + 15 * [comment.indent integerValue]), 10000)];
            label.attributedString = attrString;
            label.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
            [label sizeToFit];
            
            [self.commentsPlaceholder addSubview:label];
            
            heightComments += label.frame.size.height + 20;
        }
        
        CGRect rect = self.commentsPlaceholder.frame;
        rect.size.height = heightComments;
        self.commentsPlaceholder.frame = rect;
    }
    else if ( updatingComments )
    {
        UIActivityIndicatorView* activityComments = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityComments.center = CGPointMake(self.commentsPlaceholder.frame.size.width/2, self.commentsPlaceholder.frame.size.height/2);
        [self.commentsPlaceholder addSubview:activityComments];
        [activityComments startAnimating];
    }
    else
    {
        for (UIView* subview in self.commentsPlaceholder.subviews)
            [subview removeFromSuperview];

        NSData *data = [@"No comments yet..." dataUsingEncoding:NSUTF8StringEncoding];
        
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithHTMLData:data options:kMainTextOptions documentAttributes:NULL];
        [attrString removeAttribute:@"CTForegroundColorFromContext" range:NSMakeRange(0, attrString.length)];
        [attrString removeAttribute:@"NSLink" range:NSMakeRange(0, attrString.length)];
        
        DTAttributedLabel* label = [[DTAttributedLabel alloc] initWithFrame:CGRectMake(20, 5, self.view.frame.size.width-20 - 20, 10000)];
        label.attributedString = attrString;
        label.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
        [label sizeToFit];
        
        [self.commentsPlaceholder addSubview:label];
        CGFloat heightComments = label.frame.size.height + 20;
        CGRect rect = self.commentsPlaceholder.frame;
        rect.size.height = heightComments;
        self.commentsPlaceholder.frame = rect;
    }
    
    height = self.commentsPlaceholder.frame.origin.y + self.commentsPlaceholder.frame.size.height;
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, height);
}


@end
