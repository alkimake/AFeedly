//
//  AFLViewController.m
//  test
//
//  Created by Alkim Gozen on 03/05/14.
//  Copyright (c) 2014 Alkimake. All rights reserved.
//

#import "AFLViewController.h"
#import <AFeedly/AFeedly.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <QuartzCore/QuartzCore.h>

@interface AFLViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UIButton *authenticationButton;
@property (weak, nonatomic) IBOutlet UIButton *subscriptionButton;
@property (weak, nonatomic) IBOutlet UIButton *metadataButton;
@property (weak, nonatomic) IBOutlet UIButton *categoryButton;
@property (weak, nonatomic) IBOutlet UIButton *allUnreadButton;

@property (nonatomic,strong) AFSubscription *feedlySubscription;
@property (nonatomic,strong) NSArray *subscriptions;

@end

@implementation AFLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[_profileImage layer] setMasksToBounds:YES];
    [[_profileImage layer] setCornerRadius:25.0f];
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
- (IBAction)authenticateButtonPressed:(id)sender {
    
    [[AFLClient sharedClient] authenticatePresentingViewControllerFrom:self withResultBlock:^(BOOL success, NSError *error) {
        if (success) {
            
            _authenticationButton.enabled = NO;
            _subscriptionButton.enabled = YES;
            _categoryButton.enabled = YES;
            
            NSLog(@"Authentication Success");
            
            [self getProfile];

        } else {
            
            NSLog(@"%@",error);
            
        }
    }];

}
- (IBAction)allUnreadButtonPressed:(id)sender {
    [[AFLClient sharedClient] unreadStream:^(AFStream *stream) {
        NSLog(@"Unread Stream Returned");
        
        [[[stream items] lastObject] setUnread:NO];
        [[[stream items] lastObject] setSaved:YES];
        
        
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

-(void)getSaved{
    [[AFLClient sharedClient] saved:^(AFStream *stream) {
        
    } failure:^(NSError *error) {
        
    }];

}

- (void)getProfile{
    [[AFLClient sharedClient] profile:^(AFProfile *profile) {
        NSLog(@"%@",profile);
        [_profileImage setImageWithURL:[NSURL URLWithString:profile.picture]];
        
        [_allUnreadButton setEnabled:YES];
    } failure:^(NSError *error) {
        
    }];
}

- (IBAction)categoryButtonPressed:(id)sender {
    
    [[AFLClient sharedClient] categories:^(NSArray *categories) {
        
        if ([categories count]>0) {
            
            [_categoryButton setTitle:((AFCategory*)categories[0]).label forState:UIControlStateNormal];
            NSLog(@"%@",categories);
        }
        
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];

}

- (void)getAllFeedsMetaData{
    NSArray *feedIds = [_subscriptions valueForKeyPath:@"_id"];
    
    [[AFLClient sharedClient] feedsMeta:feedIds success:^(NSArray *feeds) {
        NSLog(@"%@",feeds);
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

-(void)getMarkers
{
    [[AFLClient sharedClient] markers:^(AFMarkers *markers) {
        NSLog(@"%@",markers);
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (IBAction)subscriptionButtonPressed:(id)sender {
    
    [[AFLClient sharedClient] subscriptions:^(NSArray *subscriptions) {
        
        if ([subscriptions count]>0) {
            
            self.feedlySubscription = subscriptions[0];
            self.subscriptions = subscriptions;
            
            [_subscriptionButton setTitle:_feedlySubscription.title forState:UIControlStateNormal];
            NSLog(@"%@",self.feedlySubscription.description);
            
            _metadataButton.enabled = YES;
        }
        
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];

}
- (IBAction)metadataButtonPressed:(id)sender {
    
    [[AFLClient sharedClient] feed:self.feedlySubscription._id success:^(AFFeed *feed) {
        NSLog(@"%@",feed.description);
        [_metadataButton setTitle:feed.website forState:UIControlStateNormal];
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}




@end
