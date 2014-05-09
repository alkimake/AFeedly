//
//  NSArray+JSONModelExtensions.m
//  Pods
//
//  Created by Alkim Gozen on 09/05/14.
//
//

#import "NSArray+JSONModelExtensions.h"

@implementation NSArray (JSONModelExtensions)
- (NSString*)toJSONStringFromModels {
    NSMutableArray* jsonObjects = [NSMutableArray new];
    for ( id obj in self )
        [jsonObjects addObject:([obj isMemberOfClass:[NSString class]])?obj:[obj toJSONString]];
    return [NSString stringWithFormat:@"[%@]", [jsonObjects componentsJoinedByString:@","]];
}

- (NSString*)toJSONString {
    NSMutableArray* jsonObjects = [NSMutableArray new];
    for ( id obj in self )
        [jsonObjects addObject:obj];
    return [NSString stringWithFormat:@"[\"%@\"]", [jsonObjects componentsJoinedByString:@"\",\""]];
}

@end
