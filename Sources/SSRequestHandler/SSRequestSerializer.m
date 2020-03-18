//
//  SSRequestSerializer.m
//  AFNetworking
//
//  Created by ixiazer on 2020/3/11.
//

#import "SSRequestSerializer.h"
#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#else
#import "AFNetworking.h"
#endif

@implementation SSRequestSerializer

+ (AFHTTPRequestSerializer *)requestSerizlizerForAPI:(SSBaseApi *)baseApi {
    AFHTTPRequestSerializer *requestSerializer = nil;
    
    // 暂时只处理HTTP和JSON request 序列化
    if (baseApi.requestSerializerType == SSRequestSerializerTypeHTTP) {
        requestSerializer = [AFHTTPRequestSerializer serializer];
    } else if (baseApi.requestSerializerType == SSRequestSerializerTypeJSON) {
        requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
    // 读取SSBaseApi的个性化配置，实现定制
    requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET", @"HEAD", @"DELETE", @"PUT", nil];
    requestSerializer.timeoutInterval = [baseApi requestTimeoutInterval];
    requestSerializer.cachePolicy = [baseApi cachePolicy];
    requestSerializer.allowsCellularAccess = [baseApi allowsCellularAccess];
    
    // 写入HTTPHeaderField信息，SSRequest将通过SSRequestHeaderPlugin实现，此处只保留此实现供参考
    NSArray <NSString *> *authorizationHeaderFieldArray = [baseApi requestAuthorizationHeaderFieldArray];
    if (authorizationHeaderFieldArray != nil){
        [requestSerializer setAuthorizationHeaderFieldWithUsername:authorizationHeaderFieldArray.firstObject
                                                          password:authorizationHeaderFieldArray.lastObject];
    }
    
    NSDictionary<NSString *, NSString *> *headerFieldValueDictionary = [baseApi requestHeaderFieldValueDictionary];
    if (headerFieldValueDictionary != nil) {
        for (NSString *httpHeaderField in headerFieldValueDictionary.allKeys) {
            NSString *value = headerFieldValueDictionary[httpHeaderField];
            [requestSerializer setValue:value forHTTPHeaderField:httpHeaderField];
        }
    }
    
    return requestSerializer;
}

@end
