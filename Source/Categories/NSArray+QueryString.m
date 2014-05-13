//
//  NSArray+QueryString.m
//  Pods
//
//  Created by Alkim Gozen on 13/05/14.
//
//

#import "NSArray+QueryString.h"
#import "NSString+QueryString.h"

@implementation NSArray (QueryString)
- (NSArray*)arrayByEscapingForURLQuery
{
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self];
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [tempArray replaceObjectAtIndex:idx withObject:[self[idx] stringByEscapingForURLQuery]];
    }];
    return [NSArray arrayWithArray:tempArray];
}
@end
