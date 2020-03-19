//
//  SSResponse.h
//  AFNetworking
//
//  Created by ixiazer on 2020/3/11.
//

#import <Foundation/Foundation.h>
#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#else
#import "AFNetworking.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface SSResponse : NSObject

@property (nonatomic, strong, readonly) NSData *data;
@property (nonatomic, assign, readonly) NSInteger statusCode;
@property (nonatomic, strong, readonly) NSDictionary *responseHeaders;
@property (nonatomic, strong, readonly) NSHTTPURLResponse *HTTPResponse;
@property (nonatomic, strong, readonly) id resultObject;
@property (nonatomic, strong, readonly) NSString *responseString;
@property (nonatomic, strong, readonly) NSDictionary *responseDic;

// NSURLResponse 转化为自定义SSResponse
- (instancetype)initWithURLResponse:(NSURLResponse *)urlResponse
                       responseData:(NSData *)responseData
                       resultObject:(id)resultObjec
                     responseString:(NSString *)responseString
                              error:(NSError * _Nullable __autoreleasing *)error;
@end

NS_ASSUME_NONNULL_END
