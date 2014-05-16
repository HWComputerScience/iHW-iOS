//
//  IHWEditCourseViewController.m
//  iHW
//
//  Created by Jonathan Burns on 8/14/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import "IHWEditCourseViewController.h"
#import "IHWCurriculum.h"
#import "IHWCheckboxCell.h"
#import "IHWLabelCell.h"
#import "IHWPeriodsChooserLayout.h"
#import "IHWUtils.h"
#import "ActionSheetStringPicker.h"

@implementation IHWEditCourseViewController

- (id)initWithCourse:(IHWCourse *)course
{
    self = [super initWithNibName:@"IHWEditCourseViewController" bundle:nil];
    if (self) {
        //Load the necessary TableViewCells
        self.cells = [[NSBundle mainBundle] loadNibNamed:@"IHWEditCourseCells" owner:self options:nil];
        
        self.course = course;
        //Make the default period -1 so that all periods are out of bounds (-2, -1, 0) (see below)
        self.period = -1;
        self.term = TERM_FULL_YEAR;
        if (self.course != nil) {
            self.navigationItem.title = self.course.name;
            self.period = self.course.period;
            self.term = self.course.term;
        } else {
            self.navigationItem.title = @"Add Course";
        }
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelCourse)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveCourse)];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:@"UIKeyboardWillShowNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:@"UIKeyboardWillHideNotification" object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.originalInsetTop = 0;
    
    if (self.course != nil) {
        //Populate the UI with values from the course
        self.nameField.text = self.course.name;
        self.periodField.text = [NSString stringWithFormat:@"%d", self.course.period];
        //Create the delete button
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
            self.deleteButton = [[GradientButton alloc] initWithFrame:CGRectMake(0, 0, 300, 44)];
            [(GradientButton *)self.deleteButton useRedDeleteStyle];
        } else {
            self.deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 300, 44)];
            [self.deleteButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            [self.deleteButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
            [self.deleteButton setTitleColor:[UIColor redColor] forState:UIControlStateDisabled];
        }
        [self.deleteButton setTitle:@"Delete Course" forState:UIControlStateNormal];
        [self.deleteButton setTitle:@"Delete Course" forState:UIControlStateHighlighted];
        [self.deleteButton setTitle:@"Delete Course" forState:UIControlStateDisabled];
        [self.deleteButton addTarget:self action:@selector(showDeleteCoursePopup) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self.nameField becomeFirstResponder];
    }
    self.termField.text = stringForTerm(self.term);
    
    //Set up the bar that appears above the number pad when editing the period number
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        toolbar.barStyle = UIBarStyleBlackTranslucent;
    } else {
        self.tableView.separatorInset = UIEdgeInsetsZero;
        self.originalInsetTop = 64;
        toolbar.barTintColor = [UIColor colorWithRed:0.6 green:0 blue:0 alpha:1];
        toolbar.tintColor = [UIColor whiteColor];
    }
    [toolbar setItems:@[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil], [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(resignPeriodField)]] animated:YES];
    self.periodField.inputAccessoryView = toolbar;
    
    self.nameField.delegate = self;
    self.periodField.delegate = self;
    self.termField.delegate = self;
    
    //Somehow this UICollectionView creates a grid of checkboxes (I forgot how)
    self.meetingsChooserView.delegate = self;
    self.meetingsChooserView.dataSource = self;
    [self.meetingsChooserView registerClass:[IHWCheckboxCell class] forCellWithReuseIdentifier:@"checkbox"];
    [self.meetingsChooserView registerClass:[IHWLabelCell class] forCellWithReuseIdentifier:@"label"];
    self.meetingsChooserView.collectionViewLayout = [[IHWPeriodsChooserLayout alloc] initWithNumDays:[IHWCurriculum currentCampus]];
    self.meetingsChooserView.backgroundColor = [UIColor clearColor];
}

