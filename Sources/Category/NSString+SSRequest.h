//
//  NSString+SSRequest.h
//  AFNetworking
//
//  Created by ixiazer on 2020/3/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (SSRequest)

// 下载文件默认文件路径
+ (NSString *)defaultDownloadTempCacheFolder;

// string md5计算
+ (NSString *)md5StringFromCString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
