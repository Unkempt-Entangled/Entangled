//
//  PhotoViewController.m
//  Entangled
//
//  Created by Tim Mickel on 3/18/15.
//  Copyright (c) 2015 Unkempt. All rights reserved.
//


#import "AppDelegate.h"
#import "PhotoViewController.h"
#import <Parse/Parse.h>


@interface PhotoViewController ()

@end

@implementation PhotoViewController

NSString* registerName;
NSString* registerCode;

- (void)viewDidLoad {
    [super viewDidLoad
     ];
    
    self.captionRequiredLabel.hidden = YES;
    self.photoSuccess.hidden = YES;
    
    // Check the registration
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    
    registerName = [defaults objectForKey:@"name"];
    registerCode = [defaults objectForKey:@"code"];
    
    if (registerName == nil || registerCode == nil) {
        // Switch to registration
        UIViewController* rv = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"RegisterViewController"];
        [self.navigationController pushViewController:rv animated:YES];
    }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self view] endEditing:YES];
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
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    OLYCamera *camera = AppDelegateCamera();
    OLYCameraActionType actionType = [camera actionType];
    if (camera.takingPicture) {
        return;
    }
    
    if (actionType == OLYCameraActionTypeSingle ||
        actionType == OLYCameraActionTypeSequential) {
        NSLog(@"Call takePicture");
        [appDelegate takePicture];
    }
    
    // Take a photo
    NSLog([NSString stringWithFormat:@"%@", registerName]);
    [self sendTakePictureNotificationWithCaption: caption];
    
    self.photoSuccess.hidden = NO;
}

- (void)sendTakePictureNotificationWithCaption:(NSString*)caption {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    registerName = [defaults objectForKey:@"name"];
    registerCode = [defaults objectForKey:@"code"];
    
    NSDictionary *payload = @{
        @"caption": caption,
        @"alert": @"",
        @"sound": @"",
        @"content-available": @1
    };
    PFPush *push = [[PFPush alloc] init];
    [push setChannel: registerCode];
    [push setData: payload];
    [push sendPushInBackground];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end