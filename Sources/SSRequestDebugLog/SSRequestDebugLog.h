//
//  SSRequestDebugLog.h
//  AFNetworking
//
//  Created by ixiazer on 2020/3/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#ifdef DEBUG
#    define SSLog(fmt, ...) NSLog((@"%s #%d " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#    define SSLog(...)
#endif


@interface SSRequestDebugLog : NSObject

+ (instancetype)sharedInstance;

- (void)debugInfo:(id)object;

@end

NS_ASSUME_NONNULL_END
