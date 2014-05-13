//
//  AFLClient.m
//  AFeedly
//
//  Created by Alkim Gozen on 02/05/14.
//  Copyright (c) 2014 Alkimake. All rights reserved.
//

#import "AFLClient.h"
#import "AFJSONRequestOperation.h"
#import "AFLAuthViewController.h"
#import <LROAuth2Client/LROAuth2AccessToken.h>


static NSString * const kFeedlyAPIBaseURLString = @"http://sandbox.feedly.com/v3";
static NSString * const kFeedlyUserURLString = @"http://sandbox.feedly.com/v3/auth/auth";
static NSString * const kFeedlyTokenURLString = @"http://sandbox.feedly.com/v3/auth/token";

@interface AFLClient ()
@property (strong) AFeedlyAuthenticationBlock authenticationResultBlock;
@property (strong) LROAuth2AccessToken* token;
@property (strong) UINavigationController *authenticationNavigationViewController;
@end

@implementation AFLClient

#pragma mark - Initialization

+ (instancetype) sharedClient {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] initWithBaseURL:[NSURL URLWithString:kFeedlyAPIBaseURLString]];
    });
    
    return _sharedInstance;
}

- (void)initWithApplicationId:(NSString*)appId andSecret:(NSString*)secret {
    self.applicationId = appId;
    self.secretKey = secret;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        self.token = [self loadToken];
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [self setParameterEncoding:AFJSONParameterEncoding];
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        [self setDefaultHeader:@"Accept-Charset" value:@"UTF-8"];
        if (self.token!=nil) {
            [self setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"OAuth %@",self.token.accessToken]];
        }
        
        //JSONModel Key mapping
        [JSONModel setGlobalKeyMapper:[
                                       [JSONKeyMapper alloc] initWithDictionary:@{
                                                                                  @"id":@"_id"
                                                                                  }]
         ];
    }
    return self;
}




#pragma mark - Token & Authentication

- (LROAuth2AccessToken*)loadToken
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"feedly/token"];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

- (void)saveToken:(LROAuth2AccessToken*)token{
    [self setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"OAuth %@",self.token.accessToken]];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:token];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"feedly/token"];
}

- (BOOL)isAuthenticated
{
    NSLog(@"token : %@",self.token.accessToken);
    return self.token!=nil && ![self.token hasExpired];
}

- (void)authenticateUsingWebview:(UIWebView*)webView
                 withResultBlock:(AFeedlyAuthenticationBlock)resultBlock
{
    _authenticationResultBlock = resultBlock;
    if ([self isAuthenticated]) {
        _authenticationResultBlock(YES, nil);
        return;
    }
    
    _oauthClient = [[LROAuth2Client alloc]
                    initWithClientID:_applicationId
                    secret:_secretKey
                    redirectURL:[NSURL URLWithString:@"http://localhost"]];
    _oauthClient.delegate = self;
    _oauthClient.debug = NO;
    
    _oauthClient.userURL = [NSURL URLWithString:kFeedlyUserURLString];
    _oauthClient.tokenURL = [NSURL URLWithString:kFeedlyTokenURLString];
    
    if ([self.token hasExpired]) {
        [_oauthClient refreshAccessToken:self.token];
        return;
    }
    
    [_oauthClient authorizeUsingWebView:webView
                   additionalParameters:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"code",@"https://cloud.feedly.com/subscriptions",nil]
                                                                    forKeys:[NSArray arrayWithObjects:@"response_type",@"scope", nil]]];
    
    
}

- (void)authenticatePresentingViewControllerFrom:(UIViewController*)presentingViewController
                                 withResultBlock:(AFeedlyAuthenticationBlock)resultBlock
{
    _authenticationResultBlock = resultBlock;
    if ([self isAuthenticated]) {
        _authenticationResultBlock(YES, nil);
        return;
    }
    AFLAuthViewController *authViewController = [[AFLAuthViewController alloc] init];
    
    self.authenticationNavigationViewController = [[UINavigationController alloc] initWithRootViewController:authViewController];
    
    [presentingViewController presentViewController:self.authenticationNavigationViewController animated:YES completion:^{
        [self authenticateUsingWebview:authViewController.webView withResultBlock:resultBlock];
    }];
}

- (void)receivedToken:(LROAuth2AccessToken*)token
{
    self.token = token;
    NSLog(@"token : %@",token);
    [self saveToken:token];
    _authenticationResultBlock(YES,nil);
    if (self.authenticationNavigationViewController) {
        [self.authenticationNavigationViewController dismissViewControllerAnimated:YES completion:^{
            // May be navigation view controller should be nil
        }];
    }
}

- (void)oauthClientDidReceiveAccessToken:(LROAuth2Client *)client;
{
    [self receivedToken:client.accessToken];
}
- (void)oauthClientDidRefreshAccessToken:(LROAuth2Client *)client
{
    [self receivedToken:client.accessToken];
}
- (void)oauthClientDidCancel:(LROAuth2Client *)client
{
    NSError *error = [[NSError alloc] initWithDomain:@"feedly" code:500 userInfo:nil];
    _authenticationResultBlock(NO,error);
}

