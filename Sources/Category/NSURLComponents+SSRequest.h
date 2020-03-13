//
//  NSURLComponents+SSRequest.h
//  AFNetworking
//
//  Created by ixiazer on 2020/3/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLComponents (SSRequest)

- (NSURLComponents *)appendingQuery:(NSURLQueryItem *)query;

@end

NS_ASSUME_NONNULL_END
