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
        
        //Set up navigation buttons
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(close)];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Options" style:UIBarButtonItemStylePlain target:nil action:NULL];
        self.navigationItem.title = @"iHW Options";
        
        self.items = [NSArray arrayWithObjects:
                      @[@"Notifications", @"Enable or disable notifications"],
                      @[@"Change year or campus", @"Choose school year, and select MS or US"],
                      @[@"Redownload schedule", @"Download your schedule from HW.com"],
                      @[@"Disclaimer", @"Don't blame us if you are late to class!"],
                      @[@"Credits / About iHW", @""],
                      nil];
        self.actions = [NSArray arrayWithObjects:
                        [NSValue valueWithPointer:@selector(showNotifications:)],
                        [NSValue valueWithPointer:@selector(changeYear:)],
                        [NSValue valueWithPointer:@selector(redownload:)],
                        [NSValue valueWithPointer:@selector(showDisclaimer:)],
                        [NSValue valueWithPointer:@selector(showAbout:)],
                        nil];
    }
    return self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section==0) return 3;
    else return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"preferencesCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    long index = indexPath.row;
    //get the actual overall index in the whole table
    if (indexPath.section == 1) index += 3;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    //Set the cell's text using the index
    cell.textLabel.text = [[self.items objectAtIndex:index] objectAtIndex:0];
    cell.detailTextLabel.text = [[self.items objectAtIndex:index] objectAtIndex:1];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Perform the correct selector from the `actions` array according to the overall index
    long index = indexPath.row;
    if (indexPath.section == 1) index += 3;
    SEL action = [[self.actions objectAtIndex:index] pointerValue];
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
    //Handle the "redownload schedule?" action sheet
    if (buttonIndex != 0) return;
    [((IHWAppDelegate *)[[UIApplication sharedApplication] delegate]).navController setViewControllers:@[[[IHWDownloadScheduleViewController alloc] initWithNibName:@"IHWDownloadScheduleViewController" bundle:nil]] animated:NO];
    //Close the preferences view
    [self close];
}

- (void)showDisclaimer:(NSIndexPath *)indexPath {
    [self showRTFWithTitle:@"Disclaimer" filename:@"disclaimer"];
}

- (void)showAbout:(NSIndexPath *)indexPath {
    [self showRTFWithTitle:@"Credits / About iHW" filename:@"about"];
}

- (void)showRTFWithTitle:(NSString *)title filename:(NSString *)filename {
    //create a new empty view controller and a web view
    UIViewController *vc = [[UIViewController alloc] init];
    vc.navigationItem.title = title;
    UIWebView *wv = [[UIWebView alloc] initWithFrame:self.navigationController.view.bounds];
    wv.delegate = self;
    //Load the RTF file into the web view
    NSURL *rtfUrl = [[NSBundle mainBundle] URLForResource:filename withExtension:@".rtf"];
    NSURLRequest *request = [NSURLRequest requestWithURL:rtfUrl];
    [wv loadRequest:request];
    wv.scalesPageToFit = YES;
    wv.backgroundColor = [UIColor whiteColor];
    vc.view = wv;
    //Show the view controller
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    //Open links from the RTF in Safari
    if (inType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    return YES;
}

- (void)close {
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
