//
//  SSRequestSerializer.h
//  AFNetworking
//
//  Created by ixiazer on 2020/3/11.
//

#import <Foundation/Foundation.h>
#import "SSBaseApi.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSRequestSerializer : NSObject

+ (AFHTTPRequestSerializer *)requestSerizlizerForAPI:(SSBaseApi *)baseApi;

@end

NS_ASSUME_NONNULL_END
