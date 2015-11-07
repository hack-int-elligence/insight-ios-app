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
@property (nonatomic) BOOL didInit;

@property (nonatomic, strong) NSMutableArray *storeList;
@property (nonatomic, strong) NSMutableArray *infoButtonList;

@property (nonatomic, strong) NSMutableDictionary *viewToListing;
@property (nonatomic, strong) Listing *currListing;

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
    
    self.didInit = NO;
    self.count = 0;
    
    //[SVProgressHUD show];
    
}

- (void) checkIn {
    
    NSLog(@"i want to check in");
    
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    
    if (![[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"]) {
        [login logInWithPublishPermissions:@[@"publish_actions"]
                        fromViewController:self
                                   handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                       self.fbAccessToken = [FBSDKAccessToken currentAccessToken].tokenString;}];
     }
    
    NSLog(@"%@", self.fbAccessToken);
    NSString *post = [NSString stringWithFormat:@"authToken=%@&latitude=%f&longitude=%f&name=%@",self.fbAccessToken,self.currListing.latitude ,self.currListing.longitude, self.currListing.placeName];
    NSLog(@"%@", post);
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:@"https://yhackinsight.herokuapp.com/fb_checkin"]];
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
                                          //[SVProgressHUD dismiss];
                                      }];
    [dataTask resume];

}

- (void) getEvents {
    
    NSLog(@"authToken=%@",self.fbAccessToken);
    NSString *post = [NSString stringWithFormat:@"authToken=%@&latitude=%f&longitude=%f",self.fbAccessToken,self.latitude,self.longitude];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:@"https://yhackinsight.herokuapp.com/fb_events"]];
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
                                          //[SVProgressHUD dismiss];
                                      }];
    [dataTask resume];

}

-(void) locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    self.heading = (int) newHeading.trueHeading;
    
    if(!self.didInit && [self.storeList count] != 0) {
        [self initViews];
    }
    
    if([self.storeList count] != 0) {
        [self updateObjectsWithHeading:self.heading];
    }
}

-(void) displayInfo {
    NSLog(@"DISPLAYING INFO");
}

-(void) displayDirections {
    
    NSString *post = [NSString stringWithFormat: @"currentLocationLatitude=%f&currentLocationLongitude=%f&destinationLatitude=%f&destinationLongitude=%f", self.latitude, self.longitude, self.currListing.latitude, self.currListing.longitude];
    NSLog(@"%@", post);
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:@"https://yhackinsight.herokuapp.com/directions"]];
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
                                          //[SVProgressHUD dismiss];
                                      }];
    [dataTask resume];

}

-(void) initViews {
    NSLog(@"%@", self.storeList);
    for(Listing *l in self.storeList) {
        [self.overlayView addSubview:l.view];
        [self.overlayView addSubview:l.label];
    }
    self.didInit = YES;
}

- (void) updateObjectsWithHeading:(int) heading {
    
    for(Listing *l in self.storeList) {
        
//        int distance = 12;
//        
//        int theta = -(((((int)(heading - l.heading)%360)+540)%360)-180);
//        NSLog(@"THETA: %d", theta);
//        int val = 2*distance*cos(fabs((double)theta*M_PI/180))*tan(63.54/2*M_PI/180);
//        NSLog(@"VAL: %d", val);
//        int set;
//        if(theta > 0) {
//            set = val/2 + distance*sin(fabs((double) theta*M_PI/180.0));
//        } else {
//            set = distance*sin(fabs((double)theta*M_PI/180.0));
//        }
//        NSLog(@"SET: %d", set);
//        float xval = set/val * self.view.frame.size.height;
//        NSLog(@"XVAL: %f", xval);
//
        
        float xval = ((l.heading - heading)/63.54 + 1/2)*self.view.frame.size.height;
        
        l.view.center = CGPointMake(self.overlayView.frame.size.width/2, xval);
        l.label.center = CGPointMake(self.overlayView.frame.size.width/2+20, xval);
    }
    
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    if(self.loops == 3) {
        self.latitude = self.locationManager.location.coordinate.latitude;
        self.longitude = self.locationManager.location.coordinate.longitude;
        NSLog(@"%f, %f", self.latitude, self.longitude);
        
        [self getPlaces];
        
        if(self.fbAccessToken) {
            [self getEvents];
        }
    }
    self.loops++;
}

