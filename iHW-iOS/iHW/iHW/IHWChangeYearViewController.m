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
#import "IHWFirstRunViewController.h"

@implementation IHWChangeYearViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.view = [[UITableView alloc] initWithFrame:self.navigationController.view.bounds style:style];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.navigationItem.title = @"Change Year";
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
        //Create the "change year" cell
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"changeYear"];
        if (cell==nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"changeYear"];
        if (self.stepper == nil) {
            //Create a stepper
            self.stepper = [[UIStepper alloc] init];
            self.stepper.minimumValue = 1;
            self.stepper.maximumValue = INT16_MAX;
            self.stepper.stepValue = 1;
            self.stepper.value = [IHWCurriculum currentYear];
            self.stepper.tintColor = [UIColor colorWithRed:0.6 green:0 blue:0 alpha:1];
            [self.stepper addTarget:self action:@selector(yearChanged) forControlEvents:UIControlEventValueChanged];
        }
        //Add the stepper to the right side of the cell
        cell.accessoryView = self.stepper;
        cell.textLabel.text = [self formatYear:[IHWCurriculum currentYear]];
        return cell;
    } else {
        //Create the "change campus" cells
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"changeCampus"];
        if (cell==nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"changeCampus"];
        cell.tintColor = [UIColor colorWithRed:0.6 green:0 blue:0 alpha:1];
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Middle School";
            if (self.selectedCampus == CAMPUS_MIDDLE) {
                //Add a checkmark if necessary
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        } else {
            cell.textLabel.text = @"Upper School";
            if (self.selectedCampus == CAMPUS_UPPER) {
                //Add a checkmark if necessary
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    //Adjust the spacing before and between cells
    if (section == 0) return 44;
    else return 24;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"changeScheduleHeader"];
    if (view == nil) {
        view = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"changeScheduleHeader"];
    }
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
        //Handle changing campus
        if (indexPath.row == 0) self.selectedCampus = CAMPUS_MIDDLE;
        else self.selectedCampus = CAMPUS_UPPER;
        [self campusChanged];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
}

- (void)yearChanged {
    int year = self.stepper.value;
    //Update year cell text
    [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]].textLabel.text = [self formatYear:year];
}

- (void)campusChanged {
    //Update checkmarks
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

- (void)viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        //Save updated campus and year
        int year = self.stepper.value;
        [IHWCurriculum setCurrentYear:year];
        [IHWCurriculum setCurrentCampus:self.selectedCampus];
        //Create a new schedule view controller
        //(this is not shown immediately -- instead, it appears behind the preferences view controller when the preferences view controller is dismissed)
        if ([IHWCurriculum isFirstRun]) {
            IHWFirstRunViewController *frvc = [[IHWFirstRunViewController alloc] initWithNibName:@"IHWFirstRunViewController" bundle:nil];
            frvc.goingToStep2 = YES;
            [((IHWAppDelegate *)[[UIApplication sharedApplication] delegate]).navController setViewControllers:@[frvc] animated:NO];
        } else {
            [((IHWAppDelegate *)[[UIApplication sharedApplication] delegate]).navController setViewControllers:@[[[IHWScheduleViewController alloc] initWithNibName:@"IHWScheduleViewController" bundle:nil]] animated:NO];
        }
    }
    [super viewWillDisappear:animated];
}

@end
