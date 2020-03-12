//
//  SSRequestSettingConfig.h
//  AFNetworking
//
//  Created by ixiazer on 2020/3/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSRequestSettingConfig : NSObject

+ (SSRequestSettingConfig *)defaultSettingConfig;

// token
@property (nonatomic, copy) NSString *token;

// plugins
@property (nonatomic, strong) NSArray *plugins;

@end

NS_ASSUME_NONNULL_END
