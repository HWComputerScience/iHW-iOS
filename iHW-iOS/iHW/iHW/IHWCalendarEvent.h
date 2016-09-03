//
//  IHWCalendarEvent.h
//  iHW
//
//  Created by Jonathan Damico on 8/12/16.
//  Copyright © 2016 Jonathan Burns. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IHWCalendarEvent : NSObject

@property (strong, nonatomic) NSString *title;//e.g. 15-16 :: Advanced Seminar in Mathematics Honors :: Weis
@property (strong, nonatomic) NSString *courseID;//e.g. 1661020
//to be added once enrollment page is called w/ courseNumberID
@property (strong, nonatomic) NSString *contextCode; // e.g. 12495583
//to be added once section page is called with courseSectionID
@property (strong, nonatomic) NSString *date; //YYYY-MM-DD
-(id)init;
+(void) downloadCalendarEvents:(NSMutableArray *) contextCodes;
@end
