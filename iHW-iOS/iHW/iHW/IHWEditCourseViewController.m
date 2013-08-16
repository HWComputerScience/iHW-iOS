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

@implementation IHWEditCourseViewController

- (id)initWithCourse:(IHWCourse *)course
{
    self = [super initWithNibName:@"IHWEditCourseViewController" bundle:nil];
    if (self) {
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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShown:) name:@"UIKeyboardDidShowNotification" object:nil];
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHidden:) name:@"UIKeyboardDidHideNotification" object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.course != nil) {
        self.nameField.text = self.course.name;
        self.periodField.text = [NSString stringWithFormat:@"%d", self.course.period];
    }
    self.termField.text = stringForTerm(self.term);
    
    self.nameField.delegate = self;
    self.periodField.delegate = self;
    self.termField.delegate = self;
    
    self.periodField.keyboardType = UIKeyboardTypeNumberPad;
    
    self.periodsChooserView.delegate = self;
    self.periodsChooserView.dataSource = self;
    [self.periodsChooserView registerClass:[IHWCheckboxCell class] forCellWithReuseIdentifier:@"checkbox"];
    [self.periodsChooserView registerClass:[IHWLabelCell class] forCellWithReuseIdentifier:@"label"];
    self.periodsChooserView.collectionViewLayout = [[IHWPeriodsChooserLayout alloc] initWithNumDays:[IHWCurriculum currentCampus]];
    self.periodsChooserView.backgroundColor = [UIColor clearColor];
    
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.contentSize = CGSizeMake(320, 276);
}

- (void)cancelCourse {
    
}

- (void)saveCourse {
    
}

- (void)keyboardShown:(NSNotification *)aNotification {
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [self.view convertRect:[aValue CGRectValue] fromView:nil];
    CGRect intersection = CGRectIntersection(keyboardRect, self.scrollView.frame);
    self.scrollView.frame = CGRectMake(self.scrollView.frame.origin.x, self.scrollView.frame.origin.y, self.scrollView.frame.size.width, self.scrollView.frame.size.height-intersection.size.height);
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
        [[[UIActionSheet alloc] initWithTitle:@"Which term does this course meet in?" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Full Year", @"First Semester", @"Second Semester", @"First Trimester", @"Second Trimester", @"Third Trimester", nil] showInView:self.view];
        return NO;
    }
    return YES;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    self.termField.text = [actionSheet buttonTitleAtIndex:buttonIndex];
    self.term = buttonIndex;
}

- (void)updatePeriodsChooser {
    int numDays = [IHWCurriculum currentCampus];
    for (int day = 0; day <= numDays; day++) for (int periodIndex = 0; periodIndex <= 3; periodIndex++) {
        UICollectionViewCell *cell = [self.periodsChooserView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:day inSection:periodIndex]];
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
            } else if (meeting == MEETING_DOUBLE_BEFORE) {
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
                cell.textLabel.text = [NSString stringWithFormat:@"%@", getOrdinal(self.course.period+indexPath.section-2)];
            }
        }
        return cell;
    }
}

- (void)checkboxCell:(IHWCheckboxCell *)cell didChangeCheckedStateToState:(BOOL)newState {
    NSIndexPath *indexPath = [self.periodsChooserView indexPathForCell:cell];
    if (indexPath.section == 1 && newState) {
        ((IHWCheckboxCell *)[self.periodsChooserView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:2]]).checked = YES;
        ((IHWCheckboxCell *)[self.periodsChooserView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:3]]).checked = NO;
    } else if (indexPath.section == 3 && newState) {
        ((IHWCheckboxCell *)[self.periodsChooserView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:2]]).checked = YES;
        ((IHWCheckboxCell *)[self.periodsChooserView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:1]]).checked = NO;
    } else if (indexPath.section == 2 && !newState) {
        ((IHWCheckboxCell *)[self.periodsChooserView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:1]]).checked = NO;
        ((IHWCheckboxCell *)[self.periodsChooserView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:3]]).checked = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
