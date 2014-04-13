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
#import "GradientButton.h"

@interface IHWEditCourseViewController : UIViewController <UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, IHWCheckboxCellDelegate, UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UILabel *periodLabel;
@property (weak, nonatomic) IBOutlet UITextField *periodField;
@property (weak, nonatomic) IBOutlet UITextField *termField;
@property (weak, nonatomic) IBOutlet UICollectionView *meetingsChooserView;
@property int originalInsetTop;

@property (strong, nonatomic) UITapGestureRecognizer *periodLabelGestureRecognizer;
@property (strong, nonatomic) UIButton *deleteButton;
@property (strong, nonatomic) NSArray *cells;

@property (nonatomic) int period;
@property (nonatomic) int term;

@property (weak, nonatomic) IHWCourse *course;

- (id)initWithCourse:(IHWCourse *)course;

@end
