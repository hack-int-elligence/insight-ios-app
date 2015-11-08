//
//  ViewController.m
//  Insight
//
//  Created by Krishna Bharathala on 11/5/15.
//  Copyright © 2015 Krishna Bharathala. All rights reserved.
//

#import "CameraViewController.h"
#import "OverLayView.h"
#import "SVProgressHUD/SVProgressHUD.h"
#import "Listing.h"
#import "InfoViewController.h"

#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>


@interface CameraViewController ()

@property (nonatomic, strong) UIImagePickerController *imagePicker;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) int loops;
@property (nonatomic) float latitude;
@property (nonatomic) float longitude;
@property (nonatomic) int heading;
@property (nonatomic) int count;

@property (nonatomic, strong) UIView *testView;
@property (nonatomic, strong) UILabel *testLabel;
@property (nonatomic, strong) OverLayView *overlayView;


@property (nonatomic, strong) NSMutableDictionary *viewToListing;
@property (nonatomic, strong) Listing *currListing;
@property (nonatomic, strong) NSMutableArray *viewArray;

@property (nonatomic) BOOL gettingData;
@property (nonatomic) BOOL didInit;

@end

@implementation CameraViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self useCamera:self];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [self.locationManager requestWhenInUseAuthorization];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    [self.locationManager startUpdatingHeading];
    
    self.viewToListing = [[NSMutableDictionary alloc] init];
    
    self.count = 0;
}

#pragma Getting the main views

- (void) useCamera:(id)sender {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        float scale = ceilf((screenSize.height / floorf(screenSize.width)) * 10.0) / 10.0;
        
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.delegate = self;
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.imagePicker.allowsEditing = NO;
        self.imagePicker.showsCameraControls = NO;
        self.imagePicker.navigationBarHidden = YES;
        self.imagePicker.toolbarHidden = YES;
        self.imagePicker.cameraViewTransform = CGAffineTransformMakeScale(scale, scale);
        [self presentViewController:self.imagePicker animated:NO completion:nil];
        
        self.overlayView = [[OverLayView alloc] initWithFrame:self.imagePicker.view.frame];
        [self.overlayView.layer setOpaque:NO];
        self.overlayView.opaque = NO;
        self.overlayView.parentView = self;
        self.imagePicker.cameraOverlayView = self.overlayView;
    }
}

-(void) initViews {
    for(Listing *l in self.viewArray) {
        [self.overlayView addSubview:l.view];
        [self.overlayView addSubview:l.label];
    }
    self.didInit = YES;
}

-(void) removeViews {
    for(Listing *l in self.viewArray) {
        [l.view removeFromSuperview];
        [l.label removeFromSuperview];
    }
}

#pragma Getting location / header

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    if(self.loops == 3) {
        self.latitude = self.locationManager.location.coordinate.latitude;
        self.longitude = self.locationManager.location.coordinate.longitude;
        NSLog(@"%f, %f", self.latitude, self.longitude);
    }
    self.loops++;
}

-(void) locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    self.heading = (int) newHeading.trueHeading;
    
    if(!self.gettingData) {
        if(self.didInit) {
            [self updateObjectsWithHeading:self.heading];
        } else {
            [self initViews];
        }
    }
}

- (void) updateObjectsWithHeading:(int) heading {
    for(Listing *l in self.viewArray) {
        float xval = ((l.heading - heading)/63.54 + 1/2)*self.view.frame.size.height;
        float yval = (l.distance)/500 * self.view.frame.size.width;
        l.view.center = CGPointMake(yval, xval);
        l.label.center = CGPointMake(yval, xval);
    }
}

#pragma OPTIONS AND THINGS

- (void) viewTap:(UITapGestureRecognizer *)recognizer {
    self.currListing = [self.viewToListing objectForKey:[NSString stringWithFormat:@"%ld", (long)recognizer.view.tag]];
    [self.overlayView openOptions];
}

-(void) displayInfo {
    InfoViewController *infoVC = [[InfoViewController alloc] init];
    //infoVC.info = self.currListing.info;
    infoVC.info = @"This is just some test text so that I can see if this view looks good.";
    [self.imagePicker presentViewController:infoVC animated:YES completion:nil];
}

-(void) displayDirections {
    
    NSString *post = [NSString stringWithFormat: @"currentLocationLatitude=%f&currentLocationLongitude=%f&destinationLatitude=%f&destinationLongitude=%f", self.latitude, self.longitude, self.currListing.latitude, self.currListing.longitude];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:@"https://insight-app.azurewebsites.net/directions"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          NSDictionary *loginSuccessful = [NSJSONSerialization JSONObjectWithData:data
                                                                                                          options:kNilOptions
                                                                                                            error:&error];
                                          NSLog(@"%@", loginSuccessful);
                                      }];
    [dataTask resume];
}

