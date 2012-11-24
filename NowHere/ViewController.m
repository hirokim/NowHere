//
//  ViewController.m
//  NowHere
//
//  Created by 松瀬 弘樹 on 12/09/16.
//  Copyright (c) 2012年 松瀬 弘樹. All rights reserved.
//

#import "ViewController.h"

#define ITUNES_URL @"http://itunes.apple.com/us/app/id554113286?mt=8"

#define OPEN_OTHER 0
#define OPEN_SMS 1
#define OPEN_MAIL 2
#define OPEN_TWITTER 3

@interface ViewController ()
{
    ADBannerView *iAdbanner;
    
    CLLocationManager* locmanager;
    CLPlacemark *placemark;
    UIDocumentInteractionController *diController;
    
    BOOL bannerIsVisible;
}

@end

@implementation ViewController

//======================================================
//
//　画面ロード後
//
//======================================================
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    locmanager = [[CLLocationManager alloc] init];
    [locmanager setDelegate:self];
    [locmanager setDesiredAccuracy:kCLLocationAccuracyBest];    //精度 (デフォルトはBest)
    [locmanager setDistanceFilter:kCLDistanceFilterNone];       //イベントを発生させる最小の距離（デフォルトは距離指定なし）
    
    // 現在地情報更新スタート
    [locmanager startUpdatingLocation];
    
    // GoogleMap読み込み
    NSString *path = [[NSBundle mainBundle] pathForResource:@"GoogleMap" ofType:@"html"];
    NSData *htmlData = [NSData dataWithContentsOfFile:path];
    NSString *htmlStr = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
    [self.webGoogleMapview loadHTMLString:htmlStr baseURL:nil];

    self.nadView = [[NADView alloc] initWithFrame:CGRectMake(0,
                                                             0,
                                                             NAD_ADVIEW_SIZE_320x50.width,
                                                             NAD_ADVIEW_SIZE_320x50.height)];
    
    [self.nadView setNendID:@"558c894678fa36d5732ac8dbdc65d2350ab0666b" spotID:@"19662"];
    [self.nadView setDelegate:self];
    [self.nadView load];
    [self.adBaseview addSubview:self.nadView];
    
    bannerIsVisible = NO;
    iAdbanner = [[ADBannerView alloc] initWithFrame:CGRectZero];
    iAdbanner.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
    iAdbanner.delegate = self;
    [self.adBaseview addSubview:iAdbanner];
    iAdbanner.frame = CGRectOffset(iAdbanner.frame, 0, 50);

    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    int usingMap = [ud integerForKey:@"usingMap"];
    self.segmentMap.selectedSegmentIndex = usingMap;
    if (usingMap == 0)
    {
        self.webGoogleMapview.hidden = YES;
    }
    else
    {
        self.mapview.hidden = YES;
    }
    
    self.segmentMap.hidden = NO;
}

//======================================================
//
//　地図きりかえ
//
//======================================================
- (IBAction)swichMapview:(id)sender
{
    int usingMap = self.segmentMap.selectedSegmentIndex;
    if (usingMap == 0)
    {
        self.webGoogleMapview.hidden = YES;
        self.mapview.hidden = NO;
    }
    else
    {
        self.webGoogleMapview.hidden = NO;
        self.mapview.hidden = YES;
    }
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setInteger:usingMap forKey:@"usingMap"];
}

//======================================================
//
//　画面表示前
//
//======================================================
- (void)viewWillAppear:(BOOL)animated
{
    [[GANTracker sharedTracker] trackPageview:@"/現在地マップ" withError:nil];
}

//======================================================
//
//　画面アンロード後
//
//======================================================
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

//======================================================
//
//　画面の向き
//
//======================================================
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//======================================================
//
//　現在地情報取得時
//
//======================================================
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    // マップ表示域設定
    MKCoordinateSpan span = MKCoordinateSpanMake(0.003, 0.003);
    MKCoordinateRegion region = MKCoordinateRegionMake(newLocation.coordinate, span);
    
    // 現在地表示
    [self.mapview setRegion:region animated:YES];
    
    // 現在地情報更新ストップ
    [locmanager stopUpdatingLocation];
    
    // 逆ジオコーディングで住所情報取得
    [self reverseGeocodeLocation:newLocation];
}

