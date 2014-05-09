//
//  AFLViewController.m
//  test
//
//  Created by Alkim Gozen on 03/05/14.
//  Copyright (c) 2014 Alkimake. All rights reserved.
//

#import "AFLViewController.h"
#import <AFeedly/AFeedly.h>

@interface AFLViewController ()
@property (weak, nonatomic) IBOutlet UIButton *authenticationButton;
@property (weak, nonatomic) IBOutlet UIButton *subscriptionButton;
@property (weak, nonatomic) IBOutlet UIButton *metadataButton;

@property (nonatomic,strong) AFSubscription *feedlySubscription;

@end

@implementation AFLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
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
            
            NSLog(@"Authentication Success");

        } else {
            
            NSLog(@"%@",error);
            
        }
    }];

}

- (IBAction)subscriptionButtonPressed:(id)sender {
    
    [[AFLClient sharedClient] subscriptions:^(NSArray *subscriptions) {
        
        if ([subscriptions count]>0) {
            
            self.feedlySubscription = subscriptions[0];
            
            [_subscriptionButton setTitle:_feedlySubscription.title forState:UIControlStateNormal];
            NSLog(@"%@",self.feedlySubscription.description);
            
            _metadataButton.enabled = YES;
            
            NSArray *feedIds = [subscriptions valueForKeyPath:@"_id"];
            
            [[AFLClient sharedClient] feedsMeta:feedIds success:^(NSArray *feeds) {
                NSLog(@"%@",feeds);
            } failure:^(NSError *error) {
                NSLog(@"%@",error);
            }];
            
            
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
