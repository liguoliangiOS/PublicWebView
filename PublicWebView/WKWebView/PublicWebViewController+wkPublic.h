//
//  PublicWebViewController+wkPublic.h
//  JavascriptBridge
//
//  Created by Passer on 2019/4/4.
//  Copyright © 2019 JavascriptBridge. All rights reserved.
//

#import "PublicWebViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class  WKWebView;

@interface PublicWebViewController (wkPublic)

- (CGFloat)wk_navigationHeight;

- (NSString *)wk_utf_8:(NSString *)str;

- (BOOL)wk_openExternalUrlWithStr:(NSURL *)Url;

#pragma marek ---- 传公共参数给H5
- (void)wk_messageView:(WKWebView *)wkView dataDic:(NSMutableDictionary *)dataDic
           messageName:(NSString *) messageName;

#pragma marek ---- 给webView电话号码输入框填充 手机号

- (void)wk_autoInputPhoneNumber:(NSString *)phoneNumber wkView:(WKWebView *)wkView;

#pragma mark --- alert 弹窗

- (void)wk_alertWithVC:(UIViewController *)controller message:(NSString *)message;

- (void)wk_alertWithVC:(UIViewController *)controller message:(NSString *)message
          selectButton:(void(^)(BOOL selectValue))completion;


- (void)wk_alertWithVC:(UIViewController *)controller title:(NSString *)title
               message:(NSString *)message defaultText:(NSString *)defaultText
          selectButton:(void(^)(NSString * _Nullable inputText))completion;

@end

NS_ASSUME_NONNULL_END
