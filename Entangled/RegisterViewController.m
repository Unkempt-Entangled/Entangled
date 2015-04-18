//
//  ViewController.m
//  Entangled
//
//  Created by Matthew Taylor on 3/14/15.
//  Copyright (c) 2015 Unkempt. All rights reserved.
//

#import "RegisterViewController.h"
#import <Parse/Parse.h>

@interface RegisterViewController ()

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Hidden labels
    self.registerFieldsRequired.hidden = YES;
    
    
    // Unfocus keyboards when tapping on screen
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] 
                                       initWithTarget:self
                                       action:@selector(dismissKeyboard)];

    [self.view addGestureRecognizer:tap];
    
    // Check the registration
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    NSString *name = [defaults objectForKey:@"name"];
    NSString *code = [defaults objectForKey:@"code"];
    
    if (name != nil) {
        self.registerName.text = name;
    }
    if (code != nil) {
        self.registerCode.text = code;
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissKeyboard {
    [self.registerCode resignFirstResponder];
    [self.registerName resignFirstResponder];
}

- (IBAction)registerButtonPressed:(id)sender {
    NSString *name = [self.registerName text];
    NSString *code = [self.registerCode text];
    
    if ([name length] == 0 || [code length] == 0) {
        self.registerFieldsRequired.hidden = NO;
        return;
    }
    
    // Save the registration
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:name forKey:@"name"];
    [defaults setObject:code forKey:@"code"];
    [defaults synchronize];
    
    // Register parse push channel using the inputed code
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation addUniqueObject:code forKey:@"channels"];
    [currentInstallation saveInBackground];
    
    [self performSegueWithIdentifier:@"showPhotoPage" sender:self];
    
}

@end
