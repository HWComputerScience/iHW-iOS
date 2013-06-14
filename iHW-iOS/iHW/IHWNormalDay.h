//
//  IHWNormalDay.h
//  iHW
//
//  Created by Andrew Friedman on 6/14/13.
//  Copyright (c) 2013 Andrew Friedman. All rights reserved.
//

#import "IHWDay.h"

@interface IHWNormalDay : IHWDay

@property int dayNumber;
@property BOOL hasBreak;
@property int numPeriods;
@property int periodsAfterBreak;
@property int periodsBeforeBreak;
@property int periodLength;
@property int breakLength;
@property NSString *breakName;

@end
