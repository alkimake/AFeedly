//
//  AFLAuthViewController.m
//  AFeedly
//
//  Created by Alkim Gozen on 03/05/14.
//  Copyright (c) 2014 Alkimake. All rights reserved.
//

#import "AFLAuthViewController.h"

@interface AFLAuthViewController ()

@end

@implementation AFLAuthViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *closeBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(close)];
    [self.navigationItem setRightBarButtonItem:closeBarButtonItem];
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.webView];    
}

- (void)close{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
