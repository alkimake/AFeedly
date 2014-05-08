//
//  Subscription.h
//  Pods
//
//  Created by Alkim Gozen on 08/05/14.
//
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
#import "AFCategory.h"

@protocol AFCategory
@end


@interface AFSubscription : JSONModel
@property (nonatomic, strong) NSString *_id;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *website;
@property (nonatomic, strong) NSArray<AFCategory> *categories;
@property (nonatomic, strong) NSDate *updated;
@property (nonatomic, assign) double velocity;
@end
