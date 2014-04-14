//
//  IHWPreferencesViewController.h
//  iHW
//
//  Created by Jonathan Burns on 8/21/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IHWOldPreferencesViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *yearField;
@property (weak, nonatomic) IBOutlet UILabel *yearHintField;
@property (weak, nonatomic) IBOutlet UITextView *disclaimerView;

@end
