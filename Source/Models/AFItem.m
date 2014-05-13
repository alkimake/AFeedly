//
//  AFItem.m
//  Pods
//
//  Created by Alkim Gozen on 10/05/14.
//
//

#import "AFItem.h"
#import "AFTag.h"
#import <hpple/TFHpple.h>

@implementation AFItem

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSLog(@"initialized");
        
        [self addObserver:self forKeyPath:@"tags" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    self.saved = [self hasSavedTag];
}

+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"id" : @"_id",@"actionTimestamp" : @"actionTime"}];
}
+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

-(BOOL)hasSavedTag
{
    NSIndexSet *indexes = [self.tags indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [[(AFTag*)obj _id] hasSuffix:@"global.saved"];
    }];
    return indexes.count>0;
}

-(void)visualsUrlArray:(void (^)(NSArray*urls ))resultBlock
               failure:(void (^)(NSError*error ))failBlock{
    
    if (self.visual) {
        if (![self.visual.url isEqualToString:@"none"]) {
            resultBlock([NSArray arrayWithObject:self.visual.url]);
        }
    } else {
        
        TFHpple * doc= [[TFHpple alloc] initWithHTMLData:[self.content.content dataUsingEncoding:NSUTF8StringEncoding]];
        
        
        if (doc==nil) {
            //TODO: add new error here
            failBlock(nil);
            return;
        }
        NSArray * elements  = [doc searchWithXPathQuery:@"//img"];
        NSMutableArray *visuals = [[NSMutableArray alloc] initWithCapacity:0];
        for (TFHppleElement *element in elements) {
            [visuals addObject:[element objectForKey:@"src"]];
        }
        resultBlock(visuals);
    }
    
}

@end
