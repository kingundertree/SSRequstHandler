//
//  SSRequestService.h
//  AFNetworking
//
//  Created by ixiazer on 2020/3/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSRequestService : NSObject

@property (nonatomic, copy) NSString *baseUrl;

- (instancetype)initWithBaseUrl:(NSString *)baseUrlStr;

@end

NS_ASSUME_NONNULL_END
