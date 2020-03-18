//
//  SSRequestTokenPlugin.h
//  AFNetworking
//
//  Created by ixiazer on 2020/3/11.
//

#import <Foundation/Foundation.h>
#import "SSRequestProtocal.h"



@interface SSRequestTokenPlugin : NSObject <SSRequestProtocal>

- (NSURLRequest *)prepareRequestForBaseApi:(NSURLRequest *)reqeust baseApi:(SSBaseApi *)baseApi;

@end