- (void) checkIn {
    
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    
    if (![[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"]) {
        [login logInWithPublishPermissions:@[@"publish_actions"]
                        fromViewController:self
                                   handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                       self.fbAccessToken = [FBSDKAccessToken currentAccessToken].tokenString;}];
    }
    
    NSString *post = [NSString stringWithFormat:@"authToken=%@&latitude=%f&longitude=%f&name=%@",self.fbAccessToken,self.currListing.latitude ,self.currListing.longitude, self.currListing.placeName];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:@"https://insight-app.azurewebsites.net/fb_checkin"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          NSDictionary *loginSuccessful = [NSJSONSerialization JSONObjectWithData:data
                                                                                                          options:kNilOptions
                                                                                                            error:&error];
                                          NSLog(@"%@", loginSuccessful);
                                      }];
    [dataTask resume];
    
}

#pragma Tapped keys

-(void) foodTapped {
    [self removeViews];
    [self getFood];
    self.didInit = NO;
}

-(void) eventsTapped {
    [self removeViews];
    [self getEvents];
    self.didInit = NO;
}

-(void) placesTapped {
    [self removeViews];
    [self getPlaces];
    self.didInit = NO;
}

-(void) allTapped {
    [self removeViews];
    [self getAll];
    self.didInit = NO;
}

#pragma Getting Information to populate view

- (void) getEvents {
    
    self.gettingData = YES;
    NSString *post = [NSString stringWithFormat:@"authToken=%@&latitude=%f&longitude=%f",self.fbAccessToken,self.latitude,self.longitude];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:@"https://insight-app.azurewebsites.net/fb_events"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          NSDictionary *loginSuccessful = [NSJSONSerialization JSONObjectWithData:data
                                                                                                          options:kNilOptions
                                                                                                            error:&error];
                                          
                                          self.viewArray = [[NSMutableArray alloc] init];
                                          NSLog(@"%@", loginSuccessful);
                                          
                                          for (NSDictionary *dict in loginSuccessful) {
                                              Listing *tempListing = [[Listing alloc] init];
                                              tempListing.placeName = [dict objectForKey:@"name"];
                                              tempListing.latitude = [[[[dict objectForKey:@"place"] objectForKey:@"location"] objectForKey:@"latitude"] floatValue];
                                              tempListing.longitude = [[[[dict objectForKey:@"place"] objectForKey:@"location"] objectForKey:@"longitude"] floatValue];
                                              tempListing.address = [[dict objectForKey:@"place"] objectForKey:@"name"];
                                              tempListing.heading = [[dict objectForKey:@"heading"] floatValue];
                                              tempListing.distance = [[dict objectForKey:@"distance"] floatValue];
                                              tempListing.icon = [dict objectForKey:@"description"];
                                              
                                              float xval = ((tempListing.heading - self.heading)/63.54 + 1/2)*self.view.frame.size.height;
                                              
                                              UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
                                              tempView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75];
                                              tempView.center = CGPointMake(self.overlayView.frame.size.width/2, xval);
                                              tempView.transform = CGAffineTransformMakeRotation(M_PI_2);
                                              tempView.layer.cornerRadius = 5;
                                              tempView.layer.masksToBounds = YES;
                                              
                                              UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 130, 30)];
                                              [tempLabel setText: tempListing.placeName];
                                              [tempLabel setTextColor:[UIColor whiteColor]];
                                              tempLabel.center = self.testView.center;
                                              tempLabel.transform = CGAffineTransformMakeRotation(M_PI_2);
                                              tempLabel.adjustsFontSizeToFitWidth = YES;
                                              tempLabel.textAlignment = NSTextAlignmentCenter;
                                              
                                              tempListing.view = tempView;
                                              tempListing.label = tempLabel;
                                              
                                              tempListing.view.userInteractionEnabled = YES;
                                              UITapGestureRecognizer *tapGesture =
                                              [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTap:)];
                                              [tempListing.view addGestureRecognizer:tapGesture];
                                              
                                              tempListing.view.tag = (NSUInteger)self.count;
                                              self.count++;
                                              [self.viewToListing setObject:tempListing forKey:[NSString stringWithFormat:@"%ld",(long)tempListing.view.tag]];
                                              
                                              [self.viewArray addObject:tempListing];
                                          }
                                          NSLog(@"%@", self.viewArray);
                                          self.gettingData = NO;
                                      }];
    [dataTask resume];
}

