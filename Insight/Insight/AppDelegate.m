//
//  AppDelegate.m
//  Insight
//
//  Created by Krishna Bharathala on 11/5/15.
//  Copyright © 2015 Krishna Bharathala. All rights reserved.
//

#import "AppDelegate.h"
#import "CameraViewController.h"
#import "LoginViewController.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface AppDelegate ()

@property (nonatomic, strong) CameraViewController *cameraVC;
@property (nonatomic, strong) LoginViewController *loginVC;
@property (nonatomic, strong) NSString *fbAccessToken;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.cameraVC = [[CameraViewController alloc] init];
    self.loginVC = [[LoginViewController alloc] init];
    
    self.navController = [[UINavigationController alloc] initWithRootViewController:self.loginVC];
    self.navController.navigationBarHidden = YES;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.navController;
    [self.window makeKeyAndVisible];
    
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*self.fbAccessToken = [FBSDKAccessToken currentAccessToken].tokenString;
    NSLog(@"%@", self.fbAccessToken);
    self.cameraVC.fbAccessToken = self.fbAccessToken;
    [self.window setRootViewController:self.cameraVC];
    [self.window makeKeyAndVisible]; */
    
    [FBSDKAppEvents activateApp];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

@end
