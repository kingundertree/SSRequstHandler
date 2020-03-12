//
//  SSResponse.m
//  AFNetworking
//
//  Created by ixiazer on 2020/3/11.
//

#import "SSResponse.h"
#import "NSObject+SSRequest.h"

@implementation SSResponse

- (instancetype)initWithURLResponse:(NSURLResponse *)urlResponse
                       responseData:(NSData *)responseData
                       resultObject:(id)resultObject
                     responseString:(NSString *)responseString
                              error:(NSError * _Nullable __autoreleasing *)error {
    if (self = [super init]) {
        _data = responseData;
        _resultObject = resultObject;
        _responseString = responseString;
        _responseDic = [self unwrapDataToDict:&error];
        if ([urlResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            _HTTPResponse = (NSHTTPURLResponse *)urlResponse;
        } else {
            // todo
        }
    }

    return self;
}

- (NSInteger)statusCode {
    return self.HTTPResponse ? self.HTTPResponse.statusCode : NSNotFound;
}

- (NSDictionary *)responseHeaders {
    return self.HTTPResponse ? self.HTTPResponse.allHeaderFields : nil;
}

- (NSUInteger)hash {
    return self.HTTPResponse.hash;
}

// response转字段
- (nullable NSDictionary *)unwrapDataToDict:(NSError * _Nullable __autoreleasing *)error {
    NSDictionary *resposeObjcet = [NSDictionary isKindOfSelf:self.resultObject];
    if (!resposeObjcet) {
        NSString *requestPath = [self.HTTPResponse.URL absoluteString];
        *error = [NSError
                  errorWithDomain:@"ResponseError"
                  code:-1024
                  userInfo:@{ NSLocalizedDescriptionKey: @"返回数据格式错误",
                              NSDebugDescriptionErrorKey: self.responseString ? : @"",
                              @"RequestPath": requestPath ? : @""}];
        return nil;
    }
    
    NSDictionary *data = [NSDictionary isKindOfSelf:[resposeObjcet objectForKey:@"data"]];
    return data;
}

- (nullable NSArray *)unwrapDataToArray:(NSError * _Nullable __autoreleasing *)error {
    NSDictionary *resposeObjcet = [NSDictionary isKindOfSelf:self.resultObject];
    if (!resposeObjcet) {
        NSString *requestPath = [self.HTTPResponse.URL absoluteString];
        *error = [NSError
                  errorWithDomain:@"ResponseError"
                  code:-1024
                  userInfo:@{ NSLocalizedDescriptionKey: @"返回数据格式错误",
                              NSDebugDescriptionErrorKey: self.responseString ? : @"",
                              @"RequestPath": requestPath ? : @""}];
        
        return nil;
    }
    
    NSArray *data = [NSArray isKindOfSelf:[resposeObjcet objectForKey:@"data"]];
    return data;
}

@end
