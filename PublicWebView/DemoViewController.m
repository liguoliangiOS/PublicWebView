//
//  DemoViewController.m
//  PublicWebView
//
//  Created by Passer on 2019/4/10.
//  Copyright © 2019 PublicWebView. All rights reserved.
//

#import "DemoViewController.h"
#import "PublicWebViewController.h"

@interface DemoViewController ()

@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self loadNormalWebView];

}

- (void)loadNormalWebView {
    PublicWebViewController * webVc = [[PublicWebViewController alloc] init];
    webVc.url =  @"http://idaitest.iadcn.com/wt/loanDetail/sddkw/#/loan?pageTp=2&proId=73&appPkgName=com.public.eee&osType=2&imei=B0523F98-EDB2-4AE6-8B84-DF112751525B&channel=App Store&apkVersion=1.0&appName=丰富贷&backName=速借钱庄&t=1";//@"https://h.sinaif.com/html/activity/promotion/middlePage/ABTLoading-dw.html?code=O4CVX";//self.feild.text ;
    [self.navigationController pushViewController:webVc animated:YES];
    
    __block NSString * title = @"这是一个上报产品的名称";
    [webVc wk_loadUrlSuccess:^(NSInteger finishedCount, NSString * _Nonnull loadUrl) {
        if (finishedCount == 0) {
                // 提交title
        } else {  //打开多次的时候需要在参数后面拼接次数
            
                //提交title
            title = [NSString stringWithFormat:@"%@-%ld", title, (long)finishedCount];
            
        }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
