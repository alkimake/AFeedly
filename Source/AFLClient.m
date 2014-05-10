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

#pragma mark - Connections

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

@end