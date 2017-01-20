//
//  AppDelegate.m
//  MiMedia
//
//  Created by iSquare5 on 08/08/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import <GoogleSignIn/GoogleSignIn.h>
#import "MainScreenVC.h"
#import "NotificationVC.h"
#import "IntroVC.h"
#define FACEBOOK_SCHEME  @"fb749392758507092"

@interface AppDelegate ()

@end

@implementation AppDelegate
static NSString * const kClientID = @"495842855206-lqa6u6pa2srp5ddpg7bbctmmufjqf4lu.apps.googleusercontent.com";
@synthesize deviceTokenStr,manuallyPhotosStatusStr;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    pageControl.backgroundColor = [UIColor whiteColor];
   
    //first time when loading menuallyphotosVC status
    manuallyPhotosStatusStr=@"0";
   
    NSLog(@"Start App");
    //push
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [application registerForRemoteNotifications];
    }else{
        //create token
        [application registerForRemoteNotifications];
    }
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *myString =[prefs stringForKey:@"id"];
   
//  NSLog(@"%@",myString);
    if(myString != NULL)
    {
        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    IntroVC *MainPage = (IntroVC*)[mainStoryboard instantiateViewControllerWithIdentifier: @"IntroVC"];
        [navigationController pushViewController:MainPage animated:NO];
    }
    else
    {
        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        MainScreenVC *MainPage = (MainScreenVC*)[mainStoryboard instantiateViewControllerWithIdentifier: @"MainScreenVC"];
        [navigationController pushViewController:MainPage animated:YES];
    }

    //**************** test link //
//    NSString *servicename=@"http://46.166.173.116/FlippyCloud/webservices/ios/test/";
    //**************** //




    
    //**************** #live //
       NSString *servicename=@"http://46.166.173.116/FlippyCloud/webservices/ios/";
    //****************//
    self.Service = [NSURL URLWithString:[NSString stringWithFormat:@"%@",servicename]];
        [FBLoginView class];
        [FBProfilePictureView class];
    [GIDSignIn sharedInstance].clientID = kClientID;
        return YES;
}
- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary *)options {
    if([[url scheme] isEqualToString:FACEBOOK_SCHEME])
    {
        return [FBAppCall handleOpenURL:url
                      sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]];
    }
    else
    {
        return [[GIDSignIn sharedInstance] handleURL:url
                                   sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                          annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
    }
    
    
}


-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    
    
    if([[url scheme] isEqualToString:FACEBOOK_SCHEME])
    {
        return [FBAppCall handleOpenURL:url
                      sourceApplication:sourceApplication];
        
    }
    else
    {
        NSDictionary *options = @{UIApplicationOpenURLOptionsSourceApplicationKey: sourceApplication,
                                  UIApplicationOpenURLOptionsAnnotationKey: annotation};
        return [self application:application
                         openURL:url
                         options:options];
        
    }
    
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceTokena {
    
    deviceTokenStr=[NSString stringWithFormat:@"%@",deviceTokena];
    deviceTokenStr=[deviceTokenStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    deviceTokenStr=[deviceTokenStr stringByReplacingOccurrencesOfString:@"<" withString:@""];
    deviceTokenStr=[deviceTokenStr stringByReplacingOccurrencesOfString:@">" withString:@""];
//  deviceTokenuser=[NSString stringWithFormat:@"%@",deviceTokenStr];
    NSLog(@"deviceTokenStr :%@",deviceTokenStr);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // this is used for clear the count when user press the notification.
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    NSMutableString *notificationType =[[userInfo objectForKey:@"aps"]objectForKey:@"type"];

    if((notificationType=nil))
    {
    }
    
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    NotificationVC *Main = (NotificationVC *)[mainStoryboard instantiateViewControllerWithIdentifier: @"NotificationVC"];
    [navigationController pushViewController:Main animated:NO];
    

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
@end
