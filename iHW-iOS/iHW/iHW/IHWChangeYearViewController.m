//
//  IHWChangeYearViewController.m
//  iHW
//
//  Created by Jonathan Burns on 4/15/14.
//  Copyright (c) 2014 Jonathan Burns. All rights reserved.
//

#import "IHWChangeYearViewController.h"
#import "IHWCurriculum.h"
#import "IHWAppDelegate.h"
#import "IHWScheduleViewController.h"

@interface IHWChangeYearViewController ()

@end

@implementation IHWChangeYearViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.view = [[UITableView alloc] initWithFrame:self.navigationController.view.bounds style:style];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.navigationItem.title = @"Change Year";
        //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
        self.selectedCampus = [IHWCurriculum currentCampus];
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
    if (section == 0) return 1;
    else return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"changeYear"];
        if (cell==nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"changeYear"];
        if (self.stepper == nil) {
            self.stepper = [[UIStepper alloc] init];
            self.stepper.minimumValue = 1;
            self.stepper.maximumValue = INT16_MAX;
            self.stepper.stepValue = 1;
            self.stepper.value = [IHWCurriculum currentYear];
            self.stepper.tintColor = [UIColor colorWithRed:0.6 green:0 blue:0 alpha:1];
            [self.stepper addTarget:self action:@selector(yearChanged) forControlEvents:UIControlEventValueChanged];
        }
        cell.accessoryView = self.stepper;
        cell.textLabel.text = [self formatYear:[IHWCurriculum currentYear]];
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"changeCampus"];
        if (cell==nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"changeCampus"];
        cell.tintColor = [UIColor colorWithRed:0.6 green:0 blue:0 alpha:1];
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Middle School";
            if (self.selectedCampus == CAMPUS_MIDDLE) cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.textLabel.text = @"Upper School";
            if (self.selectedCampus == CAMPUS_UPPER) cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) return 44;
    else return 24;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *view = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"changeScheduleHeader"];
    if (section == 0) view.textLabel.text = @"Year";
    else view.textLabel.text = @"Campus";
    return view;
}
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) return nil;
    else return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        if (indexPath.row == 0) self.selectedCampus = CAMPUS_MIDDLE;
        else self.selectedCampus = CAMPUS_UPPER;
        [self campusChanged];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
}

- (void)yearChanged {
    int year = self.stepper.value;
    [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]].textLabel.text = [self formatYear:year];
}

- (void)campusChanged {
    if (self.selectedCampus == CAMPUS_MIDDLE) {
        [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]].accessoryType = UITableViewCellAccessoryCheckmark;
        [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:1]].accessoryType = UITableViewCellAccessoryNone;
    } else {
        [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:1]].accessoryType = UITableViewCellAccessoryCheckmark;
        [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]].accessoryType = UITableViewCellAccessoryNone;
    }
}

- (NSString *)formatYear:(int)year {
    return [NSString stringWithFormat:@"%d-%02d", year, (year+1)%100];
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        int year = self.stepper.value;
        [IHWCurriculum setCurrentYear:year];
        [IHWCurriculum setCurrentCampus:self.selectedCampus];
        [((IHWAppDelegate *)[[UIApplication sharedApplication] delegate]).navController setViewControllers:@[[[IHWScheduleViewController alloc] initWithNibName:@"IHWScheduleViewController" bundle:nil]] animated:NO];
        //[self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    [super viewWillDisappear:animated];
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
