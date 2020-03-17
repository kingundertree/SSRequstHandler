//
//  FFHomePostApi.m
//  SSRequstHandler
//
//  Created by ixiazer on 2020/3/17.
//  Copyright © 2020 FF. All rights reserved.
//

#import "FFHomePostApi.h"

@implementation FFHomePostApi

- (SSRequestMethod)mehod {
    return SSRequestMethodPOST;
}

- (SSRequestService *)service {
    return [[SSRequestService alloc] initWithBaseUrl:@"https://wx.freshfresh.com"];
}



@end
