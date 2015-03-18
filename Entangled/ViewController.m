//
//  ViewController.m
//  Entangled
//
//  Created by Matthew Taylor on 3/14/15.
//  Copyright (c) 2015 Unkempt. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.registerFieldsRequired.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)registerButtonPressed:(id)sender {
    NSString *name = [self.registerName text];
    NSString *code = [self.registerCode text];
    
    if ([name length] == 0 || [code length] == 0) {
        self.registerFieldsRequired.hidden = NO;
        return;
    }
    
    [self performSegueWithIdentifier:@"showPhotoPage" sender:self];
    
    
    
}

@end
