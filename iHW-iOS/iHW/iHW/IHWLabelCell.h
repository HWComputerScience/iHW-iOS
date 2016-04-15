//
//  IHWLabelCell.h
//  iHW
//
//  Created by Jonathan Burns on 8/15/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IHWLabelCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic) BOOL shouldHideOnAppear;

@end
