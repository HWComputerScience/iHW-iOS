//
//  IHWDownloadScheduleViewController.m
//  iHW
//
//  Created by Jonathan Burns on 8/12/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import "IHWDownloadScheduleViewController.h"
#import "IHWAppDelegate.h"
#import "HTMLParser.h"
#import "IHWCourse.h"
#import "IHWCurriculum.h"
#import "IHWFirstRunViewController.h"
#import "IHWGuidedCoursesViewController.h"
#import "IHWNormalCoursesViewController.h"
#import "IHWScheduleViewController.h"
#import "IHWUtils.h"
#import "AFNetworking.h"
#import "CJSONDeserializer.h"
#import "IHWJSONInfo.h"
#import "IHWCalendarEvent.h"
#import "IHWFileManager.h"
@interface IHWDownloadScheduleViewController()
@property(strong) NSDictionary *iHW;
@property(strong) NSArray *iHW2;
@property(strong) NSArray *iHW3;
@property(strong) NSString* accessToken;
@property(strong) NSString* refreshToken;
@property(strong) IHWJSONInfo* theData;
@end

//This class controls the screen where the user logs into HW.com and downloads their schedule into the app.
@implementation IHWDownloadScheduleViewController {
    BOOL alreadyLoaded;
    BOOL hasCourseCode;
    NSMutableArray* courseCodesArray;
    NSMutableArray* courseNamesArray;
    NSMutableArray* conventionalScheduleArray;
    NSMutableArray* scheduleArray;
    BOOL correctPage;
    int n;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        alreadyLoaded = NO;
    }
    return self;
}
@synthesize myNewWebView;
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[IHWCurriculum currentCurriculum] removeAllCourses];//should start with no courses in case of redownloading
    
    self.myNewWebView.delegate=self;
    NSString *url=@"https://hub.hw.com/login/oauth2/auth?client_id=10000000000502&response_type=code&redirect_uri=https://ihwoauth.hwtechcouncil.com";
    NSURL *nsurl=[NSURL URLWithString:url];
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
    [myNewWebView loadRequest:nsrequest];//make user sign in, click captcha, and then we'll get the access key and make the requests for the schedule data, etc.

/**    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //update UI here
        });
        
        
    });
 */
//self.accessToken=@"1~j0mghUA7Xlg5aFuGGrw2JM3Xzu6t3QgJlkOiCgyzZNDsTzgoNLZPzBGRYTA7CiGd";//some token in this format
 
    
    /**   NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
        //Make sure they actually have to log in each time
    }
  */
      //self.webView.keyboardDisplayRequiresUserAction = NO;
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        self.topSpaceConstraint.constant = 0;
    }
    
    
}

