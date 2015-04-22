//
//  AppDelegate.m
//  Entangled
//
//  Created by Matthew Taylor on 3/14/15.
//  Copyright (c) 2015 Unkempt. All rights reserved.
//

#import "AppDelegate.h"
#import "Reachability.h"
#import <Parse/Parse.h>
#import <OLYCameraKit/OLYCamera.h>

NSString *const kAppDelegateCameraDidChangeConnectionStateNotification = @"kAppDelegateCameraDidChangeConnectionStateNotification";
NSString *const kConnectionStateKey = @"state";
NSString *const kConnectionStateConnected = @"connected";
NSString *const kConnectionStateDisconnected = @"disconnected";

NSString *ICSCameraPropertyTakemode = @"TAKEMODE";
NSString *ICSCameraPropertyDrivemode = @"TAKE_DRIVE";
NSString *ICSCameraPropertyApertureValue = @"APERTURE";
NSString *ICSCameraPropertyShutterSpeed = @"SHUTTER";
NSString *ICSCameraPropertyExposureCompensation = @"EXPREV";
NSString *ICSCameraPropertyWhiteBalance = @"WB";
NSString *ICSCameraPropertyIsoSensitivity = @"ISO";
NSString *ICSCameraPropertyBatteryLevel = @"BATTERY_LEVEL";
NSString *ICSCameraPropertyRecview = @"RECVIEW";

@interface AppDelegate () <OLYCameraConnectionDelegate>

@property (strong, nonatomic) dispatch_queue_t connectionQueue;
@property (strong, nonatomic) OLYCamera *camera;
@property (strong, nonatomic) Reachability *reachabilityForLocalWiFi;
@property (assign, getter = isConnecting, atomic) BOOL connecting;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [Parse setApplicationId:@"98pAYwnjCzzuqAl8ZC7YIIGMHjEnjpIbvU7Hf1nZ"
                  clientKey:@"mx4Bjfy6vSpiBQ5GfkGmcwN4jX2ykRV7fmZhuziZ"];
    
    // Register for Push Notitications
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    
    // Set up camera connection
    _camera = [[OLYCamera alloc] init];
    [_camera setConnectionDelegate:self];
    _connectionQueue = dispatch_queue_create([NSString stringWithFormat:@"%@.queue", [NSBundle mainBundle].bundleIdentifier].UTF8String, DISPATCH_QUEUE_SERIAL);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeNetworkReachability:) name:kReachabilityChangedNotification object:nil];
    _reachabilityForLocalWiFi = [Reachability reachabilityForLocalWiFi];
    
    // Set up parse connection
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    
    NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    if (notificationPayload != nil) {
        NSLog(@"Opened app from push notification - parsing data now");
        NSString *caption = [notificationPayload valueForKey:@"caption"];
        NSLocale* currentLocale = [NSLocale currentLocale];
        NSString* timestamp = [[NSDate date] descriptionWithLocale:currentLocale];
        [self takePicture];
        [self savePictureTimestampWithCaption:caption withTimestamp:timestamp];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"Received push notification while app open - parsing data now");
    NSString *caption = [userInfo objectForKey:@"caption"];
    NSLocale* currentLocale = [NSLocale currentLocale];
    NSString* timestamp = [[NSDate date] descriptionWithLocale:currentLocale];
    [self takePicture];
    [self savePictureTimestampWithCaption:caption withTimestamp:timestamp];
}

- (void)startScanningCamera {
    [self.reachabilityForLocalWiFi startNotifier];
    if (self.reachabilityForLocalWiFi.currentReachabilityStatus == ReachableViaWiFi) {
        [self startConnectingToCamera];
    }
}

