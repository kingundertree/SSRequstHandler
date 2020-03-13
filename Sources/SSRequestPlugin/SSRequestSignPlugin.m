//
//  SSRequestSignPlugin.m
//  AFNetworking
//
//  Created by ixiazer on 2020/3/11.
//

#import "SSRequestSignPlugin.h"
#import "SSRequestConfig.h"
#import "SSRequestSettingConfig.h"
#import "NSString+SSRequest.h"
#import "NSURLComponents+SSRequest.h"
#import "SSRequestDebugLog.h"

@implementation SSRequestSignPlugin

- (NSURLRequest *)prepareRequestForBaseApi:(NSURLRequest *)reqeust baseApi:(SSBaseApi *)baseApi {
    NSString *method = reqeust.HTTPMethod;
    NSURL *url = reqeust.URL;
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:false];
    
    // 获取request body的string
    NSString *queryAndBodyString = [self _queryAndBodyString:components method:method reqeust:reqeust] ?: @"";
    
    // 加签名
    NSString *path = components.percentEncodedPath;
    NSString *token = [reqeust valueForHTTPHeaderField:@"Authorization"] ?: @"";
    NSString *secret = [SSRequestSettingConfig defaultSettingConfig].secret ?: @"";
    NSString *wilSignString = [NSString stringWithFormat:@"%@%@?%@%@%@", method, path, queryAndBodyString, secret, token];
    
    NSString *sign = [NSString md5StringFromCString:wilSignString];
    if (sign) {
        [components appendingQuery:[[NSURLQueryItem alloc] initWithName:@"sign" value:sign]];
    
        NSMutableURLRequest *requestCopy = [reqeust mutableCopy];
        requestCopy.URL = components.URL;

        return reqeust;
    }
    
    return nil;
}

- (NSString *)_queryAndBodyString:(NSURLComponents *)components
                          method:(NSString *)method
                      reqeust:(NSURLRequest *)reqeust {
    NSMutableArray *revals = [self _unencodedItems:components];
    if ([method isEqualToString:@"PUT"] || [method isEqualToString:@"POST"]) {
        NSString *contentEncoding = [reqeust valueForHTTPHeaderField:@"Content-Encoding"] ?: @"";
        if ([contentEncoding containsString:@"gzip"]) {
            return nil;
        }
        
        NSString *contentType = [reqeust valueForHTTPHeaderField:@"Content-Type"];
        if (!contentType) {
            return nil;
        }
        
        NSData *data = reqeust.HTTPBody;
        if (data) {
            NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (string) {
                if ([contentType containsString:@"application/x-www-form-urlencoded"]) {
                    [revals addObjectsFromArray:[self _unencodedItems:string]];
                } else if ([contentType containsString:@"application/json"]) {
                    [revals addObject:[NSString stringWithFormat:@"jsonBody=%@", string]];
                }
                
                // 排序
                revals = [revals sortedArrayUsingSelector:@selector(compare:)];
                
                [[SSRequestDebugLog sharedInstance] debugInfo:revals];
                
                return [revals componentsJoinedByString:@"&"];
            }
        }
    }
}

- (NSMutableArray *)_unencodedItems:(NSString *)query {
    NSArray *querys = [query componentsSeparatedByString:@"&"];
    NSMutableArray *mutQuery = [NSMutableArray new];
    for (NSString *str in querys) {
        [mutQuery addObject:[str stringByRemovingPercentEncoding]];
    }
    
    return mutQuery;
}



@end
