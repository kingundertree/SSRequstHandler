//
//  SSRequestDebugLog.m
//  AFNetworking
//
//  Created by ixiazer on 2020/3/13.
//

#import "SSRequestDebugLog.h"
#import "SSRequestSettingConfig.h"

#ifdef DEBUG
#    define SSLog(fmt, ...) NSLog((@"%s #%d " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#    define SSLog(...)
#endif

@implementation SSRequestDebugLog

+ (void)showDebugInfo:(id)object {
    if ([SSRequestSettingConfig defaultSettingConfig].isShowDebugInfo == true) {
        SSLog(@"%@", object);
    }
}

@end
