//
//  SSRequestHandler.h
//  AFNetworking
//
//  Created by ixiazer on 2020/3/11.
//

#import <Foundation/Foundation.h>
#import "SSRequestConfig.h"
#import "AFNetworking.h"
#import "SSBaseApi.h"
#import "SSRequestQueryStringSerialization.h"

NS_ASSUME_NONNULL_BEGIN


typedef NSString * (^SSRequestQueryStringSerializationBlock)(NSURLRequest *request, id parameters, NSError *__autoreleasing *error);

@interface SSRequestHandler : NSObject

// params
/*
 插件集合，可以分不同的NSURLSession，暂时使用同一个plugins实现
 */
@property (nonatomic, copy) NSArray *plugins;

// queryStringSerializer block
@property (nonatomic, copy) SSRequestQueryStringSerializationBlock queryStringSerializationBlock;

+ (SSRequestHandler *)defaultHandler;

/*
 创建请求
 baseApi, api的基本配置。包括url、params、method、requestSeries、responseSeries
 */
- (void)doRequestOnQueue:(SSBaseApi *)baseApi;

/*
 取消某个请求
 */
- (void)cancleRequest:(SSBaseApi *)baseApi;

/*
 取消全部请求
 */
- (void)cancleAllRequest;

@end

NS_ASSUME_NONNULL_END
