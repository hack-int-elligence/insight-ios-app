//
//  ViewController.h
//  Insight
//
//  Created by Krishna Bharathala on 11/5/15.
//  Copyright © 2015 Krishna Bharathala. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface CameraViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSString *fbAccessToken;

-(void) displayInfo;
-(void) displayDirections;


@end

