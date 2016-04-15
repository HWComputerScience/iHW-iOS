//
//  IHWJSONInfo.m
//  iHW
//f
//  Created by Lara Bagdasarian on 3/20/16.
//  Copyright © 2016 Jonathan Burns. All rights reserved.
//

#import "IHWJSONInfo.h"

@implementation IHWJSONInfo
-(id)init
{
    self = [super init];
    if (self) {
        self.courseName = [[NSMutableArray alloc] init];
        self.courseID = [[NSMutableArray alloc] init];
       self.courseCode = [[NSMutableArray alloc] init];
        self.courseSection = [[NSMutableArray alloc] init];
        self.courseSectionID =[[NSMutableArray alloc] init];
    }
    return self;
}

@end
