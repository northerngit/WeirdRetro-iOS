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

#import "RootViewController.h"
#import "Post.h"

@interface EscapePodsViewController ()
@property (nonatomic, strong) NSArray *posts;
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
    
    if ( self.posts.count == 0 )
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [DATAMANAGER updatingStructureFromBackendWithCompletion:^(NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [self reloadData];
    }];
    
}

- (void) reloadData
{
    self.posts = [DATAMANAGER objects:@"Post"];
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.posts.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EscapePodsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EscapePodsTableViewCell" forIndexPath:indexPath];
    
    if ( !cell )
    {
        cell = [[EscapePodsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EscapePodsTableViewCell"];
    }

    Post* post = self.posts[indexPath.row];
    
//    NSString *html = self.posts[indexPath.row];
//    NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
//
//    NSDictionary *options = @{DTDefaultFontName:@"HelveticaNeue-Light",
//                              DTDefaultLinkColor:[UIColor redColor],
//                              DTDefaultLinkDecoration:@NO,
//                              DTDefaultFontSize:@13,
//                              DTUseiOS6Attributes:@YES};
//
//    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithHTMLData:data options:options documentAttributes:NULL];
//    [attrString removeAttribute:@"CTForegroundColorFromContext" range:NSMakeRange(0, attrString.length)];
//    [attrString removeAttribute:@"NSLink" range:NSMakeRange(0, attrString.length)];
    
    cell.imgThumbnail.image = nil;
    [cell.imgThumbnail setImageWithURL:[NSURL URLWithString:[NETWORK.baseURL stringByAppendingPathComponent:post.thumbnailUrl]]];
    
    //    __block NSRange foundRange = NSMakeRange(NSNotFound, 0);
    //    [attrString enumerateAttribute:DTLinkAttribute inRange:NSMakeRange(0, [attrString length]) options:0 usingBlock:^(NSString *value, NSRange range, BOOL *stop) {
    //
    //        *stop = YES;
    //        foundRange = range;
    //
    //    }];
    //
    //

    cell.lblTitle.text = post.title;
    CGRect rectTitle = [cell.lblTitle.text boundingRectWithSize:cell.lblTitle.frame.size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:cell.lblTitle.font} context:nil];
    cell.lblTitle.frame = CGRectMake(cell.lblTitle.frame.origin.x, cell.lblTitle.frame.origin.y, rectTitle.size.width, rectTitle.size.height);

//    DLog(@"%f", cell.lblTitle.frame.size.height + cell.lblTitle.frame.origin.y);
//    cell.lblTitle.frame.origin.y + cell.lblTitle.frame.size.height + 5
    
    cell.lblDescription.text = post.info;
    cell.lblDescription.frame = CGRectMake(cell.lblDescription.frame.origin.x, 0, cell.lblDescription.frame.size.width, cell.lblDescription.frame.size.height);
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ( [segue.identifier isEqualToString:@"ShowPost"])
    {
        UITableViewCell* cell = (UITableViewCell*)sender;
        NSIndexPath* path = [self.tableView indexPathForCell:cell];
        
        PostViewController* controller = segue.destinationViewController;
        controller.postURL = [(Post*)self.posts[path.row] url];
    }
}


@end
