//
//  NSURLComponents+SSRequest.m
//  AFNetworking
//
//  Created by ixiazer on 2020/3/13.
//

#import "NSURLComponents+SSRequest.h"

@implementation NSURLComponents (SSRequest)

- (NSURLComponents *)appendingQuery:(NSURLQueryItem *)query {
    NSMutableCharacterSet *set = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [set addCharactersInString:@"#"];
    NSString *name = [query.name stringByAddingPercentEncodingWithAllowedCharacters:set];
    if (name) {
        NSString *newQ;
        NSString *value = [query.value stringByAddingPercentEncodingWithAllowedCharacters:set];
    
        if (self.percentEncodedQuery && self.percentEncodedQuery.length > 0) {
            newQ = [NSString stringWithFormat:@"%@&%@=%@", self.percentEncodedQuery, name, value];
        } else {
            newQ = [NSString stringWithFormat:@"%@=%@", name, value];
        }
        
        self.percentEncodedQuery = newQ;
    
        return self;
    }
    
    return nil;
}

@end
