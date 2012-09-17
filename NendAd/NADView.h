//
//  NADView.h
//  NendAd
//
//  Ver 1.3.1
//
//  広告枠ベースビュークラス

/*
 
 nendSDK_iOSはUIIDの生成にUIApplication+UIIDを利用しています
 
 UIApplication+UIID
 Copyright (c) 2011 Masashi Ono.
 
 This code is licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import <UIKit/UIKit.h>

#define NAD_ADVIEW_SIZE_320x50  CGSizeMake(320,50)

@class NADView;

@protocol NADViewDelegate <NSObject>

#pragma mark - NADViewの広告ロードが初めて成功した際に通知されます
- (void)nadViewDidFinishLoad:(NADView *)adView;

@optional

#pragma mark - 広告受信が成功した際に通知されます
- (void)nadViewDidReceiveAd:(NADView *)adView;

#pragma mark - 広告受信に失敗した際に通知されます
- (void)nadViewDidFailToReceiveAd:(NADView *)adView;

@end

@interface NADView : UIView {
    id delegate;
}

#pragma mark - delegateオブジェクトの指定
@property (nonatomic, assign) id <NADViewDelegate> delegate;

#pragma mark - モーダルビューを表示元のビューコントローラを指定
@property (nonatomic, assign) UIViewController *rootViewController;

#pragma mark - 広告枠のapiKeyとspotIDをセット
- (void)setNendID:(NSString *)apiKey spotID:(NSString *)spotID;

#pragma mark - 広告のロード開始
- (void)load;

#pragma mark - 広告のロード開始
//  接続エラーや広告設定受信エラーなどの場合にリトライする間隔を、NSDictionaryで任意指定出来ます。
//  30 - 3600 の間で指定してください。範囲外指定された場合は標準の60秒が適用されます。
//
// 例) 180秒指定
//   [nadView load:[NSDictionary dictionaryWithObjectsAndKeys:@"180",@"retry",nil]];
- (void)load:(NSDictionary *)parameter;

#pragma mark - 広告の定期ロード中断を要求します
- (void)pause;

#pragma mark - 広告の定期ロード再開を要求します
- (void)resume;

@end
