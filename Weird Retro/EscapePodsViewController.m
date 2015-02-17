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
#import "OrderedDictionary.h"

#import "RootViewController.h"
#import "Post.h"


@interface EscapePodsViewController ()

@property (nonatomic, strong) MutableOrderedDictionary *sections;

@end


@implementation EscapePodsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg"]];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadData];
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
    return 30;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (NSInteger)self.sections.allKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (NSInteger)[self.sections[self.sections.allKeys[(NSUInteger)section]] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EscapePodsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EscapePodsTableViewCell" forIndexPath:indexPath];
    
    Post* post = self.sections[self.sections.allKeys[(NSUInteger)indexPath.section]][(NSUInteger)indexPath.row];
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
        Post* post = self.sections[self.sections.allKeys[(NSUInteger)indexPath.section]][(NSUInteger)indexPath.row];
        controller.postURL = post.url;
    }
}


@end