-(void) loadScheduleInfo{
    _theData = [[IHWJSONInfo alloc] init];
 //   NSLog(@"loadScheduleInfo was invoked");
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"https://hub.hw.com/api/v1/courses/?per_page=500"]];//add header to show complete thing************************
   
     NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30];
    [urlRequest setValue:[NSString stringWithFormat:@"Bearer %@", self.accessToken] forHTTPHeaderField:@"Authorization"];//header w/ key so we can add ?per_page =500

    NSData* urlData;
    NSURLResponse* response;
    NSError* error;
    
    //make the synchronous request
    urlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    
    NSArray* courseObject = [NSJSONSerialization JSONObjectWithData:urlData options:0 error:&error];
  //  NSLog(@"access token is %@", self.accessToken);
    //   NSLog(@"it's working until this point %@", courseObject);
    NSLog(@"the following is the course object: %@",courseObject);
    for (int x = 0; x< courseObject.count; x++)
    {
        NSDictionary* dict = courseObject[x];
        NSString* b =dict[@"id"];
     //   NSLog(@"<<<<<<<<%@",b);
        
        NSString* d = dict[@"name"];
        
        //  NSLog(@">>>>%@",d);
        //NSLog(@"number to check %lu", (unsigned long)courseObject.count);
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy"];
        char yearString = [[formatter stringFromDate:[NSDate date]] characterAtIndex:3];
        if ([d characterAtIndex:1] == yearString){//check whether it's the current year
            //    NSString* a = [NSString stringWithFormat: @"%@\n%@",b,d];
            [_theData.courseID addObject:b];
            NSString *contextCode = [NSString stringWithFormat:@"course_%@",b];
            [_theData.contextCode addObject:contextCode];
            [_theData.courseName addObject:d];
            NSLog(@"ADDING OBJECT");
        }
    }
    
    NSLog(@"%@",_theData.courseID);
    NSLog(@"%@",_theData.courseName);
    
    
    
    //second synchronous request to enrollments page with auth header
    NSURL* url2 = [NSURL URLWithString:@"https://hub.hw.com/api/v1/users/self/enrollments?per_page=500"];
    NSMutableURLRequest* urlRequest2 = [NSMutableURLRequest requestWithURL:url2 cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30];
    [urlRequest2 setValue:[NSString stringWithFormat:@"Bearer %@", self.accessToken] forHTTPHeaderField:@"Authorization"];//header w/ key so we can add ?per_page =500
    NSData* urlData2;
    NSURLResponse* response2;
    NSError* error2;
    
    //make the synchronous request
    urlData2 = [NSURLConnection sendSynchronousRequest:urlRequest2 returningResponse:&response2 error:&error2];
    
    courseObject = [NSJSONSerialization JSONObjectWithData:urlData2 options:0 error:&error2];
   // NSLog(@"it's working until this point2 %@", courseObject);
    /**    _theData.courseSectionID=[[NSMutableArray alloc ]initWithCapacity:_theData.courseName.count];
     _theData.courseCode=[[NSMutableArray alloc ]initWithCapacity:_theData.courseName.count];
     _theData.courseSectionID=[[NSMutableArray alloc ]initWithCapacity:_theData.courseName.count];
     */
    for (int x = 0; x<_theData.courseName.count; x++)
    {
        _theData.courseSectionID[x] = @" ";
    }
    
    for (int x = 0; x< courseObject.count; x++)
    {
        NSDictionary* dict = courseObject[x];
        NSString* b =dict[@"course_id"];
        //     NSLog(@"<<<<<<<<%@",b);
        
        NSString* d = dict[@"course_section_id"];
        //     NSLog(@">>>>%@",d);
        //NSLog(@"number to check %lu", (unsigned long)courseObject.count);
        BOOL inIt = false;
        //  NSLog(@"size %lu", (unsigned long)_theData.courseID.count);
        int cou = 0;
        for (cou = 0; cou<_theData.courseID.count; cou++){
            if(_theData.courseID[cou] ==b)
            {
                inIt = true;
                break;
            }
        }
        if (inIt){
            _theData.courseSectionID[cou] =d;
        }
    }
    
    NSLog(@"%@",_theData.courseSectionID);
    
    //  NSLog(@"we are done2 . . .");
    
    
    //third request for actual section and course code -- this one is looped
    for (int counter = 0; counter<_theData.courseSectionID.count; counter++){
        NSURL* url3 = [NSURL URLWithString:[NSString stringWithFormat:@"https://hub.hw.com/api/v1/sections/%@",_theData.courseSectionID[counter]]];
        NSMutableURLRequest* urlRequest3 = [NSMutableURLRequest requestWithURL:url3 cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30];
        [urlRequest3 setValue: [ NSString stringWithFormat:@"Bearer %@",self.accessToken] forHTTPHeaderField:@"Authorization"];//auth header
        NSData* urlData3;
        NSURLResponse* response3;
        NSError* error3;
        NSLog(@"url that's being called:%@", [url3 absoluteString]);
        //make the synchronous request
        urlData3 = [NSURLConnection sendSynchronousRequest:urlRequest3 returningResponse:&response3 error:&error3];
        NSDictionary* courseObject3 = [NSJSONSerialization JSONObjectWithData:urlData3 options:0 error:&error3];
        //   NSLog(@"it's working until this point3 %@", courseObject3);
        
        NSString* b = courseObject3[@"name"];
    //    NSLog(@"<<<<<<<<%@",b);
        NSArray* nameInTwoParts = [b componentsSeparatedByString:@", "];
        if (nameInTwoParts[0]!=nil)
            [_theData.courseCode addObject:nameInTwoParts[0]];
        if (nameInTwoParts[1]!=nil)
            [_theData.courseSection addObject:nameInTwoParts[1]];
    }
    
    NSLog(@"%@",_theData.courseCode);
    NSLog(@"%@",_theData.courseSection);
    
    NSLog(@"we are done3 . . .");
    /*dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
     //DATA Processing
     dispatch_sync(dispatch_get_main_queue(), ^{
     //update UI here
     });
     
     
     });*/
    
    [self saveStuff];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
     self.myNewWebView.delegate=self;
}

