//
//  ViewController.h
//  NowHere
//
//  Created by 松瀬 弘樹 on 12/09/16.
//  Copyright (c) 2012年 松瀬 弘樹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MessageUI/MessageUI.h>
#import <Twitter/TWTweetComposeViewController.h>

@interface ViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UIActionSheetDelegate, UIDocumentInteractionControllerDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIAlertViewDelegate>

@property (nonatomic) IBOutlet MKMapView *mapview;
@property (nonatomic) IBOutlet UIToolbar *toolbar;

- (IBAction)showNowLocation:(id)sender;
- (IBAction)sendNowLocation:(id)sender;

@end
