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

static NSString * const kFeedlyAPIBaseURLString = @"http://sandbox.feedly.com/v3/";
static NSString * const kFeedlyUserURLString = @"http://sandbox.feedly.com/v3/auth/auth";
static NSString * const kFeedlyTokenURLString = @"http://sandbox.feedly.com/v3/auth/token";

@interface AFLClient ()
@property (strong) AFeedlyAuthenticationBlock authenticationResultBlock;
@property (strong) LROAuth2AccessToken* token;
@property (strong) UINavigationController *authenticationNavigationViewController;
@end

@implementation AFLClient

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
        [self setDefaultHeader:@"Accept" value:@"application/json; charset=utf-8"];
    }
    return self;
}

- (LROAuth2AccessToken*)loadToken
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"feedly/token"];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

- (void)saveToken:(LROAuth2AccessToken*)token{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:token];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"feedly/token"];
}

- (BOOL)isAuthenticated
{
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
    NSLog(@"token : %@",token);
    [self saveToken:token];
    self.token = token;
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


@end
