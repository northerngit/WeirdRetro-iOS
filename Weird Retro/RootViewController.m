//
//  RootViewController.m
//  Weird Retro
//
//  Created by User i7 on 05/02/15.
//  Copyright (c) 2015 Alex Dougas. All rights reserved.
//

#import "RootViewController.h"
#import "UIViewController+ECSlidingViewController.h"
#import "MEZoomAnimationController.h"


@interface RootViewController ()
@property (nonatomic, strong) MEZoomAnimationController *transition;
@end

@implementation RootViewController

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


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}


@end