- (void)resignPeriodField {
    [self.periodField resignFirstResponder];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.course == nil) return 2;
    return 3; //One extra for the delete button
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section==0) return 2;
    else return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section > 0) {
        return [[self.cells objectAtIndex:indexPath.section+1] frame].size.height;
    }
    return [[self.cells objectAtIndex:indexPath.row] frame].size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return [self.cells objectAtIndex:2];
    } else if (indexPath.section == 2) {
        UITableViewCell *cell = [self.cells objectAtIndex:3];
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
            cell.backgroundColor = [UIColor clearColor];
        }
        [cell.contentView addSubview:self.deleteButton];
        return cell;
    }
    return [self.cells objectAtIndex:indexPath.row];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (void)cancelCourse {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveCourse {    
    //construct meetings array
    NSMutableArray *meetings = [NSMutableArray array];
    for (int i=1; i<=[IHWCurriculum currentCurriculum].campus; i++) {
        //For each day...
        BOOL thisPeriodChecked = ((IHWCheckboxCell *)[self.meetingsChooserView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:2]]).checked;
        BOOL beforePeriodChecked = ((IHWCheckboxCell *)[self.meetingsChooserView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1]]).checked;
        BOOL afterPeriodChecked = ((IHWCheckboxCell *)[self.meetingsChooserView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:3]]).checked;
        //...add the correct meeting to the array
        if (!thisPeriodChecked) [meetings addObject:[NSNumber numberWithInt:MEETING_X_DAY]];
        else if (beforePeriodChecked) [meetings addObject:[NSNumber numberWithInt:MEETING_DOUBLE_BEFORE]];
        else if (afterPeriodChecked) [meetings addObject:[NSNumber numberWithInt:MEETING_DOUBLE_AFTER]];
        else [meetings addObject:[NSNumber numberWithInt:MEETING_SINGLE_PERIOD]];
    }
    //Create the course
    IHWCourse *course = [[IHWCourse alloc] initWithName:self.nameField.text period:self.period term:self.term meetings:meetings];
    
    //The course has some problem
    if ([self.nameField.text isEqualToString:@""] || course.totalMeetings == 0) {
        [[[UIAlertView alloc] initWithTitle:@"Invalid Course" message:@"The course must have a name and at least one class meeting. Please edit the course and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
    //If we're replacing the old course, remove the old one first
    if (self.course != nil) [[IHWCurriculum currentCurriculum] removeCourse:self.course];
    if (![[IHWCurriculum currentCurriculum] addCourse:course]) {
        //Course wasn't added because courses conflict
        [[[UIAlertView alloc] initWithTitle:@"Courses Conflict!" message:@"The course period and meetings you selected conflict with one or more of your existing courses. Please change the course period or meetings and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        //Restore the old course since we couldn't add the new one
        if (self.course != nil) [[IHWCurriculum currentCurriculum] addCourse:self.course];
    } else {
        //Course was added successfully
        [[IHWCurriculum currentCurriculum] saveCourses];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)showDeleteCoursePopup {
    [[[UIActionSheet alloc] initWithTitle:@"Are you sure you want to delete this course?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Course" otherButtonTitles:nil] showInView:self.view];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    //Do some crazy math to shrink the UITableView content so that it fits above the keyboard
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [self.view convertRect:[aValue CGRectValue] fromView:nil];
    CGRect intersection = CGRectIntersection(keyboardRect, self.tableView.frame);
    
    [UIView animateWithDuration:0.2 animations:^{
        self.tableView.contentInset = UIEdgeInsetsMake(self.originalInsetTop, 0, intersection.size.height, 0);
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(self.originalInsetTop, 0, intersection.size.height, 0);
    }];
    /*int offset = 0;
    if (self.periodField.isFirstResponder) offset = self.periodField.inputAccessoryView.frame.size.height;
    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height-intersection.size.height+offset);*/
}

- (void)keyboardWillHide:(NSNotification *)notification {
    //Reset the UITableView content insets to fit the entire screen
    [UIView animateWithDuration:0.25 animations:^{
        self.tableView.contentInset = UIEdgeInsetsMake(self.originalInsetTop, 0, 0, 0);
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(self.originalInsetTop, 0, 0, 0);
    }];
    //self.tableView.frame = self.view.bounds;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *resultString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (textField == self.nameField) {
        //Set the navigation bar title
        if (![resultString isEqualToString:@""]) self.navigationItem.title = resultString;
        else if (self.course == nil) self.navigationItem.title = @"Add Course";
        else self.navigationItem.title = @"Edit Course";
        return YES;
    } else if (textField == self.periodField) {
        //Set the current selected period and update the grid
        int newPeriod = resultString.intValue;
        if ([resultString isEqualToString:@""]) {
            self.period = -1;
            [self updatePeriodsChooser];
            return YES;
        } else if (newPeriod < 1 || newPeriod > [IHWCurriculum currentCampus]+3) {
            //The period number that was entered is not valid - reject the change
            return NO;
        }
        self.period = newPeriod;
        [self updatePeriodsChooser];
        return YES;
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.termField) {
        //Don't actually edit the term field as text -- instead, show an Action Sheet with options
        [self.nameField resignFirstResponder];
        [self.periodField resignFirstResponder];
        [ActionSheetStringPicker showPickerWithTitle:@"Select Term" rows:@[@"Full Year", @"First Semester", @"Second Semester", @"First Trimester", @"Second Trimester", @"Third Trimester"] initialSelection:self.term doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            self.termField.text = stringForTerm((int)selectedIndex);
            self.term = (int)selectedIndex;
        } cancelBlock:nil origin:self.view];
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //Makes the Done button on the keyboard hide the keyboard
    self.tableView.frame = self.view.bounds;
    [textField resignFirstResponder];
    return YES;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //Respond to the "delete course" confirmation sheet
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        //Delete the course
        [[IHWCurriculum currentCurriculum] removeCourse:self.course];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)updatePeriodsChooser {
    int numDays = [IHWCurriculum currentCampus];
    for (int day = 0; day <= numDays; day++) {
        //Loop through the heading column
        //             and each day of the cycle...
        for (int periodIndex = 0; periodIndex <= 3; periodIndex++) {
            //Loop through the heading row,
            //             the period before,
            //             the period of,
            //         and the period after this course
            UICollectionViewCell *cell = [self.meetingsChooserView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:day inSection:periodIndex]];
            //Find the period number of this period
            int thisPeriod = self.period+periodIndex-2;
            if (day==0 && periodIndex > 0) {
                //Day==0 means we're looping through the heading column
                if (thisPeriod < 1 || thisPeriod > [IHWCurriculum currentCampus]+3) {
                    //Period is out of bounds
                    cell.hidden = YES;
                } else {
                    //Period is in bounds -- show the heading with ordinal text (1st, 2nd, 3rd...)
                    cell.hidden = NO;
                    ((IHWLabelCell *)cell).textLabel.text = getOrdinal(thisPeriod);
                }
            } else if (day > 0 && periodIndex > 0) {
                //We're looping through one of the actual days
                if (thisPeriod < 1 || thisPeriod > [IHWCurriculum currentCampus]+3) {
                    //Period is out of bounds -- reset and hide the checkbox
                    [(IHWCheckboxCell *)cell setChecked:NO];
                    cell.hidden = YES;
                } else {
                    //Period is in bounds -- reset and show the checkbox
                    cell.hidden = NO;
                    ((IHWCheckboxCell *)cell).checked = NO;
                }
            }
        }
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //Number of columns
    return [IHWCurriculum currentCampus]+1;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    //Number of rows
    return 4;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 0 && indexPath.row != 0) {
        //This cell should be a checkbox
        IHWCheckboxCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"checkbox" forIndexPath:indexPath];
        long thisPeriod = self.period+indexPath.section-2;
        if (thisPeriod < 1 || thisPeriod > [IHWCurriculum currentCampus]+3) {
            //This checkbox is currently out of bounds
            cell.shouldHideOnAppear = YES;
        } else {
            //This checkbox is in bounds -- check the checkbox if necessary
            int meeting = [self.course meetingOn:(int)indexPath.row];
            if (meeting != MEETING_X_DAY) {
                if (thisPeriod == self.period) cell.checked = YES;
            }
            if (meeting == MEETING_DOUBLE_BEFORE) {
                if (thisPeriod == self.period-1) cell.checked = YES;
            } else if (meeting == MEETING_DOUBLE_AFTER) {
                if (thisPeriod == self.period+1) cell.checked = YES;
            }
        }
        cell.delegate = self;
        return cell;
    } else {
        //Cell should be a heading cell
        IHWLabelCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"label" forIndexPath:indexPath];
        if ((indexPath.section == 0 && indexPath.row > 0)) {
            //day headings along the top
            cell.textLabel.text = [NSString stringWithFormat:@"%d", (int)indexPath.row];
        } else if (indexPath.section != 0) {
            //period headings along the left side
            long thisPeriod = self.period+indexPath.section-2;
            if (thisPeriod < 1 || thisPeriod > [IHWCurriculum currentCampus]+3) {
                //Period is out of bounds
                cell.shouldHideOnAppear = YES;
            } else {
                //Period is in bounds -- add the ordinal string to the label
                cell.textLabel.text = [NSString stringWithFormat:@"%@", getOrdinal(self.period+(int)indexPath.section-2)];
            }
        }
        return cell;
    }
}

- (void)checkboxCell:(IHWCheckboxCell *)cell didChangeCheckedStateToState:(BOOL)newState {
    NSIndexPath *indexPath = [self.meetingsChooserView indexPathForCell:cell];
    if (indexPath.section == 1 && newState) {
        //The cell that was checked was the period before the course's period
        //Also check the period after this one (the course's period) to create a double period
        ((IHWCheckboxCell *)[self.meetingsChooserView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:2]]).checked = YES;
        ((IHWCheckboxCell *)[self.meetingsChooserView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:3]]).checked = NO;
    } else if (indexPath.section == 3 && newState) {
        //The cell that was checked was the period after the course's period
        //Also check the period before this one (the course's period) to create a double period
        ((IHWCheckboxCell *)[self.meetingsChooserView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:2]]).checked = YES;
        ((IHWCheckboxCell *)[self.meetingsChooserView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:1]]).checked = NO;
    } else if (indexPath.section == 2 && !newState) {
        //The cell that was unchecked was the course's period
        //Also uncheck the periods before and after this period to create an X day
        ((IHWCheckboxCell *)[self.meetingsChooserView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:1]]).checked = NO;
        ((IHWCheckboxCell *)[self.meetingsChooserView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:3]]).checked = NO;
    }
}

@end
