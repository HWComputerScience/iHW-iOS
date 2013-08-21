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
        self.cells = [[NSBundle mainBundle] loadNibNamed:@"IHWEditCourseCells" owner:self options:nil];
        
        self.course = course;
        self.period = -1;
        self.term = TERM_FULL_YEAR;
        if (self.course != nil) {
            self.navigationItem.title = self.course.name;
            self.period = self.course.period;
            self.term = self.course.term;
        }
        else self.navigationItem.title = @"Add Course";
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelCourse)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveCourse)];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:@"UIKeyboardDidShowNotification" object:nil];
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
    
    if (self.course != nil) {
        self.nameField.text = self.course.name;
        self.periodField.text = [NSString stringWithFormat:@"%d", self.course.period];
        
        self.deleteButton = [[GradientButton alloc] initWithFrame:CGRectMake(0, 0, 300, 44)];
        [self.deleteButton useRedDeleteStyle];
        [self.deleteButton setTitle:@"Delete Course" forState:UIControlStateNormal];
        [self.deleteButton setTitle:@"Delete Course" forState:UIControlStateHighlighted];
        [self.deleteButton setTitle:@"Delete Course" forState:UIControlStateDisabled];
        [self.deleteButton addTarget:self action:@selector(showDeleteCoursePopup) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self.nameField becomeFirstResponder];
    }
    self.termField.text = stringForTerm(self.term);
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    [toolbar setItems:@[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil], [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(resignPeriodField)]] animated:YES];
    self.periodField.inputAccessoryView = toolbar;
    
    self.nameField.delegate = self;
    self.periodField.delegate = self;
    self.termField.delegate = self;
        
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
    return 3;
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
        BOOL thisPeriodChecked = ((IHWCheckboxCell *)[self.meetingsChooserView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:2]]).checked;
        BOOL beforePeriodChecked = ((IHWCheckboxCell *)[self.meetingsChooserView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1]]).checked;
        BOOL afterPeriodChecked = ((IHWCheckboxCell *)[self.meetingsChooserView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:3]]).checked;
        if (!thisPeriodChecked) [meetings addObject:[NSNumber numberWithInt:MEETING_X_DAY]];
        else if (beforePeriodChecked) [meetings addObject:[NSNumber numberWithInt:MEETING_DOUBLE_BEFORE]];
        else if (afterPeriodChecked) [meetings addObject:[NSNumber numberWithInt:MEETING_DOUBLE_AFTER]];
        else [meetings addObject:[NSNumber numberWithInt:MEETING_SINGLE_PERIOD]];
    }
    IHWCourse *course = [[IHWCourse alloc] initWithName:self.nameField.text period:self.period term:self.term meetings:meetings];
    
    if ([self.nameField.text isEqualToString:@""] || course.totalMeetings == 0) {
        [[[UIAlertView alloc] initWithTitle:@"Invalid Course" message:@"The course must have a name and at least one class meeting. Please edit the course and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
    if (self.course != nil) [[IHWCurriculum currentCurriculum] removeCourse:self.course];
    if (![[IHWCurriculum currentCurriculum] addCourse:course]) {
        [[[UIAlertView alloc] initWithTitle:@"Courses Conflict!" message:@"The course period and meetings you selected conflict with one or more of your existing courses. Please change the course period or meetings and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        if (self.course != nil) [[IHWCurriculum currentCurriculum] addCourse:self.course];
    } else {
        [[IHWCurriculum currentCurriculum] saveCourses];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)showDeleteCoursePopup {
    [[[UIActionSheet alloc] initWithTitle:@"Are you sure you want to delete this course?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Course" otherButtonTitles:nil] showInView:self.view];
}

- (void)keyboardDidShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [self.view convertRect:[aValue CGRectValue] fromView:nil];
    CGRect intersection = CGRectIntersection(keyboardRect, self.tableView.frame);
    int offset = 0;
    if (self.periodField.isFirstResponder) offset = self.periodField.inputAccessoryView.frame.size.height;
    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height-intersection.size.height+offset);
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.tableView.frame = self.view.bounds;

}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *resultString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (textField == self.nameField) {
        if (![resultString isEqualToString:@""]) self.navigationItem.title = resultString;
        else if (self.course == nil) self.navigationItem.title = @"Add Course";
        else self.navigationItem.title = @"Edit Course";
        return YES;
    } else if (textField == self.periodField) {
        int newPeriod = resultString.intValue;
        if ([resultString isEqualToString:@""]) {
            self.period = -1;
            [self updatePeriodsChooser];
            return YES;
        } else if (newPeriod < 1 || newPeriod > [IHWCurriculum currentCampus]+3) {
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
        [self.nameField resignFirstResponder];
        [self.periodField resignFirstResponder];
        [ActionSheetStringPicker showPickerWithTitle:@"Select Term" rows:@[@"Full Year", @"First Semester", @"Second Semester", @"First Trimester", @"Second Trimester", @"Third Trimester"] initialSelection:self.term doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            self.termField.text = stringForTerm(selectedIndex);
            self.term = selectedIndex;
        } cancelBlock:nil origin:self.view];
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    self.tableView.frame = self.view.bounds;
    [textField resignFirstResponder];
    return YES;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        [[IHWCurriculum currentCurriculum] removeCourse:self.course];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)updatePeriodsChooser {
    int numDays = [IHWCurriculum currentCampus];
    for (int day = 0; day <= numDays; day++) for (int periodIndex = 0; periodIndex <= 3; periodIndex++) {
        UICollectionViewCell *cell = [self.meetingsChooserView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:day inSection:periodIndex]];
        int thisPeriod = self.period+periodIndex-2;
        if (day==0 && periodIndex > 0) {
            if (thisPeriod < 1 || thisPeriod > [IHWCurriculum currentCampus]+3) {
                cell.hidden = YES;
            } else {
                cell.hidden = NO;
                ((IHWLabelCell *)cell).textLabel.text = getOrdinal(thisPeriod);
            }
        } else if (day > 0 && periodIndex > 0) {
            if (thisPeriod < 1 || thisPeriod > [IHWCurriculum currentCampus]+3) {
                [(IHWCheckboxCell *)cell setChecked:NO];
                cell.hidden = YES;
            } else {
                cell.hidden = NO;
                ((IHWCheckboxCell *)cell).checked = NO;
            }
        }
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [IHWCurriculum currentCampus]+1;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 4;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 0 && indexPath.row != 0) {
        IHWCheckboxCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"checkbox" forIndexPath:indexPath];
        int thisPeriod = self.period+indexPath.section-2;
        if (thisPeriod < 1 || thisPeriod > [IHWCurriculum currentCampus]+3) cell.shouldHideOnAppear = YES;
        else {
            int meeting = [self.course meetingOn:indexPath.row];
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
        IHWLabelCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"label" forIndexPath:indexPath];
        if ((indexPath.section == 0 && indexPath.row > 0)) { //day headings
            cell.textLabel.text = [NSString stringWithFormat:@"%d", indexPath.row];
        } else if (indexPath.section != 0) { //period headings
            int thisPeriod = self.period+indexPath.section-2;
            if (thisPeriod < 1 || thisPeriod > [IHWCurriculum currentCampus]+3) {
                cell.shouldHideOnAppear = YES;
            } else {
                cell.textLabel.text = [NSString stringWithFormat:@"%@", getOrdinal(self.period+indexPath.section-2)];
            }
        }
        return cell;
    }
}

- (void)checkboxCell:(IHWCheckboxCell *)cell didChangeCheckedStateToState:(BOOL)newState {
    NSIndexPath *indexPath = [self.meetingsChooserView indexPathForCell:cell];
    if (indexPath.section == 1 && newState) {
        ((IHWCheckboxCell *)[self.meetingsChooserView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:2]]).checked = YES;
        ((IHWCheckboxCell *)[self.meetingsChooserView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:3]]).checked = NO;
    } else if (indexPath.section == 3 && newState) {
        ((IHWCheckboxCell *)[self.meetingsChooserView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:2]]).checked = YES;
        ((IHWCheckboxCell *)[self.meetingsChooserView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:1]]).checked = NO;
    } else if (indexPath.section == 2 && !newState) {
        ((IHWCheckboxCell *)[self.meetingsChooserView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:1]]).checked = NO;
        ((IHWCheckboxCell *)[self.meetingsChooserView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:3]]).checked = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
