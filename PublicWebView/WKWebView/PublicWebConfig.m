//
//  PublicWebConfig.m
//  JavascriptBridge
//
//  Created by Passer on 2019/4/4.
//  Copyright © 2019 JavascriptBridge. All rights reserved.
//

#import "PublicWebConfig.h"

@implementation PublicWebConfig

/** 用户手机号 用来自动填充 **/
+ (NSString *)wk_configPhoneNumber {
    return @"15118000989";
}

#pragma Mark---- 传参给js的公共参数

+ (NSMutableDictionary *)wk_configPublicParams {
    
    // @"" 这些为了防止重复定义，所以需要自己传值进去
    
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    // 这两个手机号在存在的时候传值，请自行判断
    [dic setValue:@"" forKey:@"phone"]; // AES加密的手机号
    [dic setValue:@"" forKey:@"userPhone"]; // 不加密的手机号
    
    [dic setValue:@"" forKey:@"appName"];//传app名称
    [dic setValue:@"" forKey:@"imei"]; // 传idfa
    [dic setValue:@"" forKey:@"idfa"]; // 传idfa

    [dic setValue:@"" forKey:@"pkgName"]; //传app包名
    [dic setValue:@"" forKey:@"version"]; //传app版本号
    [dic setValue:@"App Store" forKey:@"channel"];
    [dic setValue:@"2" forKey:@"osType"];
    return dic;
}

@end
