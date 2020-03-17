//
//  NSString+SSRequest.h
//  AFNetworking
//
//  Created by ixiazer on 2020/3/11.
//

#import <Foundation/Foundation.h>
#import "SSBaseApi.h"

@interface NSString (SSRequest)

// 下载文件默认文件路径
+ (NSString *)defaultDownloadTempCacheFolder;

// string md5计算
- (NSString *)md5StringFromCString;

// 获取baseApi
+ (NSString *)requestUrlStringForBaseApi:(SSBaseApi *)baseApi;

// 获取method string
+ (NSString *)methodMap:(SSRequestMethod)method;

@end
