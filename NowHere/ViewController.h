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
#import <iAd/iAd.h>
#import "NADView.h"
#import "GANTracker.h"

@interface ViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UIActionSheetDelegate, UIDocumentInteractionControllerDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIAlertViewDelegate, ADBannerViewDelegate, NADViewDelegate>
{

}

@property (nonatomic) NADView *nadView;
@property (nonatomic) IBOutlet MKMapView *mapview;
@property (nonatomic) IBOutlet UIToolbar *toolbar;
@property (nonatomic) IBOutlet UISegmentedControl *segmentMap;
@property (nonatomic) IBOutlet UIWebView *webGoogleMapview;
@property (nonatomic) IBOutlet UIView *adBaseview;

- (IBAction)showNowLocation:(id)sender;
- (IBAction)sendNowLocation:(id)sender;
- (IBAction)swichMapview:(id)sender;

@end
