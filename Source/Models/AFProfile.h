//
//  AFProfile.h
//  Pods
//
//  Created by Alkim Gozen on 10/05/14.
//
//

#import "JSONModel.h"

@interface AFProfile : JSONModel
@property (nonatomic, assign) BOOL twitterConnected;
@property (nonatomic, strong) NSString *familyName;
@property (nonatomic, strong) NSString *google;
@property (nonatomic, strong) NSString *picture;
@property (nonatomic, strong) NSString *client;
@property (nonatomic, assign) BOOL pocketConnected;
@property (nonatomic, strong) NSString *wave;
@property (nonatomic, strong) NSDictionary *paymentProviderId;
@property (nonatomic, strong) NSString *_id;
@property (nonatomic, strong) NSString *gender;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, assign) BOOL dropboxConnected;
@property (nonatomic, assign) BOOL wordPressConnected;
@property (nonatomic, assign) BOOL evernoteConnected;
@property (nonatomic, strong) NSDictionary *paymentSubscriptionId;
@property (nonatomic, assign) BOOL facebookConnected;
@property (nonatomic, strong) NSString *givenName;
@property (nonatomic, assign) BOOL windowsLiveConnected;
@property (nonatomic, strong) NSDate *created;
@property (nonatomic, strong) NSString *fullName;
@end
