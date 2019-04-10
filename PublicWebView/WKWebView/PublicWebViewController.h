//
//  PublicWebViewController.h
//  JavascriptBridge
//
//  Created by Passer on 2019/4/4.
//  Copyright © 2019 JavascriptBridge. All rights reserved.
//  https://github.com/liguoliangiOS/PublicWebView.git

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^JSBridgeFinishedLoad)(NSInteger finishedCount, NSString * loadUrl);

@interface PublicWebViewController : UIViewController

/** 需要打开的链接 用来自动填充 **/
@property (nonatomic, copy) NSString    *  url;

/** 加载成功以后 回调 用来上传h5打开日志的 **/
- (void)wk_loadUrlSuccess:(JSBridgeFinishedLoad)complete;

@end

NS_ASSUME_NONNULL_END
