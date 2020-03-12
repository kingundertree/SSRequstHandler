//
//  SSRequestQueryStringSerialization.m
//  AFNetworking
//
//  Created by ixiazer on 2020/3/12.
//

#import "SSRequestQueryStringSerialization.h"
#import "AFNetworking.h"
#import "SSRequestQueryStringSerialization.h"

@implementation SSRequestQueryStringSerialization

+ (NSArray *)queryStringPairsFromKey:(NSString *)key andValue:(id) value {
    NSMutableArray *mutableQueryStringComponents = [NSMutableArray array];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES selector:@selector(compare:)];
    
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = value;
        // Sort dictionary keys to ensure consistent ordering in query string, which is important when deserializing potentially ambiguous sequences, such as an array of dictionaries
        for (id nestedKey in [dictionary.allKeys sortedArrayUsingDescriptors:@[ sortDescriptor]]) {
            id nestedValue = dictionary[nestedKey];
            if (nestedValue) {
                [mutableQueryStringComponents addObjectsFromArray:[self queryStringPairsFromKey:(key ? [NSString stringWithFormat:@"%@[%@]", key, nestedKey] : nestedKey) andValue:nestedValue]];
            }
        }
    } else if ([value isKindOfClass:[NSArray class]]) {
        NSArray *array = value;
        for (id nestedValue in array) {
            [mutableQueryStringComponents addObjectsFromArray: [self queryStringPairsFromKey:[NSString stringWithFormat:@"%@", key] andValue:nestedValue]];
        }
    } else if ([value isKindOfClass:[NSSet class]]) {
        NSSet *set = value;
        for (id obj in [set sortedArrayUsingDescriptors:@[ sortDescriptor ]]) {
            [mutableQueryStringComponents addObjectsFromArray: [self queryStringPairsFromKey:key andValue:obj]];
        }
    } else {
        [mutableQueryStringComponents addObject:[[SSRequestQueryStringPair alloc] initWithField:key value:value]];
    }
    
    return mutableQueryStringComponents;
}

+ (NSArray *)queryStringPairsFromDictionary:(NSDictionary *)dictionary {
    return [self queryStringPairsFromKey:nil andValue:dictionary];
}

+ (NSString *)queryStringFromParameters:(id)parameters withURLEncode:(BOOL)encode {
    NSMutableArray *mutablePairs = [NSMutableArray array];
    
    for (SSRequestQueryStringPair *pair in [self queryStringPairsFromDictionary:parameters]) {
        [mutablePairs addObject:[pair stringValueWithURLEncode:encode]];
    }
    
    return [mutablePairs componentsJoinedByString:@"&"];
}

@end

@implementation SSRequestQueryStringPair

- (instancetype)initWithField:(id)field value:(id)value {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.field = field;
    self.value = value;
    
    return self;
}

- (NSString *)stringValueWithURLEncode:(BOOL)encode {
    if (!self.value || [self.value isEqual:[NSNull null]]) {
        if (encode) {
            return AFPercentEscapedStringFromString([self.field description]);
        }
        return [self.field description];
    } else {
        if (encode) {
             return [NSString stringWithFormat:@"%@=%@", AFPercentEscapedStringFromString([self.field description]), AFPercentEscapedStringFromString([self.value description])];
        }
        return [NSString stringWithFormat:@"%@=%@", [self.field description], [self.value description]];
    }
}


@end
