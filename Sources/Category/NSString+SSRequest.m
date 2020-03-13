//
//  NSString+SSRequest.m
//  AFNetworking
//
//  Created by ixiazer on 2020/3/11.
//

#import "NSString+SSRequest.h"
#import "SSRequestConfig.h"
#include "SSRequestHandlerC.h"

@implementation NSString (SSRequest)

+ (NSString *)defaultDownloadTempCacheFolder {
    NSFileManager *fileManager = [NSFileManager new];
    static NSString *cacheFolder;
    if (!cacheFolder) {
        NSString *cacheDir = NSTemporaryDirectory();
        cacheFolder = [cacheDir stringByAppendingPathComponent:SSRequestDownloadFolderName];
    }
    
    NSError *error = nil;
    if(![fileManager createDirectoryAtPath:cacheFolder withIntermediateDirectories:YES attributes:nil error:&error]) {
        cacheFolder = nil;
    }
    return cacheFolder;
}

+ (NSString *)md5StringFromCString:(NSString *)string {
    const char *md5String = md5FromString([string UTF8String]);
    NSString *outputString = [[NSString alloc] initWithUTF8String:md5String];
    if (md5String) {
        free((char*)md5String);
    }
    
    return outputString;
}

@end
