//
//  ViewController.m
//  SSRequstHandler
//
//  Created by ixiazer on 2020/3/11.
//  Copyright © 2020 FF. All rights reserved.
//

#import "ViewController.h"
#import "FFHomeApi.h"
#import "SSRequestHandler.h"
#import "NSString+FFHome.h"
#import "FFHomePostApi.h"

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"ViewController did launch");
    
    [SSRequestSettingConfig defaultSettingConfig].appId = @"100001";
    [SSRequestSettingConfig defaultSettingConfig].deviceId = @"mnsdnjenrjkjke38dajdjwejd";
    [SSRequestSettingConfig defaultSettingConfig].token = @"dskjjjjdj3dsjs";
    [SSRequestSettingConfig defaultSettingConfig].secret = @"eiifs9wesdfsjes";
    [SSRequestSettingConfig defaultSettingConfig].plugins = @[[SSRequestTokenPlugin new], [SSRequestSignPlugin new], [SSRequestErrorFilterPlugin new]];
    [SSRequestSettingConfig defaultSettingConfig].isShowDebugInfo = true;
    
    
    [self doGetRequest];
//    [self doPostRequest];
}

- (void)doGetRequest {
    NSDictionary *bizContent = @{@"UserId":[NSNumber numberWithInteger:0]};
    NSDictionary *initDic = @{@"method" : @"HomePageManager.GetHomePageInfo",
                              @"bizContent" : [NSString jsonStringWithDictionary:bizContent],
                              @"module": @"appguide",
                              @"version": @"3.0",
                              @"clientVersion": @"6.4.2",
    };
    // OC 模式 GET Request
    FFHomeApi *homeApi = [[FFHomeApi alloc] initWithPath:@"/gateway" queries:initDic];
    __weak typeof(self) this = self;
    [homeApi requestWithCompletionBlock:^(SSResponse * _Nonnull response, NSError * _Nonnull error) {
        // todo
        if (!error) {
            NSDictionary *responseDic = response.responseDic;
            // todo 业务
        }
    }];
}

- (void)doPostRequest {
    NSDictionary *bizContent = @{@"UserId":[NSNumber numberWithInteger:7457]};
    NSDictionary *initDic = @{@"method" : @"OrderService.GetInvoiceCategories",
                              @"bizContent" : [NSString jsonStringWithDictionary:bizContent],
                              @"module": @"order",
                              @"version": @"3.0",
                              @"clientVersion": @"6.4.2",
    };
    // OC 模式 GET Request
    FFHomePostApi *homeApi = [[FFHomePostApi alloc] initWithPath:@"/gateway" queries:initDic];
    __weak typeof(self) this = self;
    [homeApi requestWithCompletionBlock:^(SSResponse * _Nonnull response, NSError * _Nonnull error) {
        // todo
        if (!error) {
            NSDictionary *responseDic = response.responseDic;
            // todo 业务
        }
    }];
}

@end
