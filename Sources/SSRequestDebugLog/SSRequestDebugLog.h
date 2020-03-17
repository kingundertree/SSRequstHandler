//
//  SSRequestDebugLog.h
//  AFNetworking
//
//  Created by ixiazer on 2020/3/13.
//

#import <Foundation/Foundation.h>
#import "SSBaseApi.h"
#import "SSResponse.h"

NS_ASSUME_NONNULL_BEGIN

#ifdef DEBUG
#    define SSLog(fmt, ...) NSLog((@"%s #%d " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#    define SSLog(...)
#endif


@interface SSRequestDebugLog : NSObject

+ (instancetype)sharedInstance;

- (void)debugInfo:(id)object;

// 打印请求前信息
- (void)showReponseStartInfo:(SSBaseApi *)baseApi request:(NSURLRequest *)request;
// 打印请求结束信息
- (void)showReponseEndInfo:(SSBaseApi *)baseApi response:(SSResponse *)response request:(NSURLRequest *)request;

@end

NS_ASSUME_NONNULL_END
