//
//  SSRequestProtocal.h
//  Pods
//
//  Created by ixiazer on 2020/3/11.
//

#import <Foundation/Foundation.h>
#import "SSResponse.h"
#import "SSBaseApi.h"

@protocol SSRequestProtocal <NSObject>

@optional
/*
 请求前预处理,SSBaseApi数据预处理
 */
- (void)willPrepareRequestForBaseApi:(SSBaseApi *_Nullable)baseApi;

/*
 请求前处理,NSURLRequest 进一步处理
 */
- (NSURLRequest *)prepareRequestForBaseApi:(NSURLRequest *)reqeust baseApi:(SSBaseApi *)baseApi;

/*
 请求发送前,提供给插件进行UI处理
*/
- (void)willSendRequestForBaseApi:(SSBaseApi *)baseApi;

/*
 返回结果处理，比如token 检查，统一error处理
 */
- (void)didReceiveResponseHandler:(id)responseOb baseApi:(SSBaseApi *)baseApi error:(NSError * _Nullable __autoreleasing *)error;

/*
 response 校验，比如数据格式，根据不同业务check
 */
- (BOOL)processionResponse:(SSResponse *)response baseApi:(SSBaseApi *)baseApi error:(NSError * _Nullable __autoreleasing *)error;

@end
