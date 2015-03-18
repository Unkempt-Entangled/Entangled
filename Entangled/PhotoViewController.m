//
//  PhotoViewController.m
//  Entangled
//
//  Created by Tim Mickel on 3/18/15.
//  Copyright (c) 2015 Unkempt. All rights reserved.
//


#import "PhotoViewController.h"


@interface PhotoViewController ()

@end

@implementation PhotoViewController

NSString* registerName;
NSString* registerCode;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.captionRequiredLabel.hidden = YES;
    self.photoSuccess.hidden = YES;
    
    // Check the registration
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    
    registerName = [defaults objectForKey:@"name"];
    registerCode = [defaults objectForKey:@"code"];
    
    if (registerName == nil || registerCode == nil) {
        // Switch to registration
        UIViewController* rv = [[UIStoryboard storyboardWithName:@"MainStoryBoard" bundle:nil] instantiateViewControllerWithIdentifier:@"RegisterViewController"];
        [self.navigationController pushViewController:rv animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)photoGo:(id)sender {
    NSString* caption = [self.captionField text];
    if ([caption length] == 0) {
        self.captionRequiredLabel.hidden = NO;
        return;
    }
    
    // Take a photo
    
    NSLog(registerName);
    
    self.photoSuccess.hidden = NO;
}

@end