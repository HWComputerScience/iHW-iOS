//
//  IHWPreferencesViewController.m
//  iHW
//
//  Created by Jonathan Burns on 4/14/14.
//  Copyright (c) 2014 Jonathan Burns. All rights reserved.
//

#import "IHWPreferencesViewController.h"
#import "IHWCurriculum.h"
#import "IHWAppDelegate.h"
#import "IHWScheduleViewController.h"
#import "IHWDownloadScheduleViewController.h"
#import "IHWChangeYearViewController.h"
#import "IHWNotificationOptionsViewController.h"

@implementation IHWPreferencesViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.view = [[UITableView alloc] initWithFrame:self.navigationController.view.bounds style:style];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(close)];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Options" style:UIBarButtonItemStylePlain target:nil action:NULL];
        self.navigationItem.title = @"iHW Options";
        self.items = [NSArray arrayWithObjects:
                      @[@"Notifications", @"Enable or disable notifications"],
                      @[@"Change year or campus", @"Choose school year, and select MS or US"],
                      @[@"Redownload schedule", @"Download your schedule from HW.com"],
                      @[@"Disclaimer", @"Don't blame us if you are late to class!"],
                      nil];
        self.actions = [NSArray arrayWithObjects:
                        [NSValue valueWithPointer:@selector(showNotifications:)],
                        [NSValue valueWithPointer:@selector(changeYear:)],
                        [NSValue valueWithPointer:@selector(redownload:)],
                        [NSValue valueWithPointer:@selector(showDisclaimer:)],
                        nil];
    }
    return self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"preferencesCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    cell.textLabel.text = [[self.items objectAtIndex:indexPath.row] objectAtIndex:0];
    cell.detailTextLabel.text = [[self.items objectAtIndex:indexPath.row] objectAtIndex:1];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SEL action = [[self.actions objectAtIndex:indexPath.row] pointerValue];
    if (action != NULL) {
        [self performSelectorOnMainThread:action withObject:indexPath waitUntilDone:YES];
    }
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
}

- (void)showNotifications:(NSIndexPath *)indexPath {
    [self.navigationController pushViewController:[[IHWNotificationOptionsViewController alloc] initWithStyle:UITableViewStyleGrouped] animated:YES];
}

- (void)changeYear:(NSIndexPath *)indexPath {
    [self.navigationController pushViewController:[[IHWChangeYearViewController alloc] initWithStyle:UITableViewStyleGrouped] animated:YES];
}

- (void)redownload:(NSIndexPath *)indexPath {
    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to delete your courses and redownload them from HW.com?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Continue" otherButtonTitles:nil];
    [as showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != 0) return;
    [((IHWAppDelegate *)[[UIApplication sharedApplication] delegate]).navController setViewControllers:@[[[IHWDownloadScheduleViewController alloc] initWithNibName:@"IHWDownloadScheduleViewController" bundle:nil]] animated:NO];
    [self close];
}

- (void)showDisclaimer:(NSIndexPath *)indexPath {
    UIViewController *vc = [[UIViewController alloc] init];
    vc.navigationItem.title = @"Disclaimer";
    UIWebView *wv = [[UIWebView alloc] initWithFrame:self.navigationController.view.bounds];
    wv.delegate = self;
    NSURL *rtfUrl = [[NSBundle mainBundle] URLForResource:@"disclaimer" withExtension:@".rtf"];
    NSURLRequest *request = [NSURLRequest requestWithURL:rtfUrl];
    [wv loadRequest:request];
    wv.scalesPageToFit = YES;
    wv.backgroundColor = [UIColor whiteColor];
    vc.view = wv;
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if (inType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    return YES;
}

- (void)close {
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
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
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
