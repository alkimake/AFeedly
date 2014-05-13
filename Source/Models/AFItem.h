//
//  AFItem.h
//  Pods
//
//  Created by Alkim Gozen on 10/05/14.
//
//

#import "JSONModel.h"
#import "AFVisual.h"
#import "AFOrigin.h"
#import "AFSummary.h"
#import "AFContent.h"

@protocol AFTag
@end
@protocol AFCanonical
@end
@protocol AFAlternate
@end
@protocol AFEnclosure
@end


@interface AFItem : JSONModel
@property (nonatomic, strong) NSString *_id;
@property (nonatomic, strong) NSString *fingerprint;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSDate* published;
@property (nonatomic, strong) NSString *originId;
@property (nonatomic, strong) NSArray<AFTag> *tags;
@property (nonatomic, strong) AFVisual *visual;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSDate* crawled;
@property (nonatomic, strong) NSArray<AFCanonical> *canonical;
@property (nonatomic, strong) NSArray *keywords;
@property (nonatomic, strong) AFOrigin *origin;
@property (nonatomic, strong) AFSummary *summary;
@property (nonatomic, strong) NSArray<AFAlternate> *alternate;
@property (nonatomic, strong) NSArray<AFEnclosure> *enclosure;
@property (nonatomic, strong) NSDate* actionTime;
@property (nonatomic, assign) BOOL unread;
@property (nonatomic, strong) AFContent *content;
@property (nonatomic, assign) BOOL saved;

-(void)visualsUrlArray:(void (^)(NSArray*urls ))resultBlock
               failure:(void (^)(NSError*error ))failBlock;



@end
