//
//  PublicWebViewController+wkPublic.m
//  JavascriptBridge
//
//  Created by Passer on 2019/4/4.
//  Copyright © 2019 JavascriptBridge. All rights reserved.
//

#import "PublicWebViewController+wkPublic.h"
#import <WebKit/WebKit.h>

@implementation PublicWebViewController (wkPublic)

- (CGFloat)wk_navigationHeight {
    CGRect statusRect = [[UIApplication sharedApplication] statusBarFrame];
    CGRect navRect = self.navigationController.navigationBar.frame;
    return (statusRect.size.height + navRect.size.height);
}

#pragma mark --- 字符串UTF_8

- (NSString *)wk_utf_8:(NSString *)str {
    if (str.length) {
        str = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, (CFStringRef)@"!NULL,'()*+,-./:;=?@_~%#[]", NULL, kCFStringEncodingUTF8));
    }
    return str;
}

- (BOOL)wk_openExternalUrlWithStr:(NSURL *)Url {
    if ([[UIApplication sharedApplication] canOpenURL:Url]) {
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:Url options:@{} completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:Url];
        }
        return YES;
    } else {
        return NO;
    }
}

#pragma mark --- 传公共参数给H5

- (void)wk_messageView:(WKWebView *)wkView dataDic:(NSMutableDictionary *)dataDic messageName:(NSString *) messageName {
    NSString * data = [self wk_dictionaryToJsonStr:dataDic];
    NSString * Method = [NSString stringWithFormat:@"%@(%@)",messageName, [self wk_replaceWhiteSpaceString:data]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [wkView evaluateJavaScript:Method completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        }];
    });
}

- (BOOL)wk_isPhoneNumber:(NSString *)phoneNumber {
    if (phoneNumber.length != 11) return NO;
    NSString * MOBILE = @"^1\\d{10}$";
    NSPredicate * regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    return [regextestmobile evaluateWithObject:phoneNumber];
}

#pragma mark --- 去空格字符串

- (NSString *)wk_replaceWhiteSpaceString:(NSString *)str {
    NSString * replaceStr= str;
    replaceStr = [replaceStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    replaceStr = [replaceStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    replaceStr = [replaceStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    replaceStr = [replaceStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    return replaceStr;
}

#pragma mark --- Joson转JosonString

- (NSString *)wk_dictionaryToJsonStr:(NSDictionary *)dic {
    if (dic) {
        NSError *parseError = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&parseError];
        return [[NSString alloc] initWithData:jsonData
                                     encoding:NSUTF8StringEncoding];
    }
    return nil;
}

#pragma marek ---- 给webView电话号码输入框填充 手机号

- (void)wk_autoInputPhoneNumber:(NSString *)phoneNumber wkView:(WKWebView *)wkView {
    if ([self wk_isPhoneNumber:phoneNumber]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSString * strNumber = [self wk_inputWithPlaceholder:phoneNumber];
            [wkView evaluateJavaScript:strNumber completionHandler:^(id _Nullable response, NSError * _Nullable error) {
                if (error != nil) {
                    if (![response isEqualToString:phoneNumber]) {
                        NSString * strNewNumber = [self wk_inputWithtypeTel:phoneNumber];
                        [wkView evaluateJavaScript:strNewNumber completionHandler:^(id _Nullable response, NSError * _Nullable error) {}];
                    }
                }
            }];
            
        });
    }
}

/**  placeholder  的方式判断 **/
- (NSString *)wk_inputWithPlaceholder:(NSString *)phoneStr {
    return [NSString stringWithFormat:@"javascript:document.querySelector('input[placeholder*=\"手机号\"]').value = '%@'",phoneStr];
}

/**  type tel 的方式判断 **/
- (NSString *)wk_inputWithtypeTel:(NSString *)phoneStr {
    return [NSString stringWithFormat:@"javascript:document.querySelector('input[type*=\"tel\"]').value = '%@'", phoneStr];
}


#pragma mark --- alert 弹窗

- (void)wk_alertWithVC:(UIViewController *)controller message:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertVc = [self wk_alertTitle:nil message:message];
        UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
        [alertVc addAction:okAction];
        [controller presentViewController:alertVc animated:YES completion:nil];
    });
}

- (void)wk_alertWithVC:(UIViewController *)controller message:(NSString *)message selectButton:(void(^)(BOOL selectValue))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertVc = [self wk_alertTitle:nil message:message];
        UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            completion(NO);
        }];
        [alertVc addAction:cancelAction];
        UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            completion(YES);
        }];
        [alertVc addAction:okAction];
        
        [controller presentViewController:alertVc animated:YES completion:nil];
    });
}


- (void)wk_alertWithVC:(UIViewController *)controller title:(NSString *)title message:(NSString *)message defaultText:(NSString *)defaultText selectButton:(void(^)(NSString * _Nullable inputText))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertVc = [self wk_alertTitle:title message:message];
        [alertVc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = defaultText;
        }];
        UIAlertAction * finishedAction = [UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            completion(alertVc.textFields[0].text?:@"");
        }];
        [alertVc addAction:finishedAction];
        [controller presentViewController:alertVc animated:YES completion:nil];
    });
}


- (UIAlertController *)wk_alertTitle:(NSString *)title message:(NSString *)message {
    return [UIAlertController alertControllerWithTitle:title message:(message ? message : @"") preferredStyle:UIAlertControllerStyleAlert];
}

@end
