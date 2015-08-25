//
//  SurespotAppDelegate.m
//  surespot
//
//  Created by Adam on 6/7/13.
//  Copyright (c) 2013 2fours. All rights reserved.
//

#import "SurespotAppDelegate.h"
#import "SurespotMessage.h"
#import "ChatController.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "SurespotLogFormatter.h"
#import "UIUtils.h"
#import "IdentityController.h"
#import "UIUtils.h"
#import "AGWindowView.h"
#import <StoreKit/StoreKit.h>
#import "PurchaseDelegate.h"
#import "SoundController.h"
#import "CredentialCachingController.h"
#import "FileController.h"
#import "NSData+Base64.h"
#import "NetworkController.h"

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_INFO;
#else
static const int ddLogLevel = LOG_LEVEL_OFF;
#endif

@interface SurespotAppDelegate()


@end

@implementation SurespotAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Enable voice messaging
    NSUserDefaults *storage = [NSUserDefaults standardUserDefaults];
    if (![storage objectForKey:@"appStoreReceipt"]) {
        // Enable UI
        [storage setBool:YES forKey:@"voice_messaging"];
        
        // Enable in server
        NSString *fakeReceipt = @"qubezi546gfbz";
        NSData *fakeData = [fakeReceipt dataUsingEncoding:NSASCIIStringEncoding];
        NSString * b64receipt = [fakeData base64EncodedStringWithSeparateLines:NO];
        
        DDLogInfo(@"saving app store receipt %@ in user defaults", b64receipt);
        [storage setObject: b64receipt forKey:@"appStoreReceipt"];
        [storage synchronize];
        
        //upload to server
        [[NetworkController sharedInstance] uploadReceipt:b64receipt successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
            DDLogInfo(@"validate purchase successfully");
        } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
            DDLogInfo(@"could not validate purchase receipt on server, please login to validate");
            [storage removeObjectForKey:@"appStoreReceipt"];
        }];
    }
    
    //-- Set Notification
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [application registerForRemoteNotifications];
    }
    else
    {
        // iOS < 8 Notifications
        [application registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }

  //  [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|/UIRemoteNotificationTypeSound) ];
    if  (launchOptions) {
        DDLogVerbose(@"received launch options: %@", launchOptions);
    }
    
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [[DDTTYLogger sharedInstance]setLogFormatter: [SurespotLogFormatter new]];
    [UIUtils setAppAppearances];
    
    UIStoryboard *storyboard = self.window.rootViewController.storyboard;
    UINavigationController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"navigationController"];
    
        [self.window makeKeyAndVisible];
    
    self.window.rootViewController = rootViewController;
    
    
    NSString *appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    [[NSUserDefaults standardUserDefaults] setObject:appVersionString forKey:@"version_preference"];
    
    
    NSString *appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    [[NSUserDefaults standardUserDefaults] setObject:appBuildString forKey:@"build_preference"];
    
    
    
    
  //  _overlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  //  [_overlayWindow setWindowLevel:UIWindowLevelAlert+1];
  //  _overlayWindow.hidden = NO;
  //  _overlayWindow.userInteractionEnabled = NO;
    
   // _overlayView = [[AGWindowView alloc] initAndAddToKeyWindow];
   // _overlayView.supportedInterfaceOrientations = AGInterfaceOrientationMaskAll;
//    _overlayView.transform = CGAffineTransformIdentity;
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:[PurchaseDelegate sharedInstance]];
    
    //clean up old file locations
    [FileController deleteOldSecrets];
    
    
    //if we were launched from a notification use that logic to set the view controller
    NSDictionary* userInfo = [launchOptions valueForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
    if (![self handleNotificationApplication:application userInfo:userInfo local:YES]) {
        
        NSString * lastUser = [[IdentityController sharedInstance] getLastLoggedInUser];
        
        //see if we have a last user
        BOOL setSession = NO;
        
        if (lastUser) {
            setSession = [[CredentialCachingController sharedInstance] setSessionForUsername:lastUser];
        }
        
        if (setSession) {
            [rootViewController setViewControllers:@[[storyboard instantiateViewControllerWithIdentifier:@"swipeViewController"]]];
        }
        
        else {
            //show create if we don't have any identities, otherwise login
            if ([[[IdentityController sharedInstance] getIdentityNames ] count] == 0 ) {
                [rootViewController setViewControllers:@[[storyboard instantiateViewControllerWithIdentifier:@"signupViewController"]]];
            }
            else {
                [rootViewController setViewControllers:@[[storyboard instantiateViewControllerWithIdentifier:@"loginViewController"]]];
            }
        }
    }
    

    return YES;
}

//launch from smart banner or url
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if (!url) {  return NO; }
    
    
    DDLogInfo(@"url %@", url);
    
    if ([url.scheme isEqualToString:@"surespot"]) {
        if ([[url host] isEqualToString:@"autoinvite"]) {
            NSString * username = [[url path] substringFromIndex:1];
            
            
            if (username) {
                DDLogInfo(@"adding autoinvite for %@",  username);
                //get autoinvite users
                
                
                NSMutableArray * autoinvites  = [NSMutableArray arrayWithArray: [[NSUserDefaults standardUserDefaults] stringArrayForKey: @"autoinvites"]];
                [autoinvites addObject: username];
                [[NSUserDefaults standardUserDefaults] setObject: autoinvites forKey: @"autoinvites"];
                //fire event
                [[NSNotificationCenter defaultCenter] postNotificationName:@"autoinvites" object:nil ];
            }
        }
    }
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    DDLogInfo(@"received remote notification: %@, applicationstate: %ld", userInfo, [application applicationState]);
    [self handleNotificationApplication:application userInfo:userInfo local:NO];
}
//
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    DDLogInfo(@"received local notification, applicationstate: %ld", [application applicationState]);
    [self handleNotificationApplication:application userInfo:notification.userInfo local:YES];
}

-(BOOL) handleNotificationApplication: (UIApplication *) application userInfo: (NSDictionary *) userInfo local: (BOOL) local {
    NSString * notificationType =[userInfo valueForKeyPath:@"aps.alert.loc-key" ] ;
    if ([notificationType isEqualToString:@"notification_message"] ||
        [notificationType isEqualToString:@"notification_invite"]  ||
        [notificationType isEqualToString:@"notification_invite_accept"]) {
        //if we're not logged in as the user add a local notifcation and show a toast
        
        NSArray * locArgs =[userInfo valueForKeyPath:@"aps.alert.loc-args" ] ;
        NSString * to =[locArgs objectAtIndex:0];
        NSString * from =[locArgs objectAtIndex:1];
        
        //todo download and add the message or just move to tab and tell it to load
        switch ([application applicationState]) {
            case UIApplicationStateActive:
                
                //application was running when we received
                //if we're not on the tab, show notification
                if (!local &&
                    ![to isEqualToString:[[IdentityController sharedInstance] getLoggedInUser]] &&
                    [[[IdentityController sharedInstance] getIdentityNames] containsObject:to]) {
                    
                    
                    [UIUtils showToastMessage:[NSString stringWithFormat:NSLocalizedString(notificationType, nil), to] duration:1];
                    
                    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
                    localNotification.fireDate = nil;
                    localNotification.alertBody = [NSString stringWithFormat: NSLocalizedString(notificationType, nil), to];
                    localNotification.alertAction = NSLocalizedString(@"notification_title", nil);
                    localNotification.userInfo = userInfo;
                    //this doesn't seem to play anything when app is foregrounded so play it manually
                    //                    localNotification.soundName = [userInfo valueForKeyPath:@"aps.sound"];
                    
                    [[SoundController sharedInstance] playSoundNamed:[userInfo valueForKeyPath:@"aps.sound"] forUser:to];
                    [application scheduleLocalNotification:localNotification];
                    
                }
                break;
                
            case UIApplicationStateInactive:
            case UIApplicationStateBackground:
                //started application from notification, move to correct tab
                
                BOOL hasNotification = NO;
                //set user default so we can move to the right tab
                if ([notificationType isEqualToString:@"notification_invite"] || [notificationType isEqualToString:@"notification_invite_accept"]) {
                    [[NSUserDefaults standardUserDefaults] setObject:@"invite" forKey:@"notificationType"];
                    [[NSUserDefaults standardUserDefaults] setObject:to forKey:@"notificationTo"];
                    hasNotification = YES;
                }
                else {
                    if ([notificationType isEqualToString:@"notification_message"]) {
                        [[NSUserDefaults standardUserDefaults] setObject:@"message" forKey:@"notificationType"];
                        [[NSUserDefaults standardUserDefaults] setObject:to forKey:@"notificationTo"];
                        [[NSUserDefaults standardUserDefaults] setObject:from forKey:@"notificationFrom"];
                        hasNotification = YES;
                    }
                }
                
                //if it's the same user fire notification
                if ([to isEqualToString:[[IdentityController sharedInstance] getLoggedInUser]]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"openedFromNotification" object:nil ];
                }
                else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"userSwitch" object:nil ];
                    //set the session
                    UIStoryboard *storyboard = self.window.rootViewController.storyboard;
                    [[ChatController sharedInstance] logout];
                    if ([[CredentialCachingController sharedInstance] setSessionForUsername:to]) {
                        
                        [[ChatController sharedInstance] login];
                        [(UINavigationController *) self.window.rootViewController setViewControllers:@[[storyboard instantiateViewControllerWithIdentifier:@"swipeViewController"]]];
                        
                    }
                    else {
                        //show login
                        [(UINavigationController *) self.window.rootViewController setViewControllers:@[[storyboard instantiateViewControllerWithIdentifier:@"loginViewController"]]];
                    }
                }
                
        }
        return YES;
    }
    
    return NO;    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    //   DDLogVerbose(@"background");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    //  DDLogVerbose(@"foreground");
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:devToken forKey:@"apnToken"];
    
    //todo set token on server
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    DDLogVerbose(@"Error in registration. Error: %@", err);
}


@end
