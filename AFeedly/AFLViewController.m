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
            
            NSLog(@"Authentication Success");
            
        } else {
            
            NSLog(@"%@",error);
            
        }
    }];

}

@end
