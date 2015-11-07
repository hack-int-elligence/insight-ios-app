//
//  OverLayView.h
//  Insight
//
//  Created by Krishna Bharathala on 11/6/15.
//  Copyright © 2015 Krishna Bharathala. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraViewController.h"

@interface OverLayView : UIView

@property (nonatomic, strong) CameraViewController *parentView;

-(void) openOptions;

@end