- (void) getAll {
    self.gettingData = YES;
    NSString *post = [NSString stringWithFormat:@"latitude=%f&longitude=%f",self.latitude,self.longitude];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:@"https://insight-app.azurewebsites.net/insight"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          NSDictionary *loginSuccessful = [NSJSONSerialization JSONObjectWithData:data
                                                                                                          options:kNilOptions
                                                                                                            error:&error];
                                          
                                          self.viewArray = [[NSMutableArray alloc] init];
                                          
                                          for (NSDictionary *dict in loginSuccessful) {
                                              Listing *tempListing = [[Listing alloc] init];
                                              tempListing.placeName = [dict objectForKey:@"name"];
                                              tempListing.latitude = [[[dict objectForKey:@"location"] objectForKey:@"lat"] floatValue];
                                              tempListing.longitude = [[[dict objectForKey:@"location"] objectForKey:@"lng"] floatValue];
                                              tempListing.address = [dict objectForKey:@"address"];
                                              tempListing.heading = [[dict objectForKey:@"heading"] floatValue];
                                              tempListing.distance = [[dict objectForKey:@"distance"] floatValue];
                                              tempListing.icon = [dict objectForKey:@"icon"];
                                              tempListing.info = [dict objectForKey:@"info"];
                                              
                                              float xval = ((tempListing.heading - self.heading)/63.54 + 1/2)*self.view.frame.size.height;
                                              
                                              UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
                                              tempView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75];
                                              tempView.center = CGPointMake(self.overlayView.frame.size.width/2, xval);
                                              tempView.transform = CGAffineTransformMakeRotation(M_PI_2);
                                              tempView.layer.cornerRadius = 5;
                                              tempView.layer.masksToBounds = YES;
                                              
                                              UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 130, 30)];
                                              [tempLabel setText: tempListing.placeName];
                                              [tempLabel setTextColor:[UIColor whiteColor]];
                                              tempLabel.center = self.testView.center;
                                              tempLabel.transform = CGAffineTransformMakeRotation(M_PI_2);
                                              tempLabel.adjustsFontSizeToFitWidth = YES;
                                              tempLabel.textAlignment = NSTextAlignmentCenter;
                                              
                                              tempListing.view = tempView;
                                              tempListing.label = tempLabel;
                                              
                                              tempListing.view.userInteractionEnabled = YES;
                                              UITapGestureRecognizer *tapGesture =
                                              [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTap:)];
                                              [tempListing.view addGestureRecognizer:tapGesture];
                                              
                                              tempListing.view.tag = (NSUInteger)self.count;
                                              self.count++;
                                              [self.viewToListing setObject:tempListing forKey:[NSString stringWithFormat:@"%ld",(long)tempListing.view.tag]];
                                              
                                              [self.viewArray addObject:tempListing];
                                          }
                                          NSLog(@"%@", self.viewArray);
                                          self.gettingData = NO;
                                      }];
    [dataTask resume];
}

