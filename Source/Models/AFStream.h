//
//  AFStream.h
//  Pods
//
//  Created by Alkim Gozen on 10/05/14.
//
//

#import "JSONModel.h"

@protocol AFItem
@end

@interface AFStream : JSONModel
@property (nonatomic, strong) NSString *_id;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSDate *updated;
@property (nonatomic, strong) NSString *continuation;
@property (nonatomic, strong) NSString *direction;
@property (nonatomic, strong) NSArray<AFItem> *items;

@end
