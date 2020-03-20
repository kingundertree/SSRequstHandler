//
//  SSRequestDebugLog.m
//  AFNetworking
//
//  Created by ixiazer on 2020/3/13.
//

#import "SSRequestDebugLog.h"
#import "SSRequestSettingConfig.h"
#import "NSString+SSRequest.h"

@implementation SSRequestDebugLog

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static SSRequestDebugLog *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SSRequestDebugLog alloc] init];
    });
    return sharedInstance;
}

- (void)debugInfo:(id)object {
    if ([SSRequestSettingConfig defaultSettingConfig].isShowDebugInfo == true) {
        SSLog(@"%@", object);
    }
}

// 打印请求前信息
- (void)showReponseStartInfo:(SSBaseApi *)baseApi
                     request:(NSURLRequest *)request {
    if ([SSRequestSettingConfig defaultSettingConfig].isShowDebugInfo == true) {
        NSMutableString *logString = [NSMutableString stringWithString:@"\n\n**************************************************************\n*                    SSRequest Request Start                 *\n**************************************************************\n\n"];
        [logString appendFormat:@"Service:\t\t%@\n", baseApi.service.baseUrl ?: @""];
        [logString appendFormat:@"API Name:\t\t%@\n", baseApi.path ?: @""];
        [logString appendFormat:@"Method:\t\t\t%@\n", [NSString methodMap:baseApi.mehod]];
        [logString appendFormat:@"HeaderField:\n%@\n", request.allHTTPHeaderFields ?: @{}];
        [logString appendFormat:@"Params:\n%@\n", [baseApi requestArgument] ?: @{}];
        [logString appendFormat:@"FullRequest:\n%@\n\n", request.URL.absoluteString];
        NSString *bodyString = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
        if (bodyString) {
            [logString appendFormat:@"Body Data:\n%@\n", bodyString];
        }
        [logString appendFormat:@"\n\n**************************************************************\n*                    SSRequest Request End                    *\n**************************************************************\n\n\n\n"];
        SSLog(@"%@", logString);
    }
}
// 打印请求结束信息
- (void)showReponseEndInfo:(SSBaseApi *)baseApi
                  response:(SSResponse *)response
                   request:(NSURLRequest *)request {
    if ([SSRequestSettingConfig defaultSettingConfig].isShowDebugInfo == true) {
        NSMutableString *logString = [NSMutableString stringWithString:@"\n\n**************************************************************\n*                  SSRequest Response Start                  *\n**************************************************************\n\n"];
        [logString appendFormat:@"Service:\t\t%@\n", baseApi.service.baseUrl ?: @""];
        [logString appendFormat:@"API Name:\t\t%@\n", baseApi.path ?: @""];
        [logString appendFormat:@"Method:\t\t\t%@\n", [NSString methodMap:baseApi.mehod]];
        [logString appendFormat:@"HeaderField:\n%@\n", response.HTTPResponse.allHeaderFields ?: @{}];
        [logString appendFormat:@"Params:\n%@\n", [baseApi requestArgument] ?: @{}];
        [logString appendFormat:@"FullRequest:\n%@\n\n", response.HTTPResponse.URL.absoluteString];
        NSData *data = request.HTTPBody;
        NSString *bodyString = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
        if (bodyString) {
            [logString appendFormat:@"Body Data:\n%@\n", bodyString];
        }
//        [logString appendFormat:@"Response Data:\n%@\n", response.responseString ?: @""];
        [logString appendFormat:@"Response Data:\n%@\n", response.responseDic ?: @""];
        [logString appendFormat:@"\n\n**************************************************************\n*                 SSRequest Response End                     *\n**************************************************************\n\n\n\n"];
        SSLog(@"%@", logString);
    }
}


@end