- (void) getFood {
    self.gettingData = YES;
    NSString *post = [NSString stringWithFormat:@"latitude=%f&longitude=%f&query=places",self.latitude,self.longitude];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:@"https://insight-app.azurewebsites.net/insight"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          NSDictionary *loginSuccessful = [NSJSONSerialization JSONObjectWithData:data
                                                                                                          options:kNilOptions
                                                                                                            error:&error];
                                          
                                          self.viewArray = [[NSMutableArray alloc] init];
                                          
                                          for (NSDictionary *dict in loginSuccessful) {
                                              Listing *tempListing = [[Listing alloc] init];
                                              tempListing.placeName = [dict objectForKey:@"name"];
                                              tempListing.latitude = [[[dict objectForKey:@"location"] objectForKey:@"lat"] floatValue];
                                              tempListing.longitude = [[[dict objectForKey:@"location"] objectForKey:@"lng"] floatValue];
                                              tempListing.address = [dict objectForKey:@"address"];
                                              tempListing.heading = [[dict objectForKey:@"heading"] floatValue];
                                              tempListing.distance = [[dict objectForKey:@"distance"] floatValue];
                                              tempListing.icon = [dict objectForKey:@"icon"];
                                              tempListing.info = [dict objectForKey:@"info"];
                                              
                                              float xval = ((tempListing.heading - self.heading)/63.54 + 1/2)*self.view.frame.size.height;
                                              
                                              UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
                                              tempView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75];
                                              tempView.center = CGPointMake(self.overlayView.frame.size.width/2, xval);
                                              tempView.transform = CGAffineTransformMakeRotation(M_PI_2);
                                              tempView.layer.cornerRadius = 5;
                                              tempView.layer.masksToBounds = YES;
                                              
                                              UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 130, 30)];
                                              [tempLabel setText: tempListing.placeName];
                                              [tempLabel setTextColor:[UIColor whiteColor]];
                                              tempLabel.center = self.testView.center;
                                              tempLabel.transform = CGAffineTransformMakeRotation(M_PI_2);
                                              tempLabel.adjustsFontSizeToFitWidth = YES;
                                              tempLabel.textAlignment = NSTextAlignmentCenter;
                                              
                                              tempListing.view = tempView;
                                              tempListing.label = tempLabel;
                                              
                                              tempListing.view.userInteractionEnabled = YES;
                                              UITapGestureRecognizer *tapGesture =
                                              [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTap:)];
                                              [tempListing.view addGestureRecognizer:tapGesture];
                                              
                                              tempListing.view.tag = (NSUInteger)self.count;
                                              self.count++;
                                              [self.viewToListing setObject:tempListing forKey:[NSString stringWithFormat:@"%ld",(long)tempListing.view.tag]];
                                              
                                              [self.viewArray addObject:tempListing];
                                          }
                                          NSLog(@"%@", self.viewArray);
                                          self.gettingData = NO;
                                      }];
    [dataTask resume];
}

- (void) getPlaces {
    self.gettingData = YES;
    NSString *post = [NSString stringWithFormat:@"latitude=%f&longitude=%f&query=yale",self.latitude,self.longitude];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:@"https://insight-app.azurewebsites.net/insight"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          NSDictionary *loginSuccessful = [NSJSONSerialization JSONObjectWithData:data
                                                                                                          options:kNilOptions
                                                                                                            error:&error];
                                          
                                          self.viewArray = [[NSMutableArray alloc] init];
                                          
                                          for (NSDictionary *dict in loginSuccessful) {
                                              Listing *tempListing = [[Listing alloc] init];
                                              tempListing.placeName = [dict objectForKey:@"name"];
                                              tempListing.latitude = [[[dict objectForKey:@"location"] objectForKey:@"lat"] floatValue];
                                              tempListing.longitude = [[[dict objectForKey:@"location"] objectForKey:@"lng"] floatValue];
                                              tempListing.address = [dict objectForKey:@"address"];
                                              tempListing.heading = [[dict objectForKey:@"heading"] floatValue];
                                              tempListing.distance = [[dict objectForKey:@"distance"] floatValue];
                                              tempListing.icon = [dict objectForKey:@"icon"];
                                              tempListing.info = [dict objectForKey:@"info"];
                                              
                                              float xval = ((tempListing.heading - self.heading)/63.54 + 1/2)*self.view.frame.size.height;
                                              
                                              UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
                                              tempView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75];
                                              tempView.center = CGPointMake(self.overlayView.frame.size.width/2, xval);
                                              tempView.transform = CGAffineTransformMakeRotation(M_PI_2);
                                              tempView.layer.cornerRadius = 5;
                                              tempView.layer.masksToBounds = YES;
                                              
                                              UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 130, 30)];
                                              [tempLabel setText: tempListing.placeName];
                                              [tempLabel setTextColor:[UIColor whiteColor]];
                                              tempLabel.center = self.testView.center;
                                              tempLabel.transform = CGAffineTransformMakeRotation(M_PI_2);
                                              tempLabel.adjustsFontSizeToFitWidth = YES;
                                              tempLabel.textAlignment = NSTextAlignmentCenter;
                                              
                                              tempListing.view = tempView;
                                              tempListing.label = tempLabel;
                                              
                                              tempListing.view.userInteractionEnabled = YES;
                                              UITapGestureRecognizer *tapGesture =
                                              [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTap:)];
                                              [tempListing.view addGestureRecognizer:tapGesture];
                                              
                                              tempListing.view.tag = (NSUInteger)self.count;
                                              self.count++;
                                              [self.viewToListing setObject:tempListing forKey:[NSString stringWithFormat:@"%ld",(long)tempListing.view.tag]];
                                              
                                              [self.viewArray addObject:tempListing];
                                          }
                                          NSLog(@"%@", self.viewArray);
                                          self.gettingData = NO;
                                      }];
    [dataTask resume];
}

@end
