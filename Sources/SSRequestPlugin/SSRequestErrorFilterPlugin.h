//
//  SSRequestErrorFilterPlugin.h
//  AFNetworking
//
//  Created by ixiazer on 2020/3/12.
//

#import <Foundation/Foundation.h>
#import "SSRequestProtocal.h"



@interface SSRequestErrorFilterPlugin : NSObject <SSRequestProtocal>

- (BOOL)processionResponse:(SSResponse *)response baseApi:(SSBaseApi *)baseApi error:(NSError * _Nullable __autoreleasing *)error;

@end


