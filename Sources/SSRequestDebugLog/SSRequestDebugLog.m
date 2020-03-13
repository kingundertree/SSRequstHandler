//
//  SSRequestDebugLog.m
//  AFNetworking
//
//  Created by ixiazer on 2020/3/13.
//

#import "SSRequestDebugLog.h"
#import "SSRequestSettingConfig.h"

@implementation SSRequestDebugLog

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static SSRequestDebugLog *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SSRequestDebugLog alloc] init];
    });
    return sharedInstance;
}

- (void)debugInfo:(id)object {
    if ([SSRequestSettingConfig defaultSettingConfig].isShowDebugInfo == true) {
        SSLog(@"%@", object);
    }
}

@end