//======================================================
//
//　現在地情報自動更新時
//
//======================================================
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    // 逆ジオコーディングで住所情報取得
    [self reverseGeocodeLocation:userLocation.location];
}

//======================================================
//
//　逆ジオコーディング
//
//======================================================
- (void)reverseGeocodeLocation:(CLLocation *)location
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:
     ^(NSArray* placemarks, NSError* error)
     {
         if ([placemarks count] > 0)
         {
             placemark = (CLPlacemark *)[placemarks lastObject];
         }
     }];
}

//======================================================
//
//　現在地更新ボタン押下
//
//======================================================
- (IBAction)showNowLocation:(id)sender
{
    [[GANTracker sharedTracker] trackEvent:@"/現在地マップ"
                                    action:@"更新ボタン押下"
                                     label:nil
                                     value:-1
                                 withError:nil];
    // 現在地情報更新スタート
    [locmanager startUpdatingLocation];
}

//======================================================
//
//　現在地送信ボタン押下
//
//======================================================
- (IBAction)sendNowLocation:(id)sender
{
    if (placemark == nil)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"エラー")
                                                        message:NSLocalizedString(@"Position information is unacquirable.", @"位置情報が取得できません。")
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert setTag:99];
        [alert show];
        return;
    }
    
    [[GANTracker sharedTracker] trackEvent:@"/現在地マップ"
                                    action:@"現在地情報送信"
                                     label:[self createAddressText]
                                     value:-1
                                 withError:nil];
    
    // アクションシートオブジェクトを生成
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"send", @"送信")
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"cancel", @"キャンセル")
                                               destructiveButtonTitle:NSLocalizedString(@"other", @"LINEなどその他のアプリ")
                                                    otherButtonTitles:@"SMS", @"Mail", @"Twitter", nil];
    // シートスタイルを設定
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];

    // アクションシートを表示
    [actionSheet showInView:self.view];
}

//======================================================
//
//　アクションシートボタン押下
//
//======================================================
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *trackStr = nil;
    
    switch (buttonIndex) {
        case OPEN_OTHER:
            trackStr = @"その他のアプリ";
            [self openOtherApplication];
            break;
            
        case OPEN_SMS:
            trackStr = @"SMS";
            [self openSMS];
            break;
            
        case OPEN_MAIL:
            trackStr = @"メール";
            [self openMail];
            break;
            
        case OPEN_TWITTER:
            trackStr = @"Twitter";
            [self openTwitter];
            break;
            
        default:
            trackStr = @"キャンセル";
            break;
    }
    
    [[GANTracker sharedTracker] trackEvent:@"/現在地マップ"
                                    action:@"送信ボタン押下"
                                     label:trackStr
                                     value:-1
                                 withError:nil];
}

//======================================================
//
//　その他のアプリで開く
//
//======================================================
- (void)openOtherApplication
{
    // メッセージ作成
    NSMutableString *text = [NSMutableString stringWithFormat:@"%@", NSLocalizedString(@"It is here now!!", @"今ココにいるよ！")];
    [text appendString:@"\n"];
    [text appendString:[self createAddressText]];
    [text appendString:@"\n"];
    [text appendString:[self createMapURL]];
    
    // UIPasteboardにコピー
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:text];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"copy text", @"位置情報をコピーしました。")
                                                    message:NSLocalizedString(@"use paste", @"貼付けて使ってください。")
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK", nil];
    [alert setTag:OPEN_OTHER];
    [alert show];
}

//======================================================
//
//　ドキュメントコントローラー開く
//
//======================================================
- (void)presentUIDocumentInteractionController
{
    // 地図を画像ファイルとして保存
    UIImage *nowImage = [self convertToImage:self.mapview];
    NSString *filePath = [self saveImageOnPng:nowImage ImageName:@"nowHere.png"];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    
    // 他のアプリ選択画面表示
    diController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
    diController.delegate = self;
    BOOL rsult = [diController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
    if (!rsult)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"エラー")
                                                        message:NSLocalizedString(@"can open app is nothing", @"開けるアプリ無し")
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert setTag:99];
        [alert show];
    }
}

