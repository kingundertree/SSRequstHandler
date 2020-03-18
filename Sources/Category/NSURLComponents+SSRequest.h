//
//  NSURLComponents+SSRequest.h
//  AFNetworking
//
//  Created by ixiazer on 2020/3/13.
//

#import <Foundation/Foundation.h>


@interface NSURLComponents (SSRequest)

- (NSURLComponents *)appendingQuery:(NSURLQueryItem *)query;

@end

