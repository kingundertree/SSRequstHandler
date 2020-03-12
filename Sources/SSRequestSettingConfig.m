//
//  SSRequestSettingConfig.m
//  AFNetworking
//
//  Created by ixiazer on 2020/3/12.
//

#import "SSRequestSettingConfig.h"

@implementation SSRequestSettingConfig

+ (SSRequestSettingConfig *)defaultSettingConfig {
    static SSRequestSettingConfig *defaultSettingConfig = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultSettingConfig = [[SSRequestSettingConfig alloc] init];
    });
    
    return defaultSettingConfig;
}

@end