//======================================================
//
//　メールで開く
//
//======================================================
- (void)openMail
{
    // 地図を画像に変換
    UIImage *nowImage = [self convertToImage:self.mapview];
    NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(nowImage)];
    
    // メッセージ作成
    NSMutableString *text = [NSMutableString stringWithFormat:@"%@\n", [self createAddressText]];
    [text appendString:[self createMapURL]];
    
    // メール画面作成
    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
    [mailViewController setMailComposeDelegate:self];
    [mailViewController setSubject:NSLocalizedString(@"It is here now!!", @"今ココにいるよ！")];
    [mailViewController setMessageBody:text isHTML:NO];
    [mailViewController addAttachmentData:imageData mimeType:@"image/png" fileName:@"nowHere"];
    [self presentModalViewController:mailViewController animated:YES];
}

//======================================================
//
//　メールで開いた後
//
//======================================================
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    // メール画面を閉じる
    [self dismissModalViewControllerAnimated:YES];
}

//======================================================
//
//　SMSで開く
//
//======================================================
- (void)openSMS
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Selection", @"選択")
                                                    message:NSLocalizedString(@"Which is copied?", @"どちらをコピーしますか？")
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:NSLocalizedString(@"location", @"位置情報"),
                                                              NSLocalizedString(@"map", @"地図"),
                                                              NSLocalizedString(@"cancel", @"キャンセル"),nil];
    [alert setTag:OPEN_SMS];
    [alert show];
}

//======================================================
//
//　SMSで開くボタン押下
//
//======================================================
- (void)openSMSWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 2)
    {
        // キャンセルボタン
        return;
    }
    
    // ペーストボード
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    
    // 位置情報コピー
    if (buttonIndex == 0)
    {
        // メッセージ作成
        NSMutableString *text = [NSMutableString stringWithFormat:@"%@", NSLocalizedString(@"It is here now!!", @"今ココにいるよ！")];
        [text appendString:@"\n\n"];
        [text appendString:[self createAddressText]];
        [text appendString:@"\n"];
        [text appendString:[self createMapURL]];
        
        // UIPasteboardにコピー
        [pasteboard setString:text];
    }
    
    // 地図コピー
    else if (buttonIndex == 1)
    {
        // 地図を画像に変換
        UIImage *nowImage = [self convertToImage:self.mapview];
        
        // UIPasteboardにコピー
        [pasteboard setImage:nowImage];
    }
    
    // SMSを開く
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"sms://"]];
}

//======================================================
//
//　SMSで開いた後
//
//======================================================
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    // メール画面を閉じる
    [self dismissModalViewControllerAnimated:YES];
}

//======================================================
//
//　アラートボタン押下
//
//======================================================
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == OPEN_SMS)
    {
        // SMSで開く
        [self openSMSWithButtonIndex:buttonIndex];
    }
    else if (alertView.tag == OPEN_OTHER)
    {
        // 他のアプリで開く
        [self performSelector:@selector(presentUIDocumentInteractionController) withObject:nil afterDelay:0.3];
    }
    
}

//======================================================
//
//　Twitterで開く
//
//======================================================
- (void)openTwitter
{
    // 地図を画像に変換
    UIImage *nowImage = [self convertToImage:self.mapview];
    
    // メッセージ作成
    NSMutableString *text = [NSMutableString stringWithFormat:@"%@", NSLocalizedString(@"It is here now!!", @"今ココにいるよ！")];
    [text appendString:@"\n"];
    [text appendString:[self createAddressText]];
    [text appendString:@"\n"];
    
    TWTweetComposeViewController *viewController = [[TWTweetComposeViewController alloc] init];
    [viewController setInitialText:text];
    [viewController addImage:nowImage];
    
    // ツイート画面表示
    [self presentModalViewController:viewController animated:YES];
}

