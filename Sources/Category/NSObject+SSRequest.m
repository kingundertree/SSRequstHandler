//
//  NSObject+SSRequest.m
//  AFNetworking
//
//  Created by ixiazer on 2020/3/11.
//

#import "NSObject+SSRequest.h"


@implementation NSObject (SSRequest)

// 检查resume data是否有效
+ (BOOL)validateResumeData:(NSData *)data {
    // From http://stackoverflow.com/a/22137510/3562486
    // From https://forums.developer.apple.com/thread/24770
    if (!data || [data length] < 1) return NO;
    
    NSError *error;
    NSDictionary *resumeDictionary = [NSPropertyListSerialization propertyListWithData:data
                                                                               options:NSPropertyListImmutable
                                                                                format:NULL
                                                                                 error:&error];
    if (!resumeDictionary || error) return NO;
    
    // Before iOS 9 & Mac OS X 10.11
#if (defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED < 90000)\
|| (defined(__MAC_OS_X_VERSION_MAX_ALLOWED) && __MAC_OS_X_VERSION_MAX_ALLOWED < 101100)
    NSString *localFilePath = [resumeDictionary objectForKey:@"NSURLSessionResumeInfoLocalPath"];
    if ([localFilePath length] < 1) return NO;
    
    BOOL result = [[NSFileManager defaultManager] fileExistsAtPath:localTmpFilePath];
    
    if (!result) {
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        NSString *localName = [localTmpFilePath lastPathComponent];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachesDir = [paths objectAtIndex:0];
        NSString *localCachePath = [[[cachesDir stringByAppendingPathComponent:@"com.apple.nsurlsessiond/Downloads"]stringByAppendingPathComponent:bundleIdentifier]stringByAppendingPathComponent:localName];
        result = [[NSFileManager defaultManager] moveItemAtPath:localCachePath toPath:localTmpFilePath error:nil];
    }
    return result;
#endif
    // After iOS 9 we can not actually detects if the cache file exists. This plist file has a somehow
    // complicated structue. Besides, the plist structure is different between iOS 9 and iOS 10.
    // We can only assume that the plist being successfully parsed means the resume data is valid.
    return YES;
}

- (instancetype _Nullable)isKindOfSelf:(id _Nullable)from {
    if (from && [from isKindOfClass:self]) {
        return from;
    }
    return nil;
}



@end
