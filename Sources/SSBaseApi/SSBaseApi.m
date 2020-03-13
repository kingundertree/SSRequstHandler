//
//  SSBaseApi.m
//  AFNetworking
//
//  Created by ixiazer on 2020/3/11.
//

#import "SSBaseApi.h"
#import "SSRequestHandler.h"
#import "SSRequestSettingConfig.h"

@interface SSBaseApi ()
@property (nonatomic, copy) NSString *appVersion;
@property (nonatomic, copy) NSString *region;
@property (nonatomic, copy) NSString *lang;
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, assign) NSTimeInterval timestamp;
@property (nonatomic, copy) NSString *deviceId;
@end

@implementation SSBaseApi

- (instancetype)initWithPath:(NSString *)path queries:(NSDictionary *)queries {
    self = [super init];
    if (self) {
        self.path = path;
        if (queries) {
            self.queries = queries;
        }
        
        // 公共参数初始化
        _appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        _region = @"cn";
        _lang = @"zh-cn";
        _appId = [SSRequestSettingConfig defaultSettingConfig].appId;
        _timestamp = (long long)([[NSDate date]timeIntervalSince1970]);
        _deviceId = [SSRequestSettingConfig defaultSettingConfig].deviceId;
    }

    return self;
}

- (SSRequestHandlerSessionType)sessionType {
    return SSRequestHandlerSessionTypeForDefault;
}

- (NSTimeInterval)requestTimeoutInterval {
    // 默认20s
    return 20;
}

- (NSURLRequestCachePolicy)cachePolicy {
    // 默认无缓存
    return NSURLRequestReloadIgnoringCacheData;
}

- (BOOL)allowsCellularAccess {
    return YES;
}

- (NSArray *)requestAuthorizationHeaderFieldArray {
    return nil;
}

- (NSDictionary *)requestHeaderFieldValueDictionary {
    return nil;
}

- (NSString *)requestPath {
    return [NSString stringWithFormat:@"%@?%@", self.path, AFQueryStringFromParameters([self queryParamForPublic])];
}

- (SSRequestMethod)mehod {
    return SSRequestMethodGET;
}

- (SSRequestConstructingBlock)constructingBlock {
    return nil;
}

- (id)requestArgument {
    if (self.queries.allKeys.count > 0) {
        self.queries;
    }
    return nil;
}

- (SSRequestService *)service {
    return [[SSRequestService alloc] initWithBaseUrl:@"https://frefresh.com"];
}

- (SSRequestSerialzerType)requestSerializerType {
    return SSRequestSerialzerTypeHTTP;
}

- (SSResponseSerialzerType)responseSerializerType {
    return SSResponseSerialzerTypeJSON;
}

- (NSIndexSet *)acceptStatusCode {
    return [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 300)];
}

- (NSError *)validateResponse:(id)response {
    return nil;
}

- (NSDictionary *)resultCodeMap {
    return nil;
}

- (NSDictionary *)queryParamForPublic {
    return @{
             @"appId": self.appId,
             @"region": self.region,
             @"lang": self.lang,
             @"appVersion": self.appVersion,
             @"timestamp" : @(self.timestamp),
             @"deviceId": self.deviceId
             };
}

#pragma mark - method
- (void)requestWithCompletionBlock:(SSRequestHandlerCallback)requestHandlerCallback {
    self.requestHandlerCallback = requestHandlerCallback;
    [[SSRequestHandler defaultHandler] doRequestOnQueue:self];
}

- (void)cancelRequest {
    [[SSRequestHandler defaultHandler] cancleRequest:self];
}

#pragma mark - get method
- (NSMutableDictionary *)queries {
    if (!_queries) {
        _queries = [NSMutableDictionary new];
    }
    return _queries;
}

@end
