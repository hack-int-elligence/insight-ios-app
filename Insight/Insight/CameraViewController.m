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

@interface CameraViewController ()

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) int loops;
@property (nonatomic) float latitude;
@property (nonatomic) float longitude;
@property (nonatomic) int heading;

@property (nonatomic, strong) UIView *testView;
@property (nonatomic, strong) UILabel *testLabel;
@property (nonatomic, strong) OverLayView *overlayView;

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
    
    //[SVProgressHUD show];
    
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
    NSLog(@"%d", self.heading);
    
    [self updateObjectsWithHeading:self.heading];
}

- (void) updateObjectsWithHeading:(int) heading {
    
    float xval = ((250 - heading)/63.54 + 1/2)*self.view.frame.size.height;
    
    self.testView.center = CGPointMake(self.overlayView.frame.size.width/2, xval);
    self.testLabel.center = self.testView.center;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    if(self.loops == 5) {
        self.latitude = self.locationManager.location.coordinate.latitude;
        self.longitude = self.locationManager.location.coordinate.longitude;
        NSLog(@"%f, %f", self.latitude, self.longitude);
        
        //[self getPlaces];
        
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

- (void) useCamera:(id)sender {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        float scale = ceilf((screenSize.height / floorf(screenSize.width)) * 10.0) / 10.0;
        
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.allowsEditing = NO;
        imagePicker.showsCameraControls = NO;
        imagePicker.navigationBarHidden = YES;
        imagePicker.toolbarHidden = YES;
        imagePicker.cameraViewTransform = CGAffineTransformMakeScale(scale, scale);
        [self presentViewController:imagePicker animated:NO completion:nil];
        
        self.overlayView = [[OverLayView alloc] initWithFrame:imagePicker.view.frame];
        [self.overlayView.layer setOpaque:NO];
        self.overlayView.opaque = NO;
        imagePicker.cameraOverlayView = self.overlayView;
        
        self.testView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 100)];
        self.testView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        self.testView.center = CGPointMake(self.overlayView.frame.size.width/2, self.overlayView.frame.size.height/2);
        self.testView.transform = CGAffineTransformMakeRotation(M_PI_2);
        self.testView.layer.cornerRadius = 5;
        self.testView.layer.masksToBounds = YES;
        [self.overlayView addSubview:self.testView];
        
        self.testLabel = [[UILabel alloc] init];
        [self.testLabel setText: @"Jacob's room ;)"];
        [self.testLabel setTextColor:[UIColor whiteColor]];
        [self.testLabel sizeToFit];
        self.testLabel.center = self.testView.center;
        self.testLabel.transform = CGAffineTransformMakeRotation(M_PI_2);
        [self.overlayView addSubview:self.testLabel];
    }
}

@end
