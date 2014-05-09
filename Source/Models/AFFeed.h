//
//  AFFeed.h
//  AFeedly
//
//  Created by Alkim Gozen on 09/05/14.
//  Copyright (c) 2014 Alkimake. All rights reserved.
//

#import "JSONModel.h"
#import "AFSuggestion.h"

@protocol AFSuggestion
@end

@interface AFFeed : JSONModel
@property (nonatomic, strong) NSArray *topics;
@property (nonatomic, strong) NSString *website;
@property (nonatomic, strong) NSString *_id;
@property (nonatomic, assign) BOOL featured;
@property (nonatomic, assign) BOOL curated;
@property (nonatomic, assign) BOOL sponsored;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) double subscribers;
@property (nonatomic, assign) double velocity;
@property (nonatomic, strong) NSArray<AFSuggestion> *suggestions;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *language;

@end
