//
//  NSError+SSRequest.h
//  AFNetworking
//
//  Created by ixiazer on 2020/3/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSError (SSRequest)

+ (NSError *)errorWithDescription:(NSString *)description;

@end

NS_ASSUME_NONNULL_END
