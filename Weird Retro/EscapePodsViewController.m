//
//  EscapePodsViewController.m
//  Weird Retro
//
//  Created by User i7 on 03/02/15.
//  Copyright (c) 2015 Alex Dougas. All rights reserved.
//

#import "EscapePodsViewController.h"
#import "PostViewController.h"

#import "Managers.h"
#import "EscapePodsTableViewCell.h"

#import <DTCoreText/DTCoreText.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <AFNetworking/UIKit+AFNetworking.h>
#import <HMSegmentedControl/HMSegmentedControl.h>
#import "OrderedDictionary.h"

#import "RootViewController.h"
#import "Post.h"

#import "EscapePodsFilterView.h"


@interface EscapePodsViewController ()

@property (nonatomic, strong) MutableOrderedDictionary *sections;
@property (nonatomic, strong) NSArray *lastPods;
@property (nonatomic, strong) UIView *filterPlaceholderView;
@property (nonatomic, assign) NSInteger selectedFilterIndex;

@end


@implementation EscapePodsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg"]];
    self.tableView.contentInset = UIEdgeInsetsMake(30, 0, 0, 0);
    
    self.selectedFilterIndex = 0;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadData];

    [self configureFilter];
}



- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ( self.sections.count == 0 )
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [DATAMANAGER updatingStructureFromBackendWithCompletion:^(NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [self reloadData];
    }];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.filterPlaceholderView removeFromSuperview];
    self.filterPlaceholderView = nil;
}

- (void) configureFilter
{
    if ( self.filterPlaceholderView )
        return;
    
    self.filterPlaceholderView = [[UIView alloc] initWithFrame: CGRectMake(0, 59, 302, 26)];
    self.filterPlaceholderView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.1f];
    self.filterPlaceholderView.layer.cornerRadius = self.filterPlaceholderView.frame.size.height/2.f;
    self.filterPlaceholderView.center = CGPointMake(self.view.frame.size.width/2, self.filterPlaceholderView.center.y);
    self.filterPlaceholderView.alpha = 0.0f;
    self.filterPlaceholderView.clipsToBounds = YES;
    
    HMSegmentedControl *segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"latest pods", @"memory banks"]];
    segmentedControl.frame = CGRectMake(0, 0, self.filterPlaceholderView.frame.size.width, self.filterPlaceholderView.frame.size.height);
    [segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];

    segmentedControl.backgroundColor = [UIColor clearColor];
    segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleBox;
    segmentedControl.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor],
                                              NSFontAttributeName : [UIFont fontWithName:@"CourierNewPS-BoldMT" size:13.0f]};

    segmentedControl.selectedTitleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor blackColor] };

    segmentedControl.selectionIndicatorColor = [UIColor colorWithRed:243.0f/255.0f green:200.0f/255.0f blue:0 alpha:1.0f];
    segmentedControl.selectionIndicatorBoxOpacity = 1.0f;
    
    segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationNone;
    segmentedControl.shouldAnimateUserSelection = NO;
    
    [self.filterPlaceholderView addSubview:segmentedControl];
    [self.navigationController.navigationBar.superview addSubview:self.filterPlaceholderView];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.filterPlaceholderView.alpha = 1.f;
    }];
    
}


- (void) segmentedControlChangedValue:(HMSegmentedControl*)sender
{
    self.selectedFilterIndex = sender.selectedSegmentIndex;
    [self.tableView reloadData];
}

- (void) reloadData
{
    NSArray* sections = [DATAMANAGER objects:@"Section" predicate:nil sortKey:@"order" ascending:YES];
    
    MutableOrderedDictionary* dict = [MutableOrderedDictionary dictionary];
    NSSortDescriptor* descriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    
    for (Section* section in sections)
    {
        NSArray* posts = [section.posts sortedArrayUsingDescriptors:@[descriptor]];
        dict[section.title] = posts;
    }
    
    self.sections = dict;
    
    ////////////
    
    NSArray* lastPosts = [DATAMANAGER objects:@"Post" predicate:[NSPredicate predicateWithFormat:@"orderInLast > 0"] sortKey:@"orderInLast" ascending:YES];
    self.lastPods = lastPosts;
    [self.tableView reloadData];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.sections.allKeys[(NSUInteger)section];
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel* lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    lblTitle.font = [UIFont fontWithName:@"Inconsolata" size:16.0f];
    lblTitle.textColor = [UIColor blackColor];
    lblTitle.backgroundColor = [UIColor colorWithRed:243.0f/255.0f green:200.0f/255.0f blue:0 alpha:0.8f];
    lblTitle.text = [@"  " stringByAppendingString:[self tableView:tableView titleForHeaderInSection:section]];
    
    return lblTitle;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ( self.selectedFilterIndex == 0 )
        return 0;
    else
        return 30;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ( self.selectedFilterIndex == 0 )
        return 1;
    else
        return (NSInteger)self.sections.allKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ( self.selectedFilterIndex == 0 )
        return (NSInteger)self.lastPods.count;
    else
        return (NSInteger)[self.sections[self.sections.allKeys[(NSUInteger)section]] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EscapePodsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EscapePodsTableViewCell" forIndexPath:indexPath];
    
    Post* post = nil;
    if ( self.selectedFilterIndex == 0 )
        post = self.lastPods[(NSUInteger)indexPath.row];
    else
        post = self.sections[self.sections.allKeys[(NSUInteger)indexPath.section]][(NSUInteger)indexPath.row];
    
    cell.post = post;
    
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    return cell;
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.0f;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ( [segue.identifier isEqualToString:@"ShowPost"])
    {
        UITableViewCell* cell = (UITableViewCell*)sender;
        NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
        
        PostViewController* controller = segue.destinationViewController;
        
        Post* post = nil;
        if ( self.selectedFilterIndex == 0 )
            post = self.lastPods[(NSUInteger)indexPath.row];
        else
            post = self.sections[self.sections.allKeys[(NSUInteger)indexPath.section]][(NSUInteger)indexPath.row];
        
        controller.postURL = post.url;
    }
}


@end