- (IBAction)backPressed:(id)sender {
    if ([IHWCurriculum isFirstRun]) [self.navigationController popViewControllerAnimated:YES];
    else if(![self.navigationController.topViewController isKindOfClass:[IHWScheduleViewController class]]) {
        @try {
            [self.navigationController setViewControllers:@[[[IHWScheduleViewController alloc] initWithNibName:@"IHWScheduleViewController" bundle:nil]] animated:YES];
        } @catch (NSException * e) {
            NSLog(@"Exception: %@", e);
        } @finally {
            //NSLog(@"finally");
        }
}
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
    {
    
 //   NSLog(@"from shouldStartLoad");
   //    NSLog(@"entered shouldStart . . .");
  //      NSLog(@"%@",request.URL.absoluteString);
    if ([request.URL.absoluteString rangeOfString:@"https://ihwoauth.hwtechcouncil.com/?code="].location !=NSNotFound){
     //   self.myNewWebView.hidden = YES;
        correctPage = YES;
        
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);//this waits until async request is over before using the access key b/c otherwise access key would be nil
        
        //
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (!data) {
                NSLog(@"%s: sendAynchronousRequest error: %@", __FUNCTION__, connectionError);
                return;
            } else if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
                if (statusCode != 200) {
                    NSLog(@"%s: sendAsynchronousRequest status code != 200: response = %@", __FUNCTION__, response);
                    return;
                }
            }
            
            NSError *parseError = nil;
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            if (!dictionary) {
                NSLog(@"%s: JSONObjectWithData error: %@; data = %@", __FUNCTION__, parseError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                return;
            }
            //NSLog(@"dictionary is %@", dictionary);
            NSLog(@"this should be the access token%@",dictionary[@"access_token"]);
            //NSLog(@"and this should be the refresh token %@", dictionary[@"refresh_token"]);
            NSDictionary *tokenDict = @{@"refresh_token" : dictionary[@"refresh_token"]};
            //Serialize the year to JSON data
            NSError *error = nil;
            NSData *tokenJSON = [[CJSONSerializer serializer] serializeDictionary:tokenDict error:&error];
            if (error != nil) { NSLog(@"ERROR serializing refresh token: %@", error.debugDescription); }
            [IHWFileManager saveTokenJSON:tokenJSON];
            self.accessToken =dictionary[@"access_token"];
            self.refreshToken =dictionary[@"refresh_token"];//we probably don't need to use the refresh token b/c we store the data on the app right away
            dispatch_semaphore_signal(sema);
        }];
            
while (dispatch_semaphore_wait(sema, DISPATCH_TIME_NOW)) { [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]]; }        //dispatch_release(sema);
//looping until async request finished
        //COULD CAUSE POTENTIAL DEADLOCK IF CAN'T LOAD THE DATA FOR SOME REASON SO WE MIGHT NEED TO CHANGE THIS
        
           if (self.accessToken!=nil)
               [self loadScheduleInfo];
        return NO;
       }

    else if (
             ![request.URL isEqual:[NSURL URLWithString:@"https://hub.hw.com/login/oauth2/deny"]]&&
             ![request.URL isEqual:[NSURL URLWithString:@"https://ihwoauth.hwtechcouncil.com/?error=access_denied"]]
             ){//makes sure you can't press cancel
    
      [(IHWAppDelegate *)[UIApplication sharedApplication].delegate performSelectorOnMainThread:@selector(showNetworkIcon) withObject:nil waitUntilDone:NO];    [(IHWAppDelegate *)[UIApplication sharedApplication].delegate performSelectorOnMainThread:@selector(showNetworkIcon) withObject:nil waitUntilDone:NO];
    
    return YES;
    }
    else
        return NO;

}

- (void)webViewDidFinishLoad:(UIWebView *)webView1 {
    
    [(IHWAppDelegate *)[UIApplication sharedApplication].delegate performSelectorOnMainThread:@selector(hideNetworkIcon) withObject:nil waitUntilDone:NO];
        //If the login page just loaded, show the UIWebView and prompt the user to log in.
    NSLog(@"this was hit");
    self.myNewWebView.hidden = NO;
    self.loginPromptLabel.hidden = NO;
    
    if (!alreadyLoaded) {
        //This is the first time the "My Schedule" page loaded, so we haven't injected the JavaScript to find the schedule URL yet.
        alreadyLoaded = YES;
        self.loadingText.text = @"Please wait, finding schedule...";
    }
    
}
 

-(void)saveStuff{
    NSString *lastCode = _theData.courseCode[0];
    NSString *lastName = _theData.courseName[0];
    NSString *lastCourseID = _theData.courseID[0];
    NSArray *lastPeriodList = [(NSString*)[_theData.courseSection objectAtIndex:0] componentsSeparatedByString:@"."];
    NSLog(@"last Period list,%@",lastPeriodList);
    BOOL shouldShowWarning = NO;
    
   if ((int)lastPeriodList.count != [IHWCurriculum currentCurriculum].campus) {
        //The course period list doesn't have the same number of days as the campus the user chose earlier.
        [[[UIAlertView alloc] initWithTitle:@"Wrong Campus!" message:@"You chose the wrong campus during the setup. Please start again." delegate:self cancelButtonTitle:@"Back" otherButtonTitles:nil] show];
        return;
    }
    //NSLog(@"number of iterations%lu", (unsigned long)scheduleArray.count);
    for (int ccount = 0; ccount<_theData.courseSection.count; ccount++)
    {
        
        lastCode = _theData.courseCode[ccount];
        lastName = _theData.courseName[ccount];
        lastCourseID = _theData.courseID[ccount];
        lastPeriodList = [(NSString*)[_theData.courseSection objectAtIndex:ccount] componentsSeparatedByString:@"."];
    //    NSArray* testArray = [NSArray arrayWithObjects:@"3",@"x",@"3",@"3",@"3", nil];
        
        IHWCourse *c = parseCourse(lastCode, lastName, lastPeriodList, lastCourseID);
      
        if (c != nil) {
            //Course is valid -- add it
            if (![[IHWCurriculum currentCurriculum] addCourse:c]) NSLog(@"WARNING: Course Conflict!");//problem here!!!!!3/1
        }
        //reset the variables for the next time through the loop
       
        //Save the courses
        
        NSLog(@"waiting");
        
    }
    [[IHWCurriculum currentCurriculum] saveCourses];
    if (shouldShowWarning) {
        //Show a warning if the schedule was a preliminary schedule
        [[[UIAlertView alloc] initWithTitle:@"Full Schedule Unavailable" message:@"The full schedule is not yet available, so you will need to edit the courses that are not full-year and set the right semester/trimester." delegate:self cancelButtonTitle:@"Edit Courses" otherButtonTitles:nil] show];
    } else {
        //Otherwise go directly to the main schedule page
        IHWScheduleViewController *svc = [[IHWScheduleViewController alloc] initWithNibName:@"IHWScheduleViewController" bundle:nil];
        
        if(![self.navigationController.topViewController isKindOfClass:[IHWScheduleViewController class]]) {
            @try {
                [self.navigationController pushViewController:svc animated:NO];
                //Clear the ViewController stack
                [self.navigationController setViewControllers:[NSArray arrayWithObject:svc]];
            } @catch (NSException * e) {
                NSLog(@"Exception: %@", e);
            } @finally {
                //NSLog(@"finally");
            }
                }
        
        
    }
    
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [(IHWAppDelegate *)[UIApplication sharedApplication].delegate performSelectorOnMainThread:@selector(hideNetworkIcon) withObject:nil waitUntilDone:NO];
    NSURL *failingURL = [[error userInfo] objectForKey:@"NSErrorFailingURLKey"];
    NSLog(@"ERROR loading URL into webView: %@", error.debugDescription);
    if ([failingURL.description hasPrefix:@"http://www.hw.com/Default.aspx?tabid=3215&error="]) {
        //If HW.com gave us an error, then we pass the error on to the user:
        [[[UIAlertView alloc] initWithTitle:@"Schedule Unavailable" message:@"Your schedule is not currently available on HW.com. You can still enter your courses manually, though:" delegate:self cancelButtonTitle:@"Add Courses Manually" otherButtonTitles:nil] show];
        
    }
}

//Handles the error messages for the HW.com error and the errors in schedule parsing (above and below)
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Add Courses Manually"]) {
        UINavigationController *c = self.navigationController;
        [c popToRootViewControllerAnimated:NO];
        [c pushViewController:[[IHWGuidedCoursesViewController alloc] initWithNibName:@"IHWGuidedCoursesViewController" bundle:nil] animated:YES];
    } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Edit Courses"]){
        IHWNormalCoursesViewController *ncvc = [[IHWNormalCoursesViewController alloc] initWithNibName:@"IHWNormalCoursesViewController" bundle:nil];
        IHWScheduleViewController *svc = [[IHWScheduleViewController alloc] initWithNibName:@"IHWScheduleViewController" bundle:nil];
        if(![self.navigationController.topViewController isKindOfClass:[IHWScheduleViewController class]]) {
            @try {
                [self.navigationController pushViewController:svc animated:YES];
                [svc presentViewController:ncvc animated:NO completion:nil];
                [self.navigationController setViewControllers:[NSArray arrayWithObject:svc]];
            } @catch (NSException * e) {
                NSLog(@"Exception: %@", e);
            } @finally {
                //NSLog(@"finally");
            }
        }
    } else {
        self.navigationController.viewControllers = [NSArray arrayWithObjects:[[IHWFirstRunViewController alloc] initWithNibName:@"IHWFirstRunViewController" bundle:nil], self, nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)downloadScheduleFromURL:(NSString *)urlStr {
    self.loadingText.text = @"Schedule found. Downloading...";
    [(IHWAppDelegate *)[UIApplication sharedApplication].delegate performSelectorOnMainThread:@selector(showNetworkIcon) withObject:nil waitUntilDone:NO];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection self]; //to stop "unused" warnings
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    //Annoyingly, we have to handle the data bit by bit as it comes in.
    [self.resultData appendData:data];
}

//DEPRECIATED - No longer needed after hub integration
//-Jonathan Damico Sept 2 2016
/*
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [(IHWAppDelegate *)[UIApplication sharedApplication].delegate performSelectorOnMainThread:@selector(hideNetworkIcon) withObject:nil waitUntilDone:NO];
    
    //Schedule has finished loading -- parse it
    //You should really take a look at the HTML source of the schedule page before even attempting to understand how this works.
    NSError *error = nil;
    HTMLParser *parser = [[HTMLParser alloc] initWithData:self.resultData error:&error];
    if (error != nil) { NSLog(@"ERROR parsing schedule HTML: %@", error.debugDescription); return; }
    //Remove courses to prepare for new ones to be added
    [[IHWCurriculum currentCurriculum] removeAllCourses];
    NSArray *divs = [[parser body] findChildTags:@"div"];
    NSString *lastCode = courseCodesArray[n];
    NSString *lastName = courseNamesArray[n];
    NSArray *lastPeriodList = [(NSString*)[scheduleArray objectAtIndex:n] componentsSeparatedByString:@"."];
    BOOL shouldShowWarning = NO;
    
    
    //Break the list into components by day
    if (lastPeriodList.count != [IHWCurriculum currentCurriculum].campus) {
        //The course period list doesn't have the same number of days as the campus the user chose earlier.
        [[[UIAlertView alloc] initWithTitle:@"Wrong Campus!" message:@"You chose the wrong campus during the setup. Please start again." delegate:self cancelButtonTitle:@"Back" otherButtonTitles:nil] show];
        return;
    }
    //Create the course object once we have a course code, name, and period list
    IHWCourse *c = parseCourse(lastCode, lastName, lastPeriodList);
    if (c != nil) {
        //Course is valid -- add it
        if (![[IHWCurriculum currentCurriculum] addCourse:c]) NSLog(@"WARNING: Course Conflict!");
    }
    //reset the variables for the next time through the loop
    lastCode = nil;
    lastName = nil;
    lastPeriodList = nil;
    courseID = nil;
    n++;
    
    //Save the courses
    [[IHWCurriculum currentCurriculum] saveCourses];
    if (shouldShowWarning) {
        //Show a warning if the schedule was a preliminary schedule
        [[[UIAlertView alloc] initWithTitle:@"Full Schedule Unavailable" message:@"The full schedule is not yet available, so you will need to edit the courses that are not full-year and set the right semester/trimester." delegate:self cancelButtonTitle:@"Edit Courses" otherButtonTitles:nil] show];
    } else {
        //Otherwise go directly to the main schedule page
        IHWScheduleViewController *svc = [[IHWScheduleViewController alloc] initWithNibName:@"IHWScheduleViewController" bundle:nil];
        if(![self.navigationController.topViewController isKindOfClass:[IHWScheduleViewController class]]) {
            @try {
                [self.navigationController pushViewController:svc animated:NO];
                //Clear the ViewController stack
                [self.navigationController setViewControllers:[NSArray arrayWithObject:svc]];            } @catch (NSException * e) {
                NSLog(@"Exception: %@", e);
            } @finally {
                //NSLog(@"finally");
            }
        
        }
    }
}
*/
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
   self.myNewWebView.delegate = nil;
  //  [super dealloc];
}

@end

