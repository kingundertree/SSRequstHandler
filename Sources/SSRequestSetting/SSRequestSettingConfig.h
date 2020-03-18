//
//  SSRequestSettingConfig.h
//  AFNetworking
//
//  Created by ixiazer on 2020/3/12.
//

#import <Foundation/Foundation.h>


@interface SSRequestSettingConfig : NSObject

+ (SSRequestSettingConfig *)defaultSettingConfig;

// token
@property (nonatomic, copy) NSString *token;

// plugins
@property (nonatomic, strong) NSArray *plugins;

// secret
@property (nonatomic, copy) NSString *secret;

// appId
@property (nonatomic, copy) NSString *appId;

// deviceId
@property (nonatomic, copy) NSString *deviceId;

// isOpen debug
@property (nonatomic, assign) BOOL isShowDebugInfo;

@end


