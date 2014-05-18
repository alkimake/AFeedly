//
//  AFResult.h
//  Pods
//
//  Created by Alkim Gozen on 18/05/14.
//
//

#import "JSONModel.h"

@interface AFResult : JSONModel
@property (nonatomic, strong) NSString *feedId;
@property (nonatomic, strong) NSString *website;
@property (nonatomic, assign) int subscribers;
@property (nonatomic, assign) BOOL featured;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) double velocity;
@property (nonatomic, assign) BOOL curated;
@end
