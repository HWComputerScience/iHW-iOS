//
//  IHWJSONInfo.h
//  iHW
//
//  Created by Lara Bagdasarian on 3/20/16.
//  Copyright © 2016 Jonathan Burns. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IHWJSONInfo : NSObject

@property (strong, nonatomic) NSMutableArray *courseName;//e.g. 15-16 :: Advanced Seminar in Mathematics Honors :: Weis
@property (strong, nonatomic) NSMutableArray *courseID;//e.g. 1661020
//to be added once enrollment page is called w/ courseNumberID
@property (strong, nonatomic) NSMutableArray * courseSectionID; // e.g. 12495583
//to be added once section page is called with courseSectionID
@property (strong, nonatomic) NSMutableArray *courseSection; //e.g. 2X222
@property (strong, nonatomic) NSMutableArray *courseCode; //e.g. 2525-0E1
-(id)init;
@end
