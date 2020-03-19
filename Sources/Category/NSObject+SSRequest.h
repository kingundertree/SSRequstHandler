//
//  NSObject+SSRequest.h
//  AFNetworking
//
//  Created by ixiazer on 2020/3/11.
//


#import <Foundation/Foundation.h>
#import "SSBaseApi.h"

NS_ASSUME_NONNULL_BEGIN
@interface NSObject (SSRequest)

+ (BOOL)validateResumeData:(NSData *)data;

- (instancetype _Nullable)isKindOfSelf:(id _Nullable)from;

@end

NS_ASSUME_NONNULL_END
