//
//  AppDelegate.h
//  Entangled
//
//  Created by Matthew Taylor on 3/14/15.
//  Copyright (c) 2015 Unkempt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OLYCameraKit/OLYCamera.h>
#import <OLYCameraKit/OLYCameraError.h>

extern NSString *const kAppDelegateCameraDidChangeConnectionStateNotification;
extern NSString *const kConnectionStateKey;
extern NSString *const kConnectionStateConnected;
extern NSString *const kConnectionStateDisconnected;

extern NSString *ICSCameraPropertyTakemode;
extern NSString *ICSCameraPropertyDrivemode;
extern NSString *ICSCameraPropertyApertureValue;
extern NSString *ICSCameraPropertyShutterSpeed;
extern NSString *ICSCameraPropertyExposureCompensation;
extern NSString *ICSCameraPropertyWhiteBalance;
extern NSString *ICSCameraPropertyIsoSensitivity;
extern NSString *ICSCameraPropertyBatteryLevel;
extern NSString *ICSCameraPropertyRecview;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)takePicture;

@end

extern OLYCamera *AppDelegateCamera();
extern void AppDelegateCameraDisconnectWithPowerOff(BOOL powerOff);
