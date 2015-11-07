//
//  OverLayView.m
//  Insight
//
//  Created by Krishna Bharathala on 11/6/15.
//  Copyright © 2015 Krishna Bharathala. All rights reserved.
//

#import "OverLayView.h"
#import <QuartzCore/QuartzCore.h>
#import "CameraViewController.h"

@interface OverLayView ()

@property (nonatomic, strong) UIButton *eventsButton;
@property (nonatomic, strong) UIButton *foodButton;
@property (nonatomic) BOOL settingsHidden;

@property (nonatomic, strong) UIButton *infoButton;
@property (nonatomic, strong) UIButton *directionsButton;
@property (nonatomic) BOOL optionsHidden;

@end

@implementation OverLayView

- (void)drawRect:(CGRect)rect {
    self.backgroundColor = [UIColor clearColor];
    
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingsButton setFrame:CGRectMake(self.frame.size.width-50, self.frame.size.height-50, 40, 40)];
    [settingsButton setImage:[UIImage imageNamed:@"gear.png"] forState:UIControlStateNormal];
    settingsButton.transform = CGAffineTransformMakeRotation(M_PI_2);
    [settingsButton addTarget:self action:@selector(openSettings) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:settingsButton];
    
    self.eventsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.eventsButton setFrame:CGRectMake(self.frame.size.width-100, self.frame.size.height-50, 40, 40)];
    [self.eventsButton setImage:[UIImage imageNamed:@"events.png"] forState:UIControlStateNormal];
    self.eventsButton.transform = CGAffineTransformMakeRotation(M_PI_2);
    [self addSubview:self.eventsButton];
    
    self.foodButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.foodButton setFrame:CGRectMake(self.frame.size.width-150, self.frame.size.height-50, 40, 40)];
    [self.foodButton setImage:[UIImage imageNamed:@"food.png"] forState:UIControlStateNormal];
    self.foodButton.transform = CGAffineTransformMakeRotation(M_PI_2);
    [self addSubview:self.foodButton];
    
    [self dismissSettings];
    
    self.infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.infoButton setFrame:CGRectMake(30, self.frame.size.height/2-40, 60, 60)];
    [self.infoButton setImage:[UIImage imageNamed:@"info.png"] forState:UIControlStateNormal];
    self.infoButton.transform = CGAffineTransformMakeRotation(M_PI_2);
    [self.infoButton addTarget:self action:@selector(showInfo) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.infoButton];
    
    self.directionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.directionsButton setFrame:CGRectMake(30, self.frame.size.height/2+40, 60, 60)];
    [self.directionsButton setImage:[UIImage imageNamed:@"directions.png"] forState:UIControlStateNormal];
    self.directionsButton.transform = CGAffineTransformMakeRotation(M_PI_2);
    [self.directionsButton addTarget:self action:@selector(showDirections) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.directionsButton];
    
    [self dismissOptions];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnView:)];
    [self addGestureRecognizer:tap];
}

-(void) showInfo {
    [self.parentView displayInfo];
    [self dismissOptions];
}

- (void) showDirections {
    [self.parentView displayDirections];
    [self dismissOptions];
}

-(void) openOptions {
    if(self.optionsHidden) {
        [self.directionsButton setHidden:NO];
        [self.infoButton setHidden:NO];
        self.optionsHidden = NO;
    } else {
        [self dismissOptions];
    }
}

-(void) dismissOptions {
    [self.directionsButton setHidden:YES];
    [self.infoButton setHidden:YES];
    self.optionsHidden = YES;
}

-(void) openSettings {
    if(self.settingsHidden) {
        [self.eventsButton setHidden:NO];
        [self.foodButton setHidden:NO];
        self.settingsHidden = NO;
    } else {
        [self dismissSettings];
    }
}

-(void) dismissSettings {
    [self.eventsButton setHidden:YES];
    [self.foodButton setHidden:YES];
    self.settingsHidden = YES;
}

- (void)tapOnView:(UITapGestureRecognizer *)sender {
    NSLog(@"Tapped");
    [self dismissSettings];
    [self dismissOptions];
}


@end
