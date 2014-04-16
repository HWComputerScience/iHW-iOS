//
//  IHWNotificationOptionsViewController.m
//  iHW
//
//  Created by Jonathan Burns on 4/15/14.
//  Copyright (c) 2014 Jonathan Burns. All rights reserved.
//

#import "IHWNotificationOptionsViewController.h"
#import "IHWCurriculum.h"

@interface IHWNotificationOptionsViewController ()

@end

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
    if (section == 0) return 1;
    else return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notifications"];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"notifications"];
    
    if (indexPath.section == 0) {
        cell.textLabel.text = @"All Notifications";
        if (self.masterSwitch == nil) self.masterSwitch = [[UISwitch alloc] init];
        self.masterSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"allNotifications"];
        [self.masterSwitch addTarget:self action:@selector(allNotificationsChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = self.masterSwitch;
    }
    
    return cell;
}

- (void)allNotificationsChanged:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:self.masterSwitch.isOn forKey:@"allNotifications"];
    [IHWCurriculum reloadCurrentCurriculum];
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
