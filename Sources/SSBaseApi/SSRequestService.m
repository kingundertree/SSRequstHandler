//
//  SSRequestService.m
//  AFNetworking
//
//  Created by ixiazer on 2020/3/12.
//

#import "SSRequestService.h"

@implementation SSRequestService

- (instancetype)initWithBaseUrl:(NSString *)baseUrlStr {
    self = [super init];
    if (!self) {
        return nil;
    }
    _baseUrl = baseUrlStr;
    return self;
}


@end
