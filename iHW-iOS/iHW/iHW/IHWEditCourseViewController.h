//
//  IHWEditCourseViewController.h
//  iHW
//
//  Created by Jonathan Burns on 8/14/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IHWCourse.h"
#import "IHWCheckboxCell.h"

@interface IHWEditCourseViewController : UIViewController <UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, IHWCheckboxCellDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *periodField;
@property (weak, nonatomic) IBOutlet UITextField *termField;
@property (weak, nonatomic) IBOutlet UICollectionView *periodsChooserView;
@property (nonatomic) int period;
@property (nonatomic) int term;

@property (weak, nonatomic) IHWCourse *course;

- (id)initWithCourse:(IHWCourse *)course;

@end
