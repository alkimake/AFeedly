//
//  AFSearch.h
//  Pods
//
//  Created by Alkim Gozen on 18/05/14.
//
//

#import "JSONModel.h"
#import "AFResult.h"

@protocol AFResult
@end

@interface AFSearch : JSONModel
@property (nonatomic, strong) NSArray<AFResult> *results;
@property (nonatomic, strong) NSArray *related;
@property (nonatomic, strong) NSString *hint;

@end
