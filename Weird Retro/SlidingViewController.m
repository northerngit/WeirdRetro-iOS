//
//  SlidingViewController.m
//  Weird Retro
//
//  Created by User i7 on 18/02/15.
//  Copyright (c) 2015 Alex Dougas. All rights reserved.
//

#import "SlidingViewController.h"

@interface SlidingViewController ()

@end

@implementation SlidingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view bringSubviewToFront:self.splashView];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}



- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ( self.splashView.alpha > 0.0f )
        [self performSelector:@selector(hidingSplash) withObject:nil afterDelay:1.3f];
}


- (void) hidingSplash
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [UIView animateWithDuration:0.2f animations:^{
        self.splashView.alpha = 0;
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
