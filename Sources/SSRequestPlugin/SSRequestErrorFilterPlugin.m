//
//  SSRequestErrorFilterPlugin.m
//  AFNetworking
//
//  Created by ixiazer on 2020/3/12.
//

#import "SSRequestErrorFilterPlugin.h"
#import "SSRequestConfig.h"
#import "SSRequestSettingConfig.h"
#import "UIViewController+SSRequest.h"

// 全局errorCode+message
static NSDictionary *result_code_mapping() {
    return @{
             @"success": @"成功",
             @"resource_not_found": @"请求资源不存在",
             @"auth_failed": @"你的登录信息已过期,请重新登录",
             @"request_forbidden": @"请求被禁止",
             @"invalid_param": @"请求参数非法",
             @"internal_error": @"服务器内部错误",
             @"blacklisted_input": @"内容非法, 有违禁词~",
             };
};

@implementation SSRequestErrorFilterPlugin

- (BOOL)processionResponse:(SSResponse *)response baseApi:(SSBaseApi *)baseApi error:(NSError * _Nullable __autoreleasing *)error {
    // 主要check是否有error，error是可以传递的，可以check token失效的case。todo
    if (*error) {
        NSError *innerError = *error;
        if (innerError.code == -1024 && [innerError.domain isEqualToString:SSRequestErrorDomain]) {
            return NO;
        }
        
        innerError =  [NSError errorWithDomain:@"Error Filter Handle"
                                          code:-1024
                                      userInfo:@{
                                                 NSLocalizedDescriptionKey: @"网络错误",
                                                 }];
        *error = innerError;
        return YES;
    }
    
    
    NSDictionary *responseDict = response.responseDic;
    if (!responseDict) {
        return NO;
    }
    // 需要按照约定的服务端关键值定义
    NSString *resultCode = [responseDict objectForKey:@"result_code"];
    NSString *errorDes;
    if (resultCode && ![resultCode isEqualToString:@"success"]) {
        // 先处理token失效的特殊逻辑
        NSString *currentAccessToken = [baseApi.requestTask.originalRequest.allHTTPHeaderFields objectForKey:@"Authorization"];
        // token 失效的Error Code
        if ([resultCode isEqualToString:@"auth_failed"] || [resultCode isEqualToString:@"another_device_logged_in"]) {
            *error = [NSError errorWithDomain:SSRequestErrorDomain
                                                    code:-1024
                                                userInfo:@{}];
            NSString *prefix = @"Bearer ";
            if ([currentAccessToken hasPrefix:prefix]) {
                NSString *token = [currentAccessToken substringFromIndex:prefix.length];
                if (token.length > 0) {
                    *error = [NSError errorWithDomain:SSRequestErrorDomain
                                                 code:-1024
                                             userInfo:@{}];

                    NSString *alertTitle;
                    if ([resultCode isEqualToString:@"auth_failed"]) {
                        alertTitle = result_code_mapping()[@"auth_failed"];
                    } else {
                        alertTitle = errorDes ? errorDes : result_code_mapping()[@"auth_failed"];
                    }

                    UIAlertController *authFailedAlert = [[UIAlertController alloc] init];
                    authFailedAlert.title = alertTitle;
                    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定"
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction *action) {
                        // post userNotification
                                                               }];
                    [authFailedAlert addAction:ok];
                    [[UIViewController currentViewController] presentViewController:authFailedAlert animated:YES completion:nil];
                
                    return true;
                }
            }
        }
        
        NSDictionary *apiCodeMap = [baseApi resultCodeMap];
        if (apiCodeMap) {
            // BaseApi有定义，则用自定义实现，否则使用全局定义
            errorDes = [apiCodeMap objectForKey:resultCode];
        }

        if(!errorDes && responseDict[@"message"]) {
            // 使用api返回message
            errorDes =  responseDict[@"message"];
        }
        
        if (!errorDes) {
            // 使用全局定义
            errorDes = result_code_mapping()[resultCode];
        }
        
        // 自定义NSError.userInfo
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
        [userInfo setObject:errorDes ?: resultCode forKey:NSLocalizedDescriptionKey];
        [userInfo setObject:resultCode forKey:SSRequestResultCode];
        
        NSDictionary *dataInfo = [responseDict objectForKey:@"data"];
        if (dataInfo) {
            [userInfo setObject:dataInfo forKey:@"data"];
        }

        NSError *resError = [NSError errorWithDomain:SSRequestErrorDomain
                                                code:-1024
                                            userInfo:userInfo];
        *error = resError;
    }
    
    return true;
}

@end