- (BOOL)validateProfile:(void (^)(NSError*error ))failBlock
{
    if (self.profile==nil) {
        NSError *error = [[NSError alloc] initWithDomain:@"AFeedly" code:501 userInfo:@{@"ErrorMessage":@"Profile be fetched first"}];
        failBlock(error);
        return NO;
    }
    return YES;
}

#pragma mark - Definitions

- (NSString*)unreadsCategoryName
{
    return [NSString stringWithFormat:@"user/%@/category/global.all",self.profile._id];
}

- (NSString*)savedTagName
{
    return [NSString stringWithFormat:@"user/%@/tag/global.saved",self.profile._id];
}


#pragma mark - Connections


-(void)markAs:(BOOL)unread
       forIds:(NSArray*)feedIds
     withType:(AFContentType)type
  lastEntryId:(NSString*)lastReadEntryId
         success:(void (^)(BOOL success))resultBlock
         failure:(void (^)(NSError*error ))failBlock
{

    NSMutableDictionary *parameters = [NSMutableDictionary new];
    
    NSString *idArrayName = @"entryIds";
    NSString *typeString = @"entries";
    
    switch (type) {
        case AFContentTypeCategory:
        {
            idArrayName = @"categoryIds";
            typeString = @"categories";
        }
            break;
        case AFContentTypeFeed:
        {
            idArrayName = @"feedIds";
            typeString = @"feeds";
        }
            break;
            
        case AFContentTypeEntry:
        {
            idArrayName = @"entryIds";
            typeString = @"entries";
        }
            break;
            
        default:
            break;
    }
    
    NSString *action = (!unread)?@"markAsRead":@"keepUnread";
    
    [parameters setObject:feedIds forKey:idArrayName];
    [parameters setObject:typeString forKey:@"type"];
    [parameters setObject:action forKey:@"action"];
    if (type!=AFContentTypeEntry) {
        [parameters setObject:lastReadEntryId forKey:@"lastReadEntryId"];
    }
    
    NSMutableURLRequest *req = [self requestWithMethod:@"POST" path:@"markers" parameters:nil];
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    
    [self postPath:@"markers" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        resultBlock(YES);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failBlock(error);
    }];
    
}

-(void)markers:(void (^)(AFMarkers *markers))resultBlock
       failure:(void (^)(NSError*error ))failBlock
{
    [self getPath:@"markers/counts" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        AFMarkers *result = [[AFMarkers alloc] initWithDictionary:responseObject error:&error];
        if(error)
            failBlock(error);
        else
            resultBlock(result);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failBlock(error);
    }];
}


-(void)categories:(void (^)(NSArray*categories ))resultBlock
          failure:(void (^)(NSError*error ))failBlock
{
    [self getPath:@"categories" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *result = [AFCategory arrayOfModelsFromDictionaries:responseObject];
        resultBlock(result);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failBlock(error);
    }];
}

-(void)subscriptions:(void (^)(NSArray*subscriptions ))resultBlock
             failure:(void (^)(NSError*error ))failBlock
{
    [self getPath:@"subscriptions" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *result = [AFSubscription arrayOfModelsFromDictionaries:responseObject];
        resultBlock(result);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failBlock(error);
    }];
}

-(void)feedsMeta:(NSArray*)feedIds
         success:(void (^)(NSArray*feeds ))resultBlock
         failure:(void (^)(NSError*error ))failBlock
{
    NSMutableURLRequest *req = [self requestWithMethod:@"POST" path:@"feeds/.mget" parameters:nil];
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    req.HTTPBody = [[feedIds toJSONString] dataUsingEncoding:NSUTF8StringEncoding];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:req success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *result = [AFFeed arrayOfModelsFromDictionaries:responseObject];
        resultBlock(result);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failBlock(error);
    }];
    [operation start];
}


-(void)feed:(NSString*)feedId
    success:(void (^)(AFFeed*feed ))resultBlock
    failure:(void (^)(NSError*error ))failBlock
{
    [self getPath:[NSString stringWithFormat:@"feeds/%@",[feedId stringByEscapingForURLQuery]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        NSDictionary *responseDictionary = (NSDictionary*)responseObject;
        AFFeed *feed = [[AFFeed alloc] initWithDictionary:responseDictionary error:&error];
        if (error) {
            failBlock(error);
        } else
            resultBlock(feed);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failBlock(error);
    }];
}

-(void)profile:(void (^)(AFProfile*profile ))resultBlock
       failure:(void (^)(NSError*error ))failBlock
{
    [self getPath:@"profile" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        NSDictionary *responseDictionary = (NSDictionary*)responseObject;
        AFProfile *profile = [[AFProfile alloc] initWithDictionary:responseDictionary error:&error];
        if (error) {
            failBlock(error);
        } else{
            self.profile = profile;
            resultBlock(profile);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failBlock(error);
    }];
}