-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%@", error.localizedDescription);
}

- (void) getPlaces {
    NSString *post = [NSString stringWithFormat:@"latitude=%f&longitude=%f",self.latitude,self.longitude];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:@"https://yhackinsight.herokuapp.com/insight"]];
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
                                          
                                          self.storeList = [[NSMutableArray alloc] init];
                                          self.viewToListing = [[NSMutableDictionary alloc] init];
                                          
                                          for (NSDictionary *dict in loginSuccessful) {
                                              Listing *tempListing = [[Listing alloc] init];
                                              tempListing.placeName = [dict objectForKey:@"name"];
                                              tempListing.latitude = [[[dict objectForKey:@"location"] objectForKey:@"lat"] floatValue];
                                              tempListing.longitude = [[[dict objectForKey:@"location"] objectForKey:@"lng"] floatValue];
                                              tempListing.address = [dict objectForKey:@"address"];
                                              tempListing.heading = [[dict objectForKey:@"heading"] floatValue];
                                              tempListing.distance = [[dict objectForKey:@"distance"] floatValue];
                                              
                                              float xval = ((tempListing.heading - self.heading)/63.54 + 1/2)*self.view.frame.size.height;
                                              
                                              UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 100)];
                                              tempView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
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
                                              
//                                              UIButton *tempInfoButton = [UIButton buttonWithType:UIButtonTypeCustom];
//                                              [tempInfoButton setImage:[UIImage imageNamed:@"info.png"] forState:UIControlStateNormal];
//                                              [tempInfoButton setFrame:CGRectMake(0, 0, 20, 20)];
//                                              tempInfoButton.center = self.testView.center;
                                              
                                              tempListing.view = tempView;
                                              tempListing.label = tempLabel;
                                              
                                              tempListing.view.userInteractionEnabled = YES;
                                              UITapGestureRecognizer *tapGesture =
                                              [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTap:)];
                                              [tempListing.view addGestureRecognizer:tapGesture];
                                              
                                              tempListing.view.tag = (NSUInteger)self.count;
                                              self.count++;
                                              [self.viewToListing setObject:tempListing forKey:[NSString stringWithFormat:@"%ld",(long)tempListing.view.tag]];
                                              
                                              [self.storeList addObject:tempListing];
                                          }
                                      }];
    [dataTask resume];

}

- (void) viewTap:(UITapGestureRecognizer *)recognizer {
    self.currListing = [self.viewToListing objectForKey:[NSString stringWithFormat:@"%ld", (long)recognizer.view.tag]];
    NSLog(@"%@", self.currListing);
    [self.overlayView openOptions];
    
}

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
        
//        self.testView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 100)];
//        self.testView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
//        self.testView.center = CGPointMake(self.overlayView.frame.size.width/2, self.overlayView.frame.size.height/2);
//        self.testView.transform = CGAffineTransformMakeRotation(M_PI_2);
//        self.testView.layer.cornerRadius = 5;
//        self.testView.layer.masksToBounds = YES;
//        [self.overlayView addSubview:self.testView];
//        
//        self.testLabel = [[UILabel alloc] init];
//        [self.testLabel setText: @"Jacob's room ;)"];
//        [self.testLabel setTextColor:[UIColor whiteColor]];
//        [self.testLabel sizeToFit];
//        self.testLabel.center = self.testView.center;
//        self.testLabel.transform = CGAffineTransformMakeRotation(M_PI_2);
//        [self.overlayView addSubview:self.testLabel];
    }
}

@end
