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
    NSSortDescriptor* descriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    
//    DLog(@"D: %d", sections.count);

    for (Section* section in sections)
    {
        DLog(@"%@, %@", section.order, section.title);

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
    return self.sections.allKeys[section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.allKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.sections[self.sections.allKeys[section]] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EscapePodsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EscapePodsTableViewCell" forIndexPath:indexPath];
    
    if ( !cell )
        cell = [[EscapePodsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EscapePodsTableViewCell"];

    
    Post* post = self.sections[self.sections.allKeys[indexPath.section]][indexPath.row];
    
    
    cell.imgThumbnail.image = nil;
    [cell.imgThumbnail setImageWithURL:[NSURL URLWithString:[NETWORK.baseURL stringByAppendingPathComponent:post.thumbnailUrl]]];

    cell.lblTitle.text = post.title;
    CGRect rectTitle = [cell.lblTitle.text boundingRectWithSize:cell.lblTitle.frame.size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:cell.lblTitle.font} context:nil];
    cell.lblTitle.frame = CGRectMake(cell.lblTitle.frame.origin.x, cell.lblTitle.frame.origin.y, rectTitle.size.width, rectTitle.size.height);

    cell.lblDescription.text = post.info;
    cell.lblDescription.frame = CGRectMake(cell.lblDescription.frame.origin.x, 0, cell.lblDescription.frame.size.width, cell.lblDescription.frame.size.height);
    
    
    return cell;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    if ( [segue.identifier isEqualToString:@"ShowPost"])
//    {
//        UITableViewCell* cell = (UITableViewCell*)sender;
//        NSIndexPath* path = [self.tableView indexPathForCell:cell];
//        
//        PostViewController* controller = segue.destinationViewController;
//        controller.postURL = [(Post*)self.posts[path.row] url];
//    }
}


@end
