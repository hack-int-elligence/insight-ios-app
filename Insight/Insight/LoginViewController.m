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
    
    UIButton *logoButton=[UIButton buttonWithType:UIButtonTypeCustom];
    logoButton.frame=CGRectMake(0,0,self.view.frame.size.width,180);
    [logoButton setImage:[UIImage imageNamed:@"insight.jpg"] forState:UIControlStateNormal];
    logoButton.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    [logoButton setUserInteractionEnabled:NO];
    [self.view addSubview:logoButton];
    
    UIView *fillView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/2+90, self.view.frame.size.width, 200)];
    fillView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:fillView];
    
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [self.view addGestureRecognizer:gr];
}

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer {
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

@end
