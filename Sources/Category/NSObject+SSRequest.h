//
//  NSObject+SSRequest.h
//  AFNetworking
//
//  Created by ixiazer on 2020/3/11.
//


#import <Foundation/Foundation.h>
#import "SSBaseApi.h"


@interface NSObject (SSRequest)

+ (BOOL)validateResumeData:(NSData *)data;

- (instancetype _Nullable)isKindOfSelf:(id _Nullable)from;

@end

