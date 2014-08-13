//
//  IHWFirstRunViewController.h
//  iHW
//
//  Created by Jonathan Burns on 8/11/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IHWCurriculum.h"

@interface IHWFirstRunViewController : UIViewController <IHWCurriculumLoadingListener, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *middleSchoolButton;
@property (weak, nonatomic) IBOutlet UIButton *upperSchoolButton;
@property (weak, nonatomic) IBOutlet UILabel *methodPromptLabel;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (weak, nonatomic) IBOutlet UIButton *manualButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topSpaceConstraint2;
@property BOOL goingToStep2;

- (void)gotoStep2;

@end
