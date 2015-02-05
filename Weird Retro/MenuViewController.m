//
//  MenuViewController.m
//  Weird Retro
//
//  Created by User i7 on 03/02/15.
//  Copyright (c) 2015 Alex Dougas. All rights reserved.
//

#import "MenuViewController.h"
#import "UIViewController+ECSlidingViewController.h"

@interface MenuViewController ()
@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, strong) UINavigationController *transitionsNavigationController;
@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // topViewController is the transitions navigation controller at this point.
    // It is initially set as a User Defined Runtime Attributes in storyboards.
    // We keep a reference to this instance so that we can go back to it without losing its state.
    self.transitionsNavigationController = (UINavigationController *)self.slidingViewController.topViewController;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}


- (IBAction)clickMenuItem:(UIButton*)sender
{
    switch ( sender.tag ) {
        case 0:
            self.slidingViewController.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EscapePodsViewController"];
            break;
        case 1:
            self.slidingViewController.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CaptainsBlogViewController"];
            break;
            
        default:
            break;
    }
    
    [self.slidingViewController resetTopViewAnimated:YES];
}



#pragma mark - Properties

//- (NSArray *)menuItems {
//    if (_menuItems) return _menuItems;
//    
//    _menuItems = @[@"Transitions", @"Settings"];
//    
//    return _menuItems;
//}
//
//#pragma mark - UITableViewDataSource
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return self.menuItems.count;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    static NSString *CellIdentifier = @"MenuCell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    
//    NSString *menuItem = self.menuItems[indexPath.row];
//    
//    cell.textLabel.text = menuItem;
//    [cell setBackgroundColor:[UIColor clearColor]];
//    
//    return cell;
//}
//
//#pragma mark - UITableViewDelegate
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSString *menuItem = self.menuItems[indexPath.row];
//    
//    // This undoes the Zoom Transition's scale because it affects the other transitions.
//    // You normally wouldn't need to do anything like this, but we're changing transitions
//    // dynamically so everything needs to start in a consistent state.
//    self.slidingViewController.topViewController.view.layer.transform = CATransform3DMakeScale(1, 1, 1);
//    
//    if ([menuItem isEqualToString:@"Transitions"]) {
//        self.slidingViewController.topViewController = self.transitionsNavigationController;
//    } else if ([menuItem isEqualToString:@"Settings"]) {
//        self.slidingViewController.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MESettingsNavigationController"];
//    }
//    
//        
//    [self.slidingViewController resetTopViewAnimated:YES];
//}

@end
