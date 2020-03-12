//
//  SSRequestTokenPlugin.m
//  AFNetworking
//
//  Created by ixiazer on 2020/3/11.
//

#import "SSRequestTokenPlugin.h"
#import "SSRequestSettingConfig.h"

@implementation SSRequestTokenPlugin

// 负责用户token实现，需要把token写入HTTPHeaderField
- (NSURLRequest *)prepareRequestForBaseApi:(NSURLRequest *)reqeust baseApi:(SSBaseApi *)baseApi {
    NSMutableURLRequest *copyRequest = [reqeust mutableCopy];
    
    NSString *authValue = [self authValue];
    if (authValue) {
        [copyRequest setValue:authValue forHTTPHeaderField:@"Authorization"];
    }
    
    return copyRequest;
}

- (NSString *)authValue {
    // token Authorization 格式：“Bearer ***”
    if ([SSRequestSettingConfig defaultSettingConfig].token) {
        return [NSString stringWithFormat:@"Bearer %@", [SSRequestSettingConfig defaultSettingConfig].token];
    }
    return nil;
}
@end
