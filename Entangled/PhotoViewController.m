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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.captionRequiredLabel.hidden = YES;
    self.photoSuccess.hidden = YES;

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
    
    self.photoSuccess.hidden = NO;
}

@end