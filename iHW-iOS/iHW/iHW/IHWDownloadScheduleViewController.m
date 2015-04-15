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

//This class controls the screen where the user logs into HW.com and downloads their schedule into the app.
@implementation IHWDownloadScheduleViewController {
    BOOL alreadyLoaded;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        alreadyLoaded = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
        //Make sure they actually have to log in each time
    }
    self.webView.delegate = self;
    self.webView.keyboardDisplayRequiresUserAction = NO;
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        self.topSpaceConstraint.constant = 0;
    }
    //Load the login page
    [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://www.hw.com/students/Login?returnurl=/students/SchoolResources/MyScheduleEvents.aspx"]]];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (IBAction)backPressed:(id)sender {
    if ([IHWCurriculum isFirstRun]) [self.navigationController popViewControllerAnimated:YES];
    else [self.navigationController setViewControllers:@[[[IHWScheduleViewController alloc] initWithNibName:@"IHWScheduleViewController" bundle:nil]] animated:YES];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    //Make sure that the UIWebView can only access these three URLs
    BOOL result = ([request.URL isEqual:[NSURL URLWithString:@"https://www.hw.com/students/Login?returnurl=/students/SchoolResources/MyScheduleEvents.aspx"]]
            || [request.URL isEqual:[NSURL URLWithString:@"http://www.hw.com/students/School-Resources/My-Schedule-Events"]]
            || [request.URL isEqual:[NSURL URLWithString:@"http://www.hw.com/students/SchoolResources/MyScheduleEvents.aspx"]]
            || [request.URL isEqual:[NSURL URLWithString:@"https://www.hw.com/students/SchoolResources/MyScheduleEvents.aspx"]]);
    if (result)
        [(IHWAppDelegate *)[UIApplication sharedApplication].delegate performSelectorOnMainThread:@selector(showNetworkIcon) withObject:nil waitUntilDone:NO];
    return result;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [(IHWAppDelegate *)[UIApplication sharedApplication].delegate performSelectorOnMainThread:@selector(hideNetworkIcon) withObject:nil waitUntilDone:NO];
    NSURL *url = webView.request.mainDocumentURL;
    //NSLog(@"URL did finish load: %@", url.description);
    if ([url isEqual:[NSURL URLWithString:@"https://www.hw.com/students/Login?returnurl=/students/SchoolResources/MyScheduleEvents.aspx"]]) {
        //If the login page just loaded, show the UIWebView and prompt the user to log in.
        self.webView.hidden = NO;
        self.loginPromptLabel.hidden = NO;
    } else if ([url isEqual:[NSURL URLWithString:@"http://www.hw.com/students/School-Resources/My-Schedule-Events"]]) {
        //If the user just logged in and the "My Schedule" page just loaded, hide the UIWebView and prompt.
        self.webView.hidden = YES;
        self.loginPromptLabel.hidden = YES;
        if (!alreadyLoaded) {
            //This is the first time the "My Schedule" page loaded, so we haven't injected the JavaScript to find the schedule URL yet.
            alreadyLoaded = YES;
            self.loadingText.text = @"Please wait, finding schedule...";
            //This string of JavaScript simulates clicking the "View" button on the "My Schedule" page.
            //That triggers a reload of the page, but once the page is reloaded, it contains the schedule URL.
            [self.webView stringByEvaluatingJavaScriptFromString:@"__doPostBack(\"dnn$ctr8420$InteractiveSchedule$lnkStudentScheduleHTML\", \"\");"];
        } else {
            //The JavaScript has already been injected and the page has reloaded.
            //Now we can scrape the schedule URL from the page by injecting JavaScript that finds and returns it.
            NSString *scheduleURL = [self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementById(\"dnn_ctr8420_InteractiveSchedule_txtWindowPopupUrl\").value"];
            self.resultData = [NSMutableData data];
            //Once we have the URL, we can download the schedule from it.
            [self downloadScheduleFromURL:scheduleURL];
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
        [self.navigationController pushViewController:svc animated:YES];
        [svc presentViewController:ncvc animated:YES completion:nil];
        [self.navigationController setViewControllers:[NSArray arrayWithObject:svc]];
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
    NSString *lastCode = nil;
    NSString *lastName = nil;
    NSString *lastPeriodList = nil;
    BOOL shouldShowWarning = NO;
    for (HTMLNode *div in divs) {
        //Loop through all the DIV elements on the (terrible) page (that doesn't conform to HTML specifications at all)
        //This is necessary because the page doesn't use unique IDs for elements (which it should)
        if ([[div getAttributeNamed:@"id"] isEqualToString:@"nameStudentName1-0"]) {
            //We currently don't do anything with the student's name
            //NSLog(@"Welcome, %@", [[[div findChildTags:@"span"] objectAtIndex:0] contents]);
        } else if ([[div getAttributeNamed:@"id"] isEqualToString:@"sectCode1"]) {
            //Found a course code
            lastCode = [[[div findChildTags:@"span"] objectAtIndex:0] contents];
            if (lastCode.length <= 4) {
                //This schedule is a preliminary schedule (without teachers, room numbers, etc.)
                //That means we can't find out what semester or trimester each course is in
                shouldShowWarning = YES;
            }
        } else if ([[div getAttributeNamed:@"id"] isEqualToString:@"sectTitle1"]) {
            //Found a course name
            lastName = [[[div findChildTags:@"span"] objectAtIndex:0] contents];
            if (lastName == nil) {
                //For long class names like "French V: Contemporary Culture and Communication", the name is in a double nested span tag
                lastName = [[[div findChildTags:@"span"] objectAtIndex:1] contents];
            }
        } else if ([[div getAttributeNamed:@"id"] isEqualToString:@"sectPeriodList1"]) {
            //Found a course period list
            lastPeriodList = [[[div findChildTags:@"span"] objectAtIndex:0] contents];
            //Break the list into components by day
            NSArray *lastPeriodComponents = [lastPeriodList componentsSeparatedByString:@"."];
            if (lastPeriodComponents.count != [IHWCurriculum currentCurriculum].campus) {
                if([[lastPeriodComponents firstObject]  isEqual: @"A"]&&[lastPeriodComponents count]==5) {
                        //Middle Schoolers who enroll in sports like football have a five day cycle for the sport. This is a workaround.
                        lastPeriodComponents=[lastPeriodComponents arrayByAddingObject:@"A"];
                    }
                else{
                //The course period list doesn't have the same number of days as the campus the user chose earlier.
                [[[UIAlertView alloc] initWithTitle:@"Wrong Campus!" message:@"You chose the wrong campus during the setup. Please start again." delegate:self cancelButtonTitle:@"Back" otherButtonTitles:nil] show];
                return;
                }
            }
            //Create the course object once we have a course code, name, and period list
            IHWCourse *c = parseCourse(lastCode, lastName, lastPeriodComponents);
            if (c != nil) {
                //Course is valid -- add it
                if (![[IHWCurriculum currentCurriculum] addCourse:c]) NSLog(@"WARNING: Course Conflict!");
            }
            //reset the variables for the next time through the loop
            lastCode = nil;
            lastName = nil;
            lastPeriodList = nil;
        } else if ([[div getAttributeNamed:@"id"] isEqualToString:@"Subreport8"]) {
            //The div with id "Subreport8" always comes after all of the courses, so we know we're done.
            break;
        }
    }
    //Save the courses
    [[IHWCurriculum currentCurriculum] saveCourses];
    if (shouldShowWarning) {
        //Show a warning if the schedule was a preliminary schedule
        [[[UIAlertView alloc] initWithTitle:@"Full Schedule Unavailable" message:@"The full schedule is not yet available, so you will need to edit the courses that are not full-year and set the right semester/trimester." delegate:self cancelButtonTitle:@"Edit Courses" otherButtonTitles:nil] show];
    } else {
        //Otherwise go directly to the main schedule page
        IHWScheduleViewController *svc = [[IHWScheduleViewController alloc] initWithNibName:@"IHWScheduleViewController" bundle:nil];
        [self.navigationController pushViewController:svc animated:YES];
        //Clear the ViewController stack
        [self.navigationController setViewControllers:[NSArray arrayWithObject:svc]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    self.webView.delegate = nil;
    //[super dealloc];
}

@end
