//
//  AFCount.h
//  Pods
//
//  Created by Alkim Gozen on 10/05/14.
//
//

#import "JSONModel.h"

@interface AFCount : JSONModel
@property (nonatomic, strong) NSString *_id;
@property (nonatomic, assign) int count;
@property (nonatomic, strong) NSDate *updated;
@end
