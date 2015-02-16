//
//  LeaveReplayViewController.m
//  Weird Retro
//
//  Created by User i7 on 10/02/15.
//  Copyright (c) 2015 Alex Dougas. All rights reserved.
//

#import "LeaveReplayViewController.h"
#import "Managers.h"
#import "MBProgressHUD.h"

@interface LeaveReplayViewController ()

@end


@implementation LeaveReplayViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8f]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    [self.navigationController.navigationBar setTitleTextAttributes: @{
                           NSFontAttributeName: [UIFont fontWithName:@"Courier-Bold" size:18.0f],
                           NSForegroundColorAttributeName: [UIColor whiteColor] }];
    
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg"]];
    
    
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                    [UIFont fontWithName:@"Courier" size:16.0], NSFontAttributeName,
                                                                    [UIColor whiteColor], NSForegroundColorAttributeName,
                                                                    nil]
                                                          forState:UIControlStateNormal];
    
    
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                    [UIFont fontWithName:@"Courier" size:16.0], NSFontAttributeName,
                                                                    [UIColor whiteColor], NSForegroundColorAttributeName,
                                                                    nil]
                                                          forState:UIControlStateNormal];

    
    self.tfWebsite.font = [UIFont fontWithName:@"Lato-Regular" size:13];
    self.tfName.font = [UIFont fontWithName:@"Lato-Regular" size:13];
    self.tfEmail.font = [UIFont fontWithName:@"Lato-Regular" size:13];
    self.tvComment.font = [UIFont fontWithName:@"Lato-Regular" size:13];
    
    self.tfEmail.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"commentEmail"];
    self.tfName.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"commentName"];
    self.tfWebsite.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"commentWebsite"];
}


- (IBAction)clickDone:(id)sender
{
    if ( !self.tfName.text.length )
    {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:self.tfEmail.text forKey:@"commentEmail"];
    [[NSUserDefaults standardUserDefaults] setObject:self.tfName.text forKey:@"commentName"];
    [[NSUserDefaults standardUserDefaults] setObject:self.tfWebsite.text forKey:@"commentWebsite"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.view endEditing:YES];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [NETWORK replyComment:self.tvComment.text postId:self.blogPost.blogPostIdentity commentId:nil name:self.tfName.text email:self.tfEmail.text website:self.tfWebsite.text notify:NO withCompletion:^(NSError *error) {
        
        if ( !error )
        {
            Comment* comment = [DATAMANAGER object:@"Comment"];
            comment.date = [NSDate date];
            comment.indent = @0;
            comment.name = [self.tfName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            comment.comment = [self.tvComment.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            if ( self.tfWebsite.text )
                comment.link = [self.tfWebsite.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            [self.blogPost addCommentsObject:comment];
            [DATAMANAGER saveWithSuccess:^(BOOL hasChanges) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [self dismissViewControllerAnimated:YES completion:nil];
            } failure:^(NSError *error) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
            
        }
        else
        {
            UIAlertController * alert =   [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* dismissAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
             {
                 [alert dismissViewControllerAnimated:YES completion:nil];
             }];
            [alert addAction:dismissAction];
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self presentViewController:alert animated:YES completion:nil];
        }

    }];
    
}


- (IBAction)clickCancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
