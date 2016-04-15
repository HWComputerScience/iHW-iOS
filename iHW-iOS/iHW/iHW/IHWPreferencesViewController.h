//
//  IHWPreferencesViewController.h
//  iHW
//
//  Created by Jonathan Burns on 4/14/14.
//  Copyright (c) 2014 Jonathan Burns. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IHWPreferencesViewController : UITableViewController <UIActionSheetDelegate, UIWebViewDelegate>

@property (nonatomic, retain) NSArray *items;
@property (nonatomic, retain) NSArray *actions;

@end
