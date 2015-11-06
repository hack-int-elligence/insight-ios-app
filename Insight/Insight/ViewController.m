//
//  ViewController.m
//  Insight
//
//  Created by Krishna Bharathala on 11/5/15.
//  Copyright © 2015 Krishna Bharathala. All rights reserved.
//

#import "ViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface ViewController ()

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) int loops;
@property (nonatomic) float latitude;
@property (nonatomic) float longitude;

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void) viewDidApp {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    loginButton.center = self.view.center;
    loginButton.readPermissions = @[@"public_profile", @"email", @"user_friends", @"user_events"];
    [self.view addSubview:loginButton];
    
    /*NSString *fbAccessToken = [FBSDKAccessToken currentAccessToken].tokenString;
    NSLog(@"%@", fbAccessToken);*/
    
    
    /*self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [self.locationManager requestWhenInUseAuthorization];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation]; */
    
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(self.fbAccessToken) {
        [self getEvents];
    }
}

- (void) getEvents {
    
    NSLog(@"authToken=%@",self.fbAccessToken);
    NSString *post = [NSString stringWithFormat:@"authToken=%@",self.fbAccessToken];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:@"https://yhackinsight.herokuapp.com/fb_events"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if(conn) {
        NSLog(@"Connection Successful");
    } else {
        NSLog(@"Connection could not be made");
    }

}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    if(self.loops == 5) {
    
        self.latitude = self.locationManager.location.coordinate.latitude;
        self.longitude = self.locationManager.location.coordinate.longitude;
        
        NSLog(@"latitude=%f&longitude=%f",self.latitude,self.longitude);
        NSString *post = [NSString stringWithFormat:@"latitude=%f&longitude=%f",self.latitude,self.longitude];
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        
        [request setURL:[NSURL URLWithString:@"https://yhackinsight.herokuapp.com/insight"]];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
        
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        if(conn) {
            NSLog(@"Connection Successful");
        } else {
            NSLog(@"Connection could not be made");
        }
    }
    self.loops++;
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data {
    
    NSError* error;
    NSDictionary *loginSuccessful = [NSJSONSerialization JSONObjectWithData:data
                                                                    options:kNilOptions
                                                                      error:&error];
    NSLog(@"%@", loginSuccessful);
}

- (void) useCamera:(id)sender {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.allowsEditing = NO;
        imagePicker.showsCameraControls = NO;
        imagePicker.navigationBarHidden = YES;
        imagePicker.toolbarHidden = YES;
        [self presentViewController:imagePicker animated:YES completion:nil];
        
    }
}

@end
