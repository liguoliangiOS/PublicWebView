//
//  PublicWebViewController.m
//  JavascriptBridge
//
//  Created by Passer on 2019/4/4.
//  Copyright © 2019 JavascriptBridge. All rights reserved.
//

#import "PublicWebViewController.h"
#import <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "PublicWebViewController+wkPublic.h"
#import "PublicWebConfig.h"

static NSString * paramsName = @"getIosAppUserInfo";


@interface PublicWebViewController ()<WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>

@property (nonatomic, strong)  UIProgressView * wkProgress;
@property(nonatomic,strong)    WKWebView  * wkView;
@property (nonatomic, strong)  WKUserContentController *  wkUserContent;

@property (nonatomic, copy) JSBridgeFinishedLoad  loadComplete;
@property (nonatomic, assign) NSInteger    loadCount;

@end

@implementation PublicWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.loadCount = 0;
    [self.view addSubview:self.wkView];
    [self.view addSubview:self.wkProgress];
    [self wk_loadWebUrl];
}

/**
 
 http://idaitest.iadcn.com/wt/loanDetail/sddkw/#/loan?pageTp=2&proId=73&appPkgName=com.public.eee&osType=2&imei=B0523F98-EDB2-4AE6-8B84-DF112751525B&channel=App Store&apkVersion=1.0&appName=丰富贷&backName=速借钱庄&t=1
 
 http://idaitest.iadcn.com/wt/loanDetail/sddkw/%23/loan?pageTp=2&proId=73&appPkgName=com.public.eee&osType=2&imei=B0523F98-EDB2-4AE6-8B84-DF112751525B&channel=App%20Store&apkVersion=1.0&appName=%E4%B8%B0%E5%AF%8C%E8%B4%B7&backName=%E9%80%9F%E5%80%9F%E9%92%B1%E5%BA%84&t=1
 
 http://idaitest.iadcn.com/wt/loanDetail/sddkw/#/loan?pageTp=2&proId=73&appPkgName=com.public.eee&osType=2&imei=B0523F98-EDB2-4AE6-8B84-DF112751525B&channel=App%20Store&apkVersion=1.0&appName=%E4%B8%B0%E5%AF%8C%E8%B4%B7&backName=%E9%80%9F%E5%80%9F%E9%92%B1%E5%BA%84&t=1

 **/

- (void)wk_loadWebUrl {
    NSURL * url = [NSURL URLWithString:self.url];
    if (url == nil) {
        url = [NSURL URLWithString:[self wk_utf_8:self.url]];
    }
    [self.wkView loadRequest:[NSURLRequest requestWithURL:url]];
}

#pragma mark --- 网络回调方法

- (void)wk_loadUrlSuccess:(JSBridgeFinishedLoad)complete {
    self.loadComplete = complete;
}

#pragma Mark -- 解决白屏的问题

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    [webView reload];
}

#pragma mark WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:paramsName]) {
        [self wk_messageView:self.wkView dataDic:[PublicWebConfig wk_configPublicParams] messageName:paramsName];
    }
}


#pragma mark WKNavigationDelegate

    // 开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
        // 可以在这里做正在加载的提示动画 然后在加载完成代理方法里移除动画
    self.wkProgress.hidden = NO;
    self.wkProgress.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    [self.view bringSubviewToFront:self.wkProgress];
}

    // 网络错误
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation
      withError:(NSError *)error {
    self.wkProgress.hidden = YES;
    if (error.code == -1003) {
        [webView reload];
    }
}

    // 网页加载完成
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    self.wkProgress.hidden = YES;
    NSString * phone = [PublicWebConfig wk_configPhoneNumber];
    if (phone) {
        [self wk_autoInputPhoneNumber:phone wkView:webView];
    }
    if (self.loadComplete) {
        __weak typeof(self) weakSelf = self;
        self.loadComplete(weakSelf.loadCount, weakSelf.url);
        self.loadCount += 1;
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    self.wkProgress.hidden = YES;
}

    // 加载不授信的https
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {  // 判断服务器采用的验证方法
    
    if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
        if (challenge.previousFailureCount == 0) {  // 如果没有错误的情况下 创建一个凭证，并使用证书
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        }else { // 验证失败，取消本次验证
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        }
    } else {
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }
}

    // 这个代理可以使得服务器返回200以外的状态码时，都调用请求失败的方法 再用请求失败的方法里面 调用不转码的 url
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse
decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    if (((NSHTTPURLResponse *)navigationResponse.response).statusCode == 200) {
        decisionHandler (WKNavigationResponsePolicyAllow);
    } else {
        decisionHandler(WKNavigationResponsePolicyCancel);
    }
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    if ([webView.URL.absoluteString hasPrefix:@"itms-appss://"]) {
        [self wk_openExternalUrlWithStr:webView.URL];
    }
    if ([webView.URL.absoluteString hasPrefix:@"itms-apps://"]) {
        [self wk_openExternalUrlWithStr:webView.URL];
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if (navigationAction.targetFrame == nil) { //如果是跳转一个新页面
        [webView loadRequest:navigationAction.request];
    }
        ///[url.absoluteString containsString:@"itms-services://"] 下载证书安装应用的方式
    NSURL  *url = navigationAction.request.URL;
    if ([[url host] isEqualToString:@"itunes.apple.com"] || [url.absoluteString containsString:@"itms-services://"]) {
        if ([self wk_openExternalUrlWithStr:url]) {
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    decisionHandler(WKNavigationActionPolicyAllow);
    return;
}



- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.wkProgress.progress = self.wkView.estimatedProgress;
        if (self.wkProgress.progress == 1) {
            __weak typeof (self)weakSelf = self;
            [UIView animateWithDuration:0.25f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                weakSelf.wkProgress.transform = CGAffineTransformMakeScale(1.0f, 1.4f);
            } completion:^(BOOL finished) {
                weakSelf.wkProgress.hidden = YES;
                
            }];
        }
    } else if ([keyPath isEqualToString:@"title"]) {
        if (object == self.wkView) self.navigationItem.title = self.wkView.title;
    } else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


#pragma mark WKUIDelegate

    // alert
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message
initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    [self wk_alertWithVC:self message:message];
    completionHandler();
}

    // confirm
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message
initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    [self wk_alertWithVC:self message:message selectButton:^(BOOL selectValue) {
        completionHandler(selectValue);
    }];
}

    // prompt
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt
    defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    [self wk_alertWithVC:self title:prompt message:@"" defaultText:defaultText selectButton:^(NSString * _Nullable inputText) {
        completionHandler(inputText);
    }];
}

#pragma mark --- dealloc

- (void)dealloc {
    [self.wkView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.wkView removeObserver:self forKeyPath:@"title"];
    [[self.wkView configuration].userContentController removeScriptMessageHandlerForName:paramsName];
}

#pragma mark --- lazy

- (UIProgressView *)wkProgress {
    if (!_wkProgress) {
        _wkProgress = [[UIProgressView alloc] initWithFrame:CGRectMake(0, [self wk_navigationHeight], self.view.frame.size.width, 2)];
        _wkProgress.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    }
    return _wkProgress;
}

- (WKWebView *)wkView {
    if(!_wkView) {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        self.wkUserContent = config.userContentController;
        [self.wkUserContent addScriptMessageHandler:self name:paramsName];

        _wkView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
        _wkView.navigationDelegate = self;
        _wkView.backgroundColor = [UIColor whiteColor];
        _wkView.UIDelegate = self;
        [_wkView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
        [_wkView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    }
    return _wkView;
}


@end
