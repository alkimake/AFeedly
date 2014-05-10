//
//  AFVisual.h
//  Pods
//
//  Created by Alkim Gozen on 10/05/14.
//
//

#import "JSONModel.h"

@interface AFVisual : JSONModel
@property (nonatomic, assign) int height;
@property (nonatomic, assign) int width;
@property (nonatomic, strong) NSString *contentType;
@property (nonatomic, strong) NSString *url;
@end