- (void)startConnectingToCamera {
    if (self.isConnecting) {
        return;
    }
    self.connecting = YES;
    
    dispatch_async(self.connectionQueue, ^{
        // This process will take some time...
        NSError *error = nil;
        if (![_camera connect:&error]) {
            NSLog(@"To connect to the camera is failed: %@", error ? error : @"Unknown error");
            self.connecting = NO;
            return;
        }
        NSString *userLivePreviewQuality = [[NSUserDefaults standardUserDefaults] stringForKey:@"live_preview_quality"];
        if (userLivePreviewQuality) {
            if (![_camera changeLiveViewSize:CGSizeFromString(userLivePreviewQuality) error:&error]) {
                NSLog(@"To change the live view size is failed: %@", error ? error : @"Unknown error");
            }
        }
        if (![_camera changeRunMode:OLYCameraRunModeRecording error:&error]) {
            NSLog(@"To change the run-mode is failed: %@", error ? error : @"Unknown error");
            self.connecting = NO;
            return;
        }
        
        // Restores my settings.
        if (_camera.connected) {
            NSArray *names = @[ICSCameraPropertyTakemode,
                               ICSCameraPropertyDrivemode,
                               ICSCameraPropertyApertureValue,
                               ICSCameraPropertyShutterSpeed,
                               ICSCameraPropertyExposureCompensation,
                               ICSCameraPropertyWhiteBalance,
                               ICSCameraPropertyIsoSensitivity,
                               ICSCameraPropertyRecview];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSMutableDictionary *values = [[NSMutableDictionary alloc] initWithCapacity:names.count];
            [names enumerateObjectsUsingBlock:^(id name, NSUInteger idx, BOOL *stop) {
                id value = [userDefaults valueForKey:name];
                if (value) {
                    [values setObject:value forKey:name];
                }
            }];
            if (values.count > 0) {
                if (![_camera setCameraPropertyValues:values error:&error]) {
                    NSLog(@"To change the camera properties is failed: %@", error ? error : @"Unknown error");
                }
            }
        }
        self.connecting = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!_camera.connected) {
                return;
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kAppDelegateCameraDidChangeConnectionStateNotification object:self userInfo:@{kConnectionStateKey: kConnectionStateConnected}];
        });
    });
}

- (void)disconnectWithPowerOff:(BOOL)powerOff {
    [[NSNotificationCenter defaultCenter] postNotificationName:kAppDelegateCameraDidChangeConnectionStateNotification object:self userInfo:@{kConnectionStateKey: kConnectionStateDisconnected}];
    
    dispatch_sync(self.connectionQueue, ^{
        NSError *error = nil;
        
        // Stores current settings.
        if (_camera.connected) {
            NSArray *names = @[ICSCameraPropertyTakemode,
                               ICSCameraPropertyDrivemode,
                               ICSCameraPropertyApertureValue,
                               ICSCameraPropertyShutterSpeed,
                               ICSCameraPropertyExposureCompensation,
                               ICSCameraPropertyWhiteBalance,
                               ICSCameraPropertyIsoSensitivity,
                               ICSCameraPropertyRecview];
            NSDictionary *values = [_camera cameraPropertyValues:[NSSet setWithArray:names] error:&error];
            if (values) {
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [values enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    [userDefaults setObject:obj forKey:key];
                }];
            } else {
                NSLog(@"To get the camera properties is failed: %@", error ? error : @"Unknown error");
            }
        }
        
        if (![_camera disconnectWithPowerOff:powerOff error:&error]) {
            NSLog(@"To disconnect from the camera is failed: %@", error ? error : @"Unknown error");
        }
    });
}

OLYCamera *AppDelegateCamera() {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (!delegate) {
        return nil;
    }
    return delegate.camera;
}

void AppDelegateCameraDisconnectWithPowerOff(BOOL powerOff){
    dispatch_async(dispatch_get_main_queue(), ^{
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [delegate disconnectWithPowerOff:powerOff];
    });
}

- (void)takePicture {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    NSLog(@"Started taking the picture");
    OLYCamera *camera = AppDelegateCamera();
    [camera takePicture:nil progressHandler:nil completionHandler:^(NSDictionary *info) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    } errorHandler:^(NSError *error) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];

        if (error.domain != OLYCameraErrorDomain || error.code != OLYCameraErrorFocusFailed) {
            NSString *title = NSLocalizedString(@"Take failed", nil);
            NSString *message = error.localizedDescription;
            NSString *ok = NSLocalizedString(@"OK", nil);
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:ok otherButtonTitles:nil];
            [alertView show];
        }
    }];
    NSLog(@"Finished taking picture");
}

- (void) savePictureTimestampWithCaption:(NSString *)caption withTimestamp:(NSString *)timestamp {
    NSLog(@"Saving picture and timestamp...");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *photoList = [defaults objectForKey:@"photoList"];
    NSDictionary *newData = @{
        @"timestamp": timestamp,
        @"caption": caption
    };
    if (photoList == nil) {
        photoList = [[NSMutableArray alloc] init];
    }
    [photoList addObject:newData];
}

@end
