//
//  AFCategory.m
//  Pods
//
//  Created by Alkim Gozen on 08/05/14.
//
//

#import "AFCategory.h"
#import "AFLClient.h"

@implementation AFCategory
+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}
+ (AFCategory*)categoryWithLabel:(NSString*)label
{
    AFCategory *category = [AFCategory new];
    category.label = label;
    category._id = [NSString stringWithFormat:@"/user/%@/category/%@",[[[AFLClient sharedClient] profile] _id],[label stringByReplacingOccurrencesOfString:@" " withString:@"-"]];
    
    return category;
}

@end
