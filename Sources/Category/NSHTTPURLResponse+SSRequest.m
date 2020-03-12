//
//  NSHTTPURLResponse+SSRequest.m
//  AFNetworking
//
//  Created by ixiazer on 2020/3/12.
//

#import "NSHTTPURLResponse+SSRequest.h"


@implementation NSHTTPURLResponse (SSRequest)

- (NSStringEncoding)stringEncoding {
    NSStringEncoding stringEncoding = NSUTF8StringEncoding;
    if (self.textEncodingName) {
        CFStringEncoding encoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)self.textEncodingName);
        if (encoding != kCFStringEncodingInvalidId) {
            stringEncoding = CFStringConvertEncodingToNSStringEncoding(encoding);
        }
    }
    return stringEncoding;
}


@end
