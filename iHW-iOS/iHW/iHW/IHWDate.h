//
//  IHWDate.h
//  iHW
//
//  Created by Andrew Friedman on 7/11/13.
//  Copyright (c) 2013 Andrew Friedman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IHWDate : NSDate

- (id)initWithMonth:(int)m day:(int)d year:(int)y;

-(int)getMonth;

-(int)getDay;

-(int)getYear;
@end
