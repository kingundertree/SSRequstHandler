//
//  NSError+SSRequest.m
//  AFNetworking
//
//  Created by ixiazer on 2020/3/12.
//

#import "NSError+SSRequest.h"
#import "SSRequestConfig.h"

@implementation NSError (SSRequest)

+ (NSError *)errorWithDescription:(NSString *)description {
    return [NSError errorWithDomain:SSRequestErrorDomain
                               code:-1024
                           userInfo:@{NSLocalizedDescriptionKey: description ?: @"No Desc"}];
}

@end
