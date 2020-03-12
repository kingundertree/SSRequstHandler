//
//  SSRequestSignPlugin.m
//  AFNetworking
//
//  Created by ixiazer on 2020/3/11.
//

#import "SSRequestSignPlugin.h"

@implementation SSRequestSignPlugin

- (NSURLRequest *)prepareRequestForBaseApi:(NSURLRequest *)reqeust baseApi:(SSBaseApi *)baseApi {
    NSString *method = reqeust.HTTPMethod;
    NSURL *url = reqeust.URL;
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:false];
    
//    __weak typeof(self) this = self;
//    __block
//    NSString *queryAndBodyString = {
////        var reval = [this ];
//
//    };
    
    return reqeust;
}

- (NSString *)queryAndBodyString:(NSURLComponents *)components method:(NSString *)method {
    NSArray *reval = [self _unencodedItems:components];
    
//    if (method) {
//        switch (method) {
//            case @"PUT", @"POST":
//                
//                break;
//                
//            default:
//                break;
//        }
//    }
}

- (NSArray *)_unencodedItems:(NSString *)query {
    NSArray *querys = [query componentsSeparatedByString:@"&"];
    NSMutableArray *mutQuery = [NSMutableArray new];
    for (NSString *str in querys) {
        [mutQuery addObject:[str stringByRemovingPercentEncoding]];
    }
    
    return [NSArray arrayWithArray:mutQuery];
}

@end
