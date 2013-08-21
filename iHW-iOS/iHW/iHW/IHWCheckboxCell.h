//
//  IHWCheckboxCell.h
//  iHW
//
//  Created by Jonathan Burns on 8/15/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IHWCheckboxCellDelegate;



@interface IHWCheckboxCell : UICollectionViewCell

@property (nonatomic, strong) UIButton *checkboxButton;
@property (nonatomic, weak) NSObject<IHWCheckboxCellDelegate> *delegate;
@property (nonatomic) BOOL shouldHideOnAppear;

- (BOOL)checked;
- (void)setChecked:(BOOL)checked;

@end



@protocol IHWCheckboxCellDelegate <NSObject>

@optional
- (void)checkboxCell:(IHWCheckboxCell *)cell didChangeCheckedStateToState:(BOOL)newState;

@end