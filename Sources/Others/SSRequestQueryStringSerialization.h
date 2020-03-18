//
//  SSRequestQueryStringSerialization.h
//  AFNetworking
//
//  Created by ixiazer on 2020/3/12.
//

#import <Foundation/Foundation.h>

@interface SSRequestQueryStringSerialization : NSObject

+ (NSArray *)queryStringPairsFromKey:(NSString *)key andValue:(id) value;
+ (NSArray *)queryStringPairsFromDictionary:(NSDictionary *)dictionary;
+ (NSString *)queryStringFromParameters:(id)parameters withURLEncode:(BOOL)encode;

@end

@interface SSRequestQueryStringPair : NSObject
@property (readwrite, nonatomic, strong) id field;
@property (readwrite, nonatomic, strong) id value;

- (instancetype)initWithField:(id)field value:(id)value;
- (NSString *)stringValueWithURLEncode:(BOOL)encode;
@end