//======================================================
//
//　UIViewをUIImageに変換
//
//======================================================
- (UIImage *)convertToImage:(UIView *)uiv
{
    UIGraphicsBeginImageContextWithOptions(uiv.frame.size, NO, 0);
    [uiv.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

//======================================================
//
//　UIImageをファイルに書き出す
//
//======================================================
- (NSString *)saveImageOnPng:(UIImage *)image ImageName:(NSString *)name
{
    // 表示画像を一時的にファイルに書き出す
    NSString* a_tmp_dir = NSTemporaryDirectory();
    NSString *path = [a_tmp_dir stringByAppendingPathComponent:name];
    NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(image)];
    [imageData writeToFile:path atomically:YES];
    
    return path;
}

//======================================================
//
//　住所の文字を取得
//
//======================================================
- (NSString *)createAddressText
{
//    NSLog(@"name : %@", placemark.name);
//    NSLog(@"ocean : %@", placemark.ocean);
//    NSLog(@"postalCode : %@", placemark.postalCode);
//    NSLog(@"subAdministrativeArea : %@", placemark.subAdministrativeArea);
//    NSLog(@"subLocality : %@", placemark.subLocality);
//    NSLog(@"subThoroughfare : %@", placemark.subThoroughfare);
//    NSLog(@"thoroughfare : %@", placemark.thoroughfare);
//    NSLog(@"administrativeArea : %@", placemark.administrativeArea);
//    NSLog(@"inlandWater : %@", placemark.inlandWater);
//    NSLog(@"ISOcountryCode : %@", placemark.ISOcountryCode);
//    NSLog(@"locality : %@", placemark.locality);
//    NSLog(@"addressDictionary CountryCode : %@", [placemark.addressDictionary objectForKey:@"CountryCode"]);
//    NSLog(@"addressDictionary Country : %@", [placemark.addressDictionary objectForKey:@"Country"]);
//    NSLog(@"addressDictionary ZIP : %@", [placemark.addressDictionary objectForKey:@"ZIP"]);
//    NSLog(@"addressDictionary State : %@", [placemark.addressDictionary objectForKey:@"State"]);
//    NSLog(@"addressDictionary City : %@", [placemark.addressDictionary objectForKey:@"City"]);
//    NSLog(@"addressDictionary SubLocality : %@", [placemark.addressDictionary objectForKey:@"SubLocality"]);
//    NSLog(@"addressDictionary FormattedAddressLines : %@", [placemark.addressDictionary objectForKey:@"FormattedAddressLines"]);
//    NSLog(@"addressDictionary Name : %@", [placemark.addressDictionary objectForKey:@"Name"]);
//    NSLog(@"addressDictionary SubThoroughfare : %@", [placemark.addressDictionary objectForKey:@"SubThoroughfare"]);
//    NSLog(@"addressDictionary Thoroughfare : %@", [placemark.addressDictionary objectForKey:@"Thoroughfare"]);
    
    NSMutableString *addressStr = [NSMutableString stringWithCapacity:0];
    NSArray *array = [placemark.addressDictionary objectForKey:@"FormattedAddressLines"];
    for (NSString *tmpStr in array)
    {
        [addressStr appendFormat:@"%@ \n", tmpStr];
    }
    
    return addressStr;
}

//======================================================
//
//　位置情報URLの文字を取得
//
//======================================================
- (NSString *)createMapURL
{
    NSString *urlStr = @"http://maps.google.com/maps?q=%@@%f,%f";
    
    float latitude = placemark.location.coordinate.latitude;    // 緯度
    float longitude = placemark.location.coordinate.longitude;  // 経度
    
    return [NSString stringWithFormat:urlStr, NSLocalizedString(@"Here", @"今ココ"), latitude, longitude];
}

#pragma mark - NADView delegate

// NADViewのロードが成功した時に呼ばれる
- (void)nadViewDidFinishLoad:(NADView *)adView
{
    NSLog(@"FirstView delegate nadViewDidFinishLoad:");
}

// 広告受信成功
-(void)nadViewDidReceiveAd:(NADView *)adView
{
    NSLog(@"FirstView delegate nadViewDidReceiveAd:");
}

// 広告受信エラー
-(void)nadViewDidFailToReceiveAd:(NADView *)adView
{
    NSLog(@"FirstView delegate nadViewDidFailToReceiveAd:");
}

#pragma mark - ADBannerView delegate

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave {
    
	BOOL shouldExecuteAction = YES;
    if (!willLeave && shouldExecuteAction)
    {
        
    }
    return shouldExecuteAction;
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (!bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
		// assumes the banner view is offset 50 pixels so that it is not visible.
        banner.frame = CGRectOffset(banner.frame, 0, -50);
        [UIView commitAnimations];
        bannerIsVisible = YES;
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
	if (bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
		// assumes the banner view is at the top of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, 50);
        [UIView commitAnimations];
        bannerIsVisible = NO;
    }
}

@end
