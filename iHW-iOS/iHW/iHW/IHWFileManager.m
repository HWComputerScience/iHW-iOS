//
//  IHWFileManager.m
//  iHW
//
//  Created by Jonathan Burns on 8/8/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import "IHWFileManager.h"

@implementation IHWFileManager

+ (BOOL)saveScheduleJSON:(NSData *)json forYear:(int)year campus:(NSString *)campusChar {
    NSString *filename = [NSString stringWithFormat:@"curriculum%d%@.hws", year, campusChar];
    return [IHWFileManager saveFile:json toPathInsideDocuments:filename];
}

+ (NSData *)loadScheduleJSONForYear:(int)year campus:(NSString *)campusChar {
    NSString *filename = [NSString stringWithFormat:@"curriculum%d%@.hws", year, campusChar];
    return [IHWFileManager loadFileFromPathInsideDocuments:filename];
}

+ (BOOL)saveYearJSON:(NSData *)json forYear:(int)year campus:(NSString *)campusChar {
    NSString *filename = [NSString stringWithFormat:@"year%d%@.hws", year, campusChar];
    return [IHWFileManager saveFile:json toPathInsideDocuments:filename];
}

+ (NSData *)loadYearJSONForYear:(int)year campus:(NSString *)campusChar {
    NSString *filename = [NSString stringWithFormat:@"year%d%@.hws", year, campusChar];
    return [IHWFileManager loadFileFromPathInsideDocuments:filename];
}

+ (BOOL)saveWeekJSON:(NSData *)json forWeekNumber:(int)weekNumber year:(int)year campus:(NSString *)campusChar {
    NSString *filename = [NSString stringWithFormat:@"%d%@/week%d.hws", year, campusChar, weekNumber];
    return [IHWFileManager saveFile:json toPathInsideDocuments:filename];
}

+ (NSData *)loadWeekJSONForWeekNumber:(int)weekNumber year:(int)year campus:(NSString *)campusChar {
    NSString *filename = [NSString stringWithFormat:@"%d%@/week%d.hws", year, campusChar, weekNumber];
    return [IHWFileManager loadFileFromPathInsideDocuments:filename];
}

+ (BOOL)saveCalendarJSON:(NSData *)json forYear:(int)year campus:(NSString *)campusChar {
    NSString *filename = [NSString stringWithFormat:@"calendar%d%@.hws", year, campusChar];
    return [IHWFileManager saveFile:json toPathInsideDocuments:filename];
}

+ (NSData *)loadCalendarJSONForYear:(int)year campus:(NSString *)campusChar {
    NSString *filename = [NSString stringWithFormat:@"calendar%d%@.hws", year, campusChar];
    return [IHWFileManager loadFileFromPathInsideDocuments:filename];
}

+ (BOOL)saveTokenJSON:(NSData *)json {
    NSString *filename = [NSString stringWithFormat:@"token.hws"];
    return [IHWFileManager saveFile:json toPathInsideDocuments:filename];
}

+ (NSData *)loadTokenJSON {
    NSString *filename = [NSString stringWithFormat:@"token.hws"];
    return [IHWFileManager loadFileFromPathInsideDocuments:filename];
}

+ (BOOL)saveFile:(NSData *)data toPathInsideDocuments:(NSString *)pathInsideDocuments {
    //Get path to documents
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    //Construct complete file path
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, pathInsideDocuments];
    NSError *error = nil;
    //Make sure the folder exists
    [[NSFileManager defaultManager] createDirectoryAtPath:[filePath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:&error];
    if (error != nil) { NSLog(@"ERROR saving file %@: %@", pathInsideDocuments, error.debugDescription); return NO; }
    //Write the data
    [data writeToFile:filePath options:NSDataWritingAtomic error:&error];
    if (error != nil) { NSLog(@"ERROR saving file %@: %@", pathInsideDocuments, error.debugDescription); return NO; }
    return YES;
}

+ (NSData *)loadFileFromPathInsideDocuments:(NSString *)pathInsideDocuments {
    //Get path to documents
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    //Construct complete file path
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, pathInsideDocuments];
    NSError *error = nil;
    //Get the data and return it
    NSData *result = [NSData dataWithContentsOfFile:filePath options:0 error:&error];
    if (error == nil) return result;
    else {
        NSLog(@"ERROR loading file %@: %@", pathInsideDocuments, error.debugDescription);
        return nil;
    }
}

@end
