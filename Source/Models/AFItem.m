//
//  AFItem.m
//  Pods
//
//  Created by Alkim Gozen on 10/05/14.
//
//

#import "AFItem.h"
#import <hpple/TFHpple.h>

@implementation AFItem
+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"actionTimestamp" : @"actionTime"}];
}
+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

-(void)visualsUrlArray:(void (^)(NSArray*urls ))resultBlock
               failure:(void (^)(NSError*error ))failBlock{
    
    if (self.visual) {
        resultBlock([NSArray arrayWithObject:self.visual.url]);
    } else {
        
        TFHpple * doc= [[TFHpple alloc] initWithHTMLData:[self.content.content dataUsingEncoding:NSUTF8StringEncoding]];
        NSArray * elements  = [doc searchWithXPathQuery:@"//img"];
        NSMutableArray *visuals = [[NSMutableArray alloc] initWithCapacity:0];
        for (TFHppleElement *element in elements) {
            [visuals addObject:[element objectForKey:@"src"]];
        }
        resultBlock(visuals);
    }
    
}

@end
