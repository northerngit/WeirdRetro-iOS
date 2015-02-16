//
//  ContactViewController.m
//  Weird Retro
//
//  Created by User i7 on 07/02/15.
//  Copyright (c) 2015 Alex Dougas. All rights reserved.
//

#import "ContactViewController.h"
#import "UIViewController+ECSlidingViewController.h"
#import "MEZoomAnimationController.h"
#import "Managers.h"
#import <DTCoreText/DTCoreText.h>
#import "MBProgressHUD.h"


@interface ContactViewController ()
@property (nonatomic, strong) MEZoomAnimationController *transition;
@property (nonatomic, strong) DTAttributedLabel* headerLabel;
@property (nonatomic, strong) DTAttributedLabel* footerLabel;

@end

@implementation ContactViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.transition = [[MEZoomAnimationController alloc] init];
    self.slidingViewController.delegate = self.transition;
    
    self.slidingViewController.topViewAnchoredGesture = ECSlidingViewControllerAnchoredGestureTapping | ECSlidingViewControllerAnchoredGesturePanning;
    self.slidingViewController.customAnchoredGestures = @[];
    
    [self.navigationController.view addGestureRecognizer:self.slidingViewController.panGesture];
    
    UIBarButtonItem* menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Hamburger"] style:UIBarButtonItemStylePlain target:self action:@selector(menuButtonTapped:)];
    self.navigationItem.leftBarButtonItem = menuButton;
    
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8f]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    [self.navigationController.navigationBar setTitleTextAttributes: @{
                                                                       NSFontAttributeName: [UIFont fontWithName:@"Courier-Bold" size:18.0f],
                                                                       NSForegroundColorAttributeName: [UIColor whiteColor] }];
    
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg"]];
    
    
//    UIBarButtonItem submitButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStylePlain target:self action:@selector(sel:)];

    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Courier" size:16.0],
                                        NSForegroundColorAttributeName: [UIColor whiteColor]} 
                              forState:UIControlStateNormal];

    NSDictionary *options = kMainTextOptions;
    NSString* text = @"Have a weird question for us, a suggestion for the website, or just want to throw us a random \"Hiya!\"? Send us a message via our contact section, or email us directly at <a>weirdretro@rocketship.com</a> and we'll get back to you as soon as we land rocket ship Weird Retro.";
    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableAttributedString* headerAttrString = [[NSMutableAttributedString alloc] initWithHTMLData:data options:options documentAttributes:NULL];
    self.headerLabel = [[DTAttributedLabel alloc] initWithFrame:CGRectMake(15, 15, self.view.frame.size.width-30, 10000)];
    self.headerLabel.attributedString = headerAttrString;
    self.headerLabel.backgroundColor = [UIColor clearColor];
    [self.headerLabel sizeToFit];
    
    text = @"Note: Any questions or queries in relation to orders, please remember to quote your order number, so we can get back to you quickly.";
    data = [text dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableAttributedString* footerAttrString = [[NSMutableAttributedString alloc] initWithHTMLData:data options:options documentAttributes:NULL];
    self.footerLabel = [[DTAttributedLabel alloc] initWithFrame:CGRectMake(15, 15, self.view.frame.size.width-30, 10000)];
    self.footerLabel.attributedString = footerAttrString;
    self.footerLabel.backgroundColor = [UIColor clearColor];
    [self.footerLabel sizeToFit];
    
    self.tfFirstName.font = [UIFont fontWithName:@"Lato-Regular" size:13];
    self.tfLastName.font = [UIFont fontWithName:@"Lato-Regular" size:13];
    self.tfEmail.font = [UIFont fontWithName:@"Lato-Regular" size:13];
    
    self.tvContent.font = [UIFont fontWithName:@"Lato-Regular" size:13];
    [self.commentType.titleLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:13]];
}



- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.headerLabel.frame.size.height+ 30)];
        [view addSubview:self.headerLabel];
        return view;
    }
    
    return nil;
}


- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return self.headerLabel.frame.size.height + 30;
    }
    
    return 0;
}


- (UIView*) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 2)
    {
        UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.footerLabel.frame.size.height+ 30)];
        [view addSubview:self.footerLabel];
        return view;
    }
    
    return nil;
}


- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 2)
    {
        return self.footerLabel.frame.size.height + 30;
    }
    
    return 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



- (IBAction)menuButtonTapped:(id)sender {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}


- (IBAction)submitButtonTapped:(id)sender {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.view endEditing:YES];
    
    [NETWORK submitContactFormWithFirstName:self.tfFirstName.text lastName:self.tfLastName.text email:self.tfEmail.text type:[self.commentType titleForState:UIControlStateNormal] comment:self.tvContent.text withCompletion:^(NSError *error) {

        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        self.tvContent.text = @"";

        UIAlertController * alert =   [UIAlertController alertControllerWithTitle:@"Success" message:@"Thank you. Your information has been submitted." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* dismissAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                        {
                                            [alert dismissViewControllerAnimated:YES completion:nil];
                                        }];
        [alert addAction:dismissAction];
        
        [self presentViewController:alert animated:YES completion:nil];

        
    }];
}

@end
