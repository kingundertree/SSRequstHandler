//
//  ViewController.m
//  SSRequstHandler
//
//  Created by ixiazer on 2020/3/11.
//  Copyright © 2020 FF. All rights reserved.
//

#import "ViewController.h"
#import "FFHomeApi.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"ViewController did launch");
    
    // OC 模式request
    FFHomeApi *homeApi = [FFHomeApi new];
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
