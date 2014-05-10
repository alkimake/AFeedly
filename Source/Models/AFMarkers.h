//
//  AFMarkers.h
//  Pods
//
//  Created by Alkim Gozen on 10/05/14.
//
//

#import "JSONModel.h"

@protocol AFCount
@end

@interface AFMarkers : JSONModel
@property (nonatomic, strong) NSArray<AFCount> *unreadcounts;
- (NSInteger)totalUnreadCount;
- (NSArray*)userCategoryCounts;
- (NSArray*)feedCounts;
- (NSInteger)countForFeed:(NSString*)feedId;

@end
