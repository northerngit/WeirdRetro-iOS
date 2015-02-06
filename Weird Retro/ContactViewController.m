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



@interface ContactViewController ()
@property (nonatomic, strong) MEZoomAnimationController *transition;
@end

@implementation ContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.transition = [[MEZoomAnimationController alloc] init];
    self.slidingViewController.delegate = self.transition;
    
    self.slidingViewController.topViewAnchoredGesture = ECSlidingViewControllerAnchoredGestureTapping | ECSlidingViewControllerAnchoredGesturePanning;
    self.slidingViewController.customAnchoredGestures = @[];
    
    [self.navigationController.view addGestureRecognizer:self.slidingViewController.panGesture];
    
    UIBarButtonItem* menuButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self action:@selector(menuButtonTapped:)];
    
    self.navigationItem.leftBarButtonItem = menuButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



- (IBAction)menuButtonTapped:(id)sender {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
