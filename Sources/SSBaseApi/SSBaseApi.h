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
#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#else
#import "AFNetworking.h"
#endif

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, SSRequestHandlerSessionType) {
    SSRequestHandlerSessionTypeDefault, // 默认
    SSRequestHandlerSessionTypeAuthentication, // 需要自建TSP认证
} ;


typedef NS_ENUM(NSInteger, SSRequestSerializerType) {
    SSRequestSerializerTypeHTTP = 0,
    SSRequestSerializerTypeText = 1,
    SSRequestSerializerTypeJSON = 2,
    SSRequestSerializerTypeXML = 3
};

typedef NS_ENUM(NSInteger, SSResponseSerializerType) {
    SSResponseSerializerTypeHTTP = 0,
    SSResponseSerializerTypeText = 1,
    SSResponseSerializerTypeJSON = 2,
    SSResponseSerializerTypeXML = 3
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
typedef void (^SSRequestHandlerCallback)(SSResponse * _Nullable response, NSError * _Nullable error);

/*
 下载进度回调
 */
typedef void (^SSRequestHandlerProgressBlock)(NSProgress * _Nullable progress);

/*
 上传数据组合
*/
typedef void (^SSRequestConstructingBlock)(id<AFMultipartFormData> _Nullable formData);


@interface SSBaseApi : NSObject

// 绑定BaseApi 创建的task，执行resume、canlce等操作
@property (nonatomic, strong) NSURLSessionTask * _Nullable requestTask;
// request callback
@property (nonatomic, copy) SSRequestHandlerCallback _Nullable requestHandlerCallback;
// download process callback
@property (nonatomic, copy) SSRequestHandlerProgressBlock _Nullable progressCallback;
// request path
@property (nonatomic, copy) NSString *path;
// 自定义入参实现, swift 可以通过subscript实现。不直接合并到URL，待后续POST、GET继续处理
@property (nonatomic, strong) NSMutableDictionary * _Nullable queries;

// BaseApi 初始化
- (instancetype _Nullable )initWithPath:(NSString *_Nullable)path queries:(NSDictionary *_Nullable)queries;

// 通过SSBaseApi发生请求
- (void)requestWithCompletionBlock:(SSRequestHandlerCallback _Nullable )requestHandlerCallback;

// 取消请求
- (void)cancelRequest;

// 下载数据的缓存地址
- (NSString *_Nullable)downloadPath;

// sesstion配置type
- (SSRequestHandlerSessionType)sessionType;

// 超时设置
- (NSTimeInterval)requestTimeoutInterval;

// 缓存策略
- (NSURLRequestCachePolicy)cachePolicy;

// 蜂窝网络使用策略
- (BOOL)allowsCellularAccess;

// 认证信息
- (NSArray *_Nullable)requestAuthorizationHeaderFieldArray;

// 自定义header参数
- (NSDictionary *_Nullable)requestHeaderFieldValueDictionary;

// 请求服务，定义默认host
- (SSRequestService *_Nullable)service;

// 请求method，可以为完整的url
- (NSString *_Nullable)requestPath;

// method type
- (SSRequestMethod)mehod;

// request params
- (id _Nullable )requestArgument;

// download data process
- (SSRequestConstructingBlock _Nullable )constructingBlock;

// requestSerializer
- (SSRequestSerializerType)requestSerializerType;

// responseSerializer
- (SSResponseSerializerType)responseSerializerType;

// 默认errorcode
- (NSIndexSet *_Nullable)acceptStatusCode;

// response校验
- (NSError *_Nullable)validateResponse:(id _Nullable )response;

// 自定义errorCode和errorMessage
- (NSDictionary *_Nullable)resultCodeMap;

// 公共参数
- (NSDictionary *_Nullable)queryParamForPublic;
@end

NS_ASSUME_NONNULL_END
