//
//  SSBaseApi.h
//  AFNetworking
//
//  Created by ixiazer on 2020/3/11.
//

#import <Foundation/Foundation.h>
#import "SSRequestConfig.h"
#import "SSResponse.h"
#import "SSRequestService.h"
#import "AFNetworking.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    SSRequestHandlerSessionTypeForDefault, // 默认
    SSRequestHandlerSessionTypeForAuthentication, // 需要自建TSP认证
} SSRequestHandlerSessionType;


typedef NS_ENUM(NSInteger, SSRequestSerialzerType) {
    SSRequestSerialzerTypeHTTP = 0,
    SSRequestSerialzerTypeText = 1,
    SSRequestSerialzerTypeJSON = 2,
    SSRequestSerialzerTypeXML = 3
};

typedef NS_ENUM(NSInteger, SSResponseSerialzerType) {
    SSResponseSerialzerTypeHTTP = 0,
    SSResponseSerialzerTypeText = 1,
    SSResponseSerialzerTypeJSON = 2,
    SSResponseSerialzerTypeXML = 3
};

typedef NS_ENUM(NSUInteger, SSRequestMethod) {
    SSRequestMethodGET,
    SSRequestMethodPOST,
    SSRequestMethodHEAD,
    SSRequestMethodPUT,
    SSRequestMethodDELETE,
    SSRequestMethodPATCH
};
/*
 请求结束回调
 */
typedef void (^SSRequestHandlerCallback)(SSResponse *response, NSError *error);

/*
 下载进度回调
 */
typedef void (^SSRequestHandlerProgressBlock)(NSProgress *progress);

/*
 上传数据组合
*/
typedef void (^SSRequestConstructingBlock)(id<AFMultipartFormData> formData);


@interface SSBaseApi : NSObject

// 绑定BaseApi 创建的task，执行resume、canlce等操作
@property (nonatomic, strong) NSURLSessionTask *requestTask;
// request callback
@property (nonatomic, copy) SSRequestHandlerCallback requestHandlerCallback;
// download process callback
@property (nonatomic, copy) SSRequestHandlerProgressBlock progressCallback;

// 通过SSBaseApi发生请求
- (void)requestWithCompletionBlock:(SSRequestHandlerCallback)requestHandlerCallback;
// 取消请求
- (void)cancelRequest;

// 下载数据的缓存地址
- (NSString *)downloadPath;

// sesstion配置type
- (SSRequestHandlerSessionType)sessionType;

// 超时设置
- (NSTimeInterval)requestTimeoutInterval;

// 缓存策略
- (NSURLRequestCachePolicy)cachePolicy;

// 蜂窝网络使用策略
- (BOOL)allowsCellularAccess;

// 认证信息
- (NSArray *)requestAuthorizationHeaderFieldArray;

// header信息，建议通过plugin实现，实现统一简洁
- (NSDictionary *)requestHeaderFieldValueDictionary;

// 请求服务，定义默认host
- (SSRequestService *)service;

// 请求method，可以为完整的url
- (NSString *)requestPath;

// method type
- (SSRequestMethod)mehod;

// request params
- (id)requestArgument;

// download data process
- (SSRequestConstructingBlock)constructingBlock;

// requestSerializer
- (SSRequestSerialzerType)requestSerializerType;

// responseSerializer
- (SSResponseSerialzerType)responseSerializerType;

// 默认errorcode
- (NSIndexSet *)acceptStatusCode;

// response校验
- (NSError *)validateResponse:(id)response;

// 自定义errorCode和errorMessage
- (NSDictionary *)resultCodeMap;
@end

NS_ASSUME_NONNULL_END
