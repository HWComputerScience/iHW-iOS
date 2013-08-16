//
//  IHWPeriodsChooserLayout.h
//  iHW
//
//  Created by Jonathan Burns on 8/15/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IHWPeriodsChooserLayout : UICollectionViewLayout

@property int numDays;
@property CGSize cellSize;
@property CGSize marginSize;

- (id)initWithNumDays:(int)numDays;

@end
