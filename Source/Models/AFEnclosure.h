//
//  AFEnclosure.h
//  Pods
//
//  Created by Alkim Gozen on 10/05/14.
//
//

#import "JSONModel.h"

@interface AFEnclosure : JSONModel
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *href;
@property (nonatomic, assign) int length;
@end
