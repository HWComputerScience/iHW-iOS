//
//  IHWDay.h
//  iHW
//
//  Created by Andrew Friedman on 7/10/13.
//  Copyright (c) 2013 Andrew Friedman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IHWDate.h"

@interface IHWDay : NSObject

@property int dayNum;
@property (strong, nonatomic) IHWDate *date;
@property (strong, nonatomic) NSMutableArray *periods;
@property int periodLength;
@property BOOL hasBreak;
@property int breakLength;
@property (strong, nonatomic) NSString *breakName;


@end
