//
//  SSBaseApi.m
//  AFNetworking
//
//  Created by ixiazer on 2020/3/11.
//

#import "SSBaseApi.h"
#import "SSRequestHandler.h"
#import "SSRequestSettingConfig.h"
#import "SSRequestService.h"

@interface SSBaseApi ()
@property (nonatomic, copy) NSString *appVersion;
@property (nonatomic, copy) NSString *region;
@property (nonatomic, copy) NSString *lang;
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *deviceId;
@property (nonatomic, assign) NSTimeInterval timestamp;
@end

@implementation SSBaseApi

- (instancetype)initWithPath:(NSString *)path queries:(NSDictionary *)queries {
    self = [super init];
    if (self) {
        self.path = path;
        if (queries) {
            self.queries = queries;
        }
        [self doConfigInit];
    }

    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self doConfigInit];
    }

    return self;
}

- (void)doConfigInit {
    // 公共参数初始化
    self.appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    self.region = @"cn";
    self.lang = @"zh-cn";
    self.appId = [SSRequestSettingConfig defaultSettingConfig].appId;
    self.timestamp = (long long)([[NSDate date]timeIntervalSince1970]);
    self.deviceId = [SSRequestSettingConfig defaultSettingConfig].deviceId;
}

- (SSRequestHandlerSessionType)sessionType {
    return SSRequestHandlerSessionTypeDefault;
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

- (NSString *)downloadPath {
    return nil;
}

- (id)requestArgument {
    if (self.queries.allKeys.count > 0) {
        return self.queries;
    }
    return nil;
}

- (SSRequestService *)service {
    return [SSRequestSettingConfig defaultSettingConfig].service ?: [[SSRequestService alloc] initWithBaseUrl:@"https://**.******.com"];
}

- (SSRequestSerializerType)requestSerializerType {
    return SSRequestSerializerTypeHTTP;
}

- (SSResponseSerializerType)responseSerializerType {
    return SSResponseSerializerTypeJSON;
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
             @"timeStamp" : [self getNowFormateDate],
             @"deviceId": self.deviceId,
             @"device": @"iOS"
             };
}

- (NSString *)getNowFormateDate {
    NSDate *nowDate = [NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *nowDateStr = [dateformatter stringFromDate:nowDate];
    
    return nowDateStr;
}

#pragma mark - method
- (void)requestWithCompletionBlock:(SSRequestHandlerCallback)requestHandlerCallback {
    self.requestHandlerCallback = requestHandlerCallback;
    [[SSRequestHandlerManager defaultHandler] doRequestOnQueue:self];
}

- (void)cancelRequest {
    [[SSRequestHandlerManager defaultHandler] cancleRequest:self];
}

#pragma mark - get method
- (NSMutableDictionary *)queries {
    if (!_queries) {
        _queries = [NSMutableDictionary new];
    }
    return _queries;
}

@end
