//
//  IHWConstants.h
//  iHW
//
//  Created by Jonathan Burns on 8/11/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

/* Hello world! */

typedef enum {
    CAMPUS_MIDDLE = 6,
    CAMPUS_UPPER = 5
} CAMPUS;

typedef enum {
    TERM_FULL_YEAR = 0,
    TERM_FIRST_SEMESTER,
    TERM_SECOND_SEMESTER,
    TERM_FIRST_TRIMESTER,
    TERM_SECOND_TRIMESTER,
    TERM_THIRD_TRIMESTER
} COURSE_TERM;

typedef enum {
    MEETING_X_DAY = 0,
    MEETING_SINGLE_PERIOD,
    MEETING_DOUBLE_BEFORE,
    MEETING_DOUBLE_AFTER
} CLASS_MEETING;