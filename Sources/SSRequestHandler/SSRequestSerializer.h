//
//  SSRequestSerializer.h
//  AFNetworking
//
//  Created by ixiazer on 2020/3/11.
//

#import <Foundation/Foundation.h>
#import "SSBaseApi.h"



@interface SSRequestSerializer : NSObject

+ (AFHTTPRequestSerializer *)requestSerizlizerForAPI:(SSBaseApi *)baseApi;

@end


