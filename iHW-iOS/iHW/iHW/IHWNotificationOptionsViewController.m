//
//  IHWNotificationOptionsViewController.m
//  iHW
//
//  Created by Jonathan Burns on 4/15/14.
//  Copyright (c) 2014 Jonathan Burns. All rights reserved.
//

#import "IHWNotificationOptionsViewController.h"
#import "IHWCurriculum.h"

@implementation IHWNotificationOptionsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.view = [[UITableView alloc] initWithFrame:self.navigationController.view.bounds style:style];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.navigationItem.title = @"Notifications";
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
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Currently there's only one cell in this table
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notifications"];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"notifications"];
    
    if (indexPath.section == 0) { //this doesn't matter
        cell.textLabel.text = @"All Notifications";
        if (self.masterSwitch == nil) self.masterSwitch = [[UISwitch alloc] init];
        self.masterSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"allNotifications"];
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
            //Don't allow iOS 6 users to turn on notifications because background fetch isn't supported
            //Hypotheticaly, if the user doesn't open the iHW app for a week, notifications could stop appearing because iHW doesn't have a chance to schedule new notifications. Background fetch fixes this problem in iOS 7 because iOS allows us to periodically run some code in the background to schedule notifications.
            self.masterSwitch.enabled = NO;
        }
        [self.masterSwitch addTarget:self action:@selector(allNotificationsChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = self.masterSwitch;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 64;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UITableViewHeaderFooterView *v = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"notificationHFV"];
    if (v==nil) {
        v = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"notificationHFV"];
    }
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        v.textLabel.text = @"Notifications are not supported in iOS 6.";
    } else {
        v.textLabel.text = @"When enabled, you will receive notifications at the end of your free periods if you have class next period.";
    }
    v.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    return v;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (void)allNotificationsChanged:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:self.masterSwitch.isOn forKey:@"allNotifications"];
    if (self.masterSwitch.isOn) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"seenNotifications"];
    }
    [IHWCurriculum reloadCurrentCurriculum];
}

@end
