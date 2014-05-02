//
//  AFLClient.h
//  AFeedly
//
//  Created by Alkim Gozen on 02/05/14.
//  Copyright (c) 2014 Alkimake. All rights reserved.
//

#import "AFHTTPClient.h"
#import <LROAuth2Client/LROAuth2Client.h>

typedef void(^AFeedlyAuthenticationBlock)(BOOL success, NSError *error);

@interface AFLClient : AFHTTPClient <LROAuth2ClientDelegate>

@property (nonatomic,strong) LROAuth2Client *oauthClient;

@property (nonatomic,strong) NSString *applicationId;
@property (nonatomic,strong) NSString *secretKey;

+ (instancetype) sharedClient;
- (void)initWithApplicationId:(NSString*)appId andSecret:(NSString*)secret;
- (BOOL)isAuthenticated;

- (void)authenticatePresentingViewControllerFrom:(UIViewController*)presentingViewController
                                 withResultBlock:(AFeedlyAuthenticationBlock)resultBlock;
- (void)authenticateUsingWebview:(UIWebView*)webView
                 withResultBlock:(AFeedlyAuthenticationBlock)resultBlock;


@end
