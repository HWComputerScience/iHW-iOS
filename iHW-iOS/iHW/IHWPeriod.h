//
//  IHWPeriod.h
//  iHW
//
//  Created by Andrew Friedman on 6/14/13.
//  Copyright (c) 2013 Andrew Friedman. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IHWTime;

@interface IHWPeriod : NSObject

@property NSString *name;
@property IHWTime *startTime;
@property IHWTime *endTime;




@end
