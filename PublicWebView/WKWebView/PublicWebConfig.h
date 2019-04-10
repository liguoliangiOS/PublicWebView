//
//  PublicWebConfig.h
//  JavascriptBridge
//
//  Created by Passer on 2019/4/4.
//  Copyright © 2019 JavascriptBridge. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PublicWebConfig : NSObject

/** 用户手机号 用来自动填充 **/
+ (NSString *)wk_configPhoneNumber;

/** 传参给js的公共参数 **/
+ (NSMutableDictionary *)wk_configPublicParams;

@end

NS_ASSUME_NONNULL_END
