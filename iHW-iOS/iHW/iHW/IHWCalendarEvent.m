//
//  IHWCalendarEvent.m
//  iHW
//
//  Created by Jonathan Damico on 8/12/16.
//  Copyright © 2016 Jonathan Burns. All rights reserved.
//

#import "IHWCalendarEvent.h"
#import "IHWFileManager.h"
#import "IHWUtils.h"
#import "IHWCurriculum.h"

@implementation IHWCalendarEvent
-(id)init
{
    self = [super init];
    if (self) {
        self.title = nil;
        self.courseID = nil;
        self.contextCode = nil;
        self.date = nil;
    }
    return self;
}

+(void) downloadCalendarEvents:(NSMutableArray *) contextCodes {
    NSMutableArray *calendar = [[NSMutableArray alloc] init];
    NSDictionary *test = [[NSDictionary alloc] init];
    NSString *contextCode = nil;
    NSString *eventType = nil;
    NSArray *eventTypes = [NSArray arrayWithObjects: @"event", @"assignment", nil];
    for(eventType in eventTypes) {
        for(contextCode in contextCodes) {
            NSLog(@"Started ASDFASDFASDF");
            NSString *urlString = [NSString stringWithFormat:@"https://hub.hw.com/api/v1/calendar_events?per_page=500&all_events=true&context_codes[]=%@&access_token=1~lFvoisjiIm7lybWcTneNIRiqpZUp4M5oQ39gwIm92sWbzwZrGUwSJyWV9GFDQpGC&type=%@", contextCode, eventType];
            NSDictionary *headers = @{ @"cache-control": @"no-cache",
                                       @"postman-token": @"15389f09-d1b4-7f18-6601-3d651b762198" };
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                                   cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                               timeoutInterval:10.0];
            [request setHTTPMethod:@"GET"];
            [request setAllHTTPHeaderFields:headers];
            
            NSURLSession *session = [NSURLSession sharedSession];
            NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
                                                            if (error) {
                                                                NSLog(@"%@", error);
                                                            } else {
                                                                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                                                NSLog(@"%@", httpResponse);
                                                                NSError *error = nil;
                                                                NSArray *dataJSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                                                if (error != nil) {
                                                                    NSLog(@"Error parsing JSON.");
                                                                } else {
                                                                    //NSLog(@"%@", dataJSON);
                                                                    for(NSDictionary *event in dataJSON) {
                                                                        IHWCalendarEvent *eventObj = [[self alloc ]init];
                                                                        eventObj.title = event[@"title"];
                                                                        eventObj.contextCode = event[@"context_code"];
                                                                        eventObj.date = event[@"all_day_date"];
                                                                        
                                                                        NSDictionary *assignment = event[@"assignment"];
                                                                        if(assignment!=nil)
                                                                            eventObj.courseID = assignment[@"course_id"];
                                                                        else
                                                                            eventObj.courseID = [event[@"context_code"] substringFromIndex:7];
                                                                        [calendar addObject:eventObj];
                                                                    }
                                                                }
                                                            }
                                                        }];
            [dataTask resume];
        }
    }
    NSMutableDictionary *eventsDict = [NSMutableDictionary dictionary];
    [eventsDict setObject:calendar forKey:@"events"];
    //Serialize the year to JSON data
    NSError *error = nil;
    NSData *eventsJSON = [[CJSONSerializer serializer] serializeDictionary:eventsDict error:&error];
    if (error != nil) { NSLog(@"ERROR serializing courses: %@", error.debugDescription); return; }
    [IHWFileManager saveCalendarJSON:eventsJSON forYear:[IHWCurriculum currentYear] campus:getCampusChar([IHWCurriculum currentCampus])];
}

@end