//
//  LoginViewController.m
//  Insight
//
//  Created by Krishna Bharathala on 11/6/15.
//  Copyright © 2015 Krishna Bharathala. All rights reserved.
//

#import "LoginViewController.h"
#import "CameraViewController.h"

#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface LoginViewController ()

@property (nonatomic, strong) CameraViewController *cameraVC;
@property (nonatomic, strong) NSString *fbAccessToken;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *myLoginButton=[UIButton buttonWithType:UIButtonTypeCustom];
    myLoginButton.frame=CGRectMake(0,0,180,40);
    [myLoginButton setImage:[UIImage imageNamed:@"facebook.png"] forState:UIControlStateNormal];
    myLoginButton.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height - 100);
    [myLoginButton addTarget:self action:@selector(loginButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:myLoginButton];
    
    UIButton *skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [skipButton setTitle:@"Continue without Facebook" forState:UIControlStateNormal];
    [skipButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [skipButton sizeToFit];
    skipButton.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height - 50);
    [skipButton addTarget:self action:@selector(skipFacebook) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:skipButton];

}

-(void)loginButtonClicked {
    
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logInWithReadPermissions: @[@"public_profile", @"email", @"user_events", @"user_friends", @"user_posts"]
     fromViewController:self
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             NSLog(@"Process error");
         } else if (result.isCancelled) {
             NSLog(@"Cancelled");
         } else {
             self.fbAccessToken = [FBSDKAccessToken currentAccessToken].tokenString;
             NSLog(@"%@", self.fbAccessToken);
             
             self.cameraVC = [[CameraViewController alloc] init];
             self.cameraVC.fbAccessToken = self.fbAccessToken;
             
             [self.navigationController pushViewController:self.cameraVC animated:NO];
             
         }
     }];
}

-(void) skipFacebook {
    self.cameraVC = [[CameraViewController alloc] init];
    [self.navigationController pushViewController:self.cameraVC animated:NO];
}

@end
