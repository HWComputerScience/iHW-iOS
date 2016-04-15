//
//  IHWDownloadScheduleViewController.h
//  iHW
//
//  Created by Jonathan Burns on 8/12/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IHWDownloadScheduleViewController : UIViewController <UIWebViewDelegate, NSURLConnectionDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UILabel *loginPromptLabel;
@property (weak, nonatomic) IBOutlet UILabel *loadingText;
@property (strong, nonatomic) NSMutableData *resultData;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topSpaceConstraint;

@end
