//
//  SSBaseApi.m
//  AFNetworking
//
//  Created by ixiazer on 2020/3/11.
//

#import "SSBaseApi.h"
#import "SSRequestHandler.h"

@implementation SSBaseApi


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
    return nil;
}

- (SSRequestMethod)mehod {
    return SSRequestMethodGET;
}

- (SSRequestConstructingBlock)constructingBlock {
    return nil;
}

- (id)requestArgument {
    return nil;
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

#pragma mark - method
- (void)requestWithCompletionBlock:(SSRequestHandlerCallback)requestHandlerCallback {
    self.requestHandlerCallback = requestHandlerCallback;
    [[SSRequestHandler defaultHandler] doRequestOnQueue:self];
}

- (void)cancelRequest {
    [[SSRequestHandler defaultHandler] cancleRequest:self];
}

@end