-(void)getStreamContentForId:(NSString*)contentId
                  unreadOnly:(BOOL)unread
                     success:(void (^)(AFStream*stream ))resultBlock
                     failure:(void (^)(NSError*error ))failBlock
{
    NSString *path = [NSString stringWithFormat:@"streams/contents?streamId=%@&unreadOnly=%@",[contentId stringByEscapingForURLQuery],unread?@"true":@"false"];
    
    [self getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        NSDictionary *responseDictionary = (NSDictionary*)responseObject;
        AFStream *stream = [[AFStream alloc] initWithDictionary:responseDictionary error:&error];
        if (error) {
            failBlock(error);
        } else{
            
            if (_isSyncWithServer) {
                
                for (AFItem*item in stream.items) {
                    [item addObserver:self forKeyPath:@"unread" options:NSKeyValueObservingOptionNew context:nil];
                    [item addObserver:self forKeyPath:@"saved" options:NSKeyValueObservingOptionNew context:nil];
                }
                
            }
            
            resultBlock(stream);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failBlock(error);
    }];
    
}

-(void)saved:(void (^)(AFStream*stream ))resultBlock
     failure:(void (^)(NSError*error ))failBlock
{
    if (![self validateProfile:failBlock]) {
        return;
    }
    NSString *tag = [self savedTagName];
    [self getStreamContentForId:tag unreadOnly:NO success:resultBlock failure:failBlock];
}

-(void)unreadStream:(void (^)(AFStream*stream ))resultBlock
            failure:(void (^)(NSError*error ))failBlock
{
    if (![self validateProfile:failBlock]) {
        return;
    }
    NSString *categoryId = [self unreadsCategoryName];
    [self getStreamContentForId:categoryId unreadOnly:YES success:resultBlock failure:failBlock];
}

-(void)tagEntry:(NSString*)entryId
           tags:(NSArray*)tags
        success:(void (^)(BOOL success ))resultBlock
     failure:(void (^)(NSError*error ))failBlock
{
    if (![self validateProfile:failBlock]) {
        return;
    }
    
    
    NSString *path = [NSString stringWithFormat:@"tags/%@",[[tags arrayByEscapingForURLQuery] componentsJoinedByString:@","]];
    
    NSLog(@"%@",path);
    
    NSDictionary *parameters = @{@"entryId":entryId};
    
    [self getPath:path
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              resultBlock(YES);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              failBlock(error);
          }];
    
}

-(void)tagEntries:(NSArray*)entryIds
           tags:(NSArray*)tags
        success:(void (^)(BOOL success ))resultBlock
        failure:(void (^)(NSError*error ))failBlock
{
    if (![self validateProfile:failBlock]) {
        return;
    }
    
    
    NSString *path = [NSString stringWithFormat:@"tags/%@",[[tags arrayByEscapingForURLQuery] componentsJoinedByString:@","]];
    
    NSLog(@"%@",path);
    
    NSString *entries = [entryIds toJSONString];
    NSDictionary *parameters = @{@"entryIds":entries};
    
    [self getPath:path
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              resultBlock(YES);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              failBlock(error);
          }];
    
}


-(void)untagEntries:(NSArray*)entryIds
             tags:(NSArray*)tags
          success:(void (^)(BOOL success ))resultBlock
          failure:(void (^)(NSError*error ))failBlock
{
    if (![self validateProfile:failBlock]) {
        return;
    }
    
    NSString *path = [NSString stringWithFormat:@"tags/%@/%@",[[tags arrayByEscapingForURLQuery] componentsJoinedByString:@","],[[entryIds arrayByEscapingForURLQuery] componentsJoinedByString:@","]];
    
    NSLog(@"%@",path);
    
    [self deletePath:path
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              resultBlock(YES);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              failBlock(error);
          }];
    
}



#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{

    if ([object isKindOfClass:[AFItem class]]) {
        
        AFItem *item = (AFItem*)object;
        
        if ([keyPath isEqualToString:@"unread"]) {
            [self markAs:item.unread
                  forIds:@[item._id]
                withType:AFContentTypeEntry
             lastEntryId:nil
                 success:^(BOOL success) {
                     NSLog(@"mark as %@",item.unread?@"unread":@"read");
                 } failure:^(NSError *error) {
                     NSLog(@"%@",error.localizedDescription);
                 }];
        }
        
        if ([keyPath isEqualToString:@"saved"]) {
            
            if (item.saved) {
                [self tagEntry:item._id
                          tags:@[[self savedTagName]]
                       success:^(BOOL success) {
                           NSLog(@"saved");
                       } failure:^(NSError *error) {
                           NSLog(@"%@",error.localizedDescription);
                       }];
            } else {
            
                [self untagEntries:@[item._id]
                              tags:@[[self savedTagName]]
                           success:^(BOOL success) {
                               NSLog(@"unsaved");
                           } failure:^(NSError *error) {
                               NSLog(@"%@",error.localizedDescription);
                           }];
            }
            
            
        }
    }
}


@end
