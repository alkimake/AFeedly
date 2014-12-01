//
//  AFMarkers.m
//  Pods
//
//  Created by Alkim Gozen on 10/05/14.
//
//

#import "AFMarkers.h"
#import "AFCount.h"

@implementation AFMarkers

- (NSInteger)totalUnreadCount
{
    NSInteger index = [self.unreadcounts indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [[(AFCount*)obj _id] hasSuffix:@"global.all"];
    }];
    if (index==NSNotFound)
        return 0;
    return [(AFCount*)[self.unreadcounts objectAtIndex:index] count];
}

- (NSInteger)countForFeed:(NSString*)feedId
{
    NSInteger index = [self.unreadcounts indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [[(AFCount*)obj _id] isEqualToString:feedId];
    }];
    if (index==NSNotFound)
        return 0;
    return [(AFCount*)[self.unreadcounts objectAtIndex:index] count];
}

- (NSArray*)userCategoryCounts
{
    NSIndexSet *indexes = [self.unreadcounts indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [[(AFCount*)obj _id] hasPrefix:@"user"];
    }];
    if (indexes==nil)
        return @[];
    return [self.unreadcounts objectsAtIndexes:indexes];
}

- (NSArray*)feedCounts
{
    NSIndexSet *indexes = [self.unreadcounts indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [[(AFCount*)obj _id] hasPrefix:@"feed"];
    }];
    if (indexes==nil)
        return @[];
    return [self.unreadcounts objectsAtIndexes:indexes];
}

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

@end
