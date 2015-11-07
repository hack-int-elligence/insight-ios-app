//
//  OverLayView.m
//  Insight
//
//  Created by Krishna Bharathala on 11/6/15.
//  Copyright © 2015 Krishna Bharathala. All rights reserved.
//

#import "OverLayView.h"
#import <QuartzCore/QuartzCore.h>

@interface OverLayView ()

@property (nonatomic, strong) UIButton *eventsButton;
@property (nonatomic, strong) UIButton *foodButton;
@property (nonatomic) BOOL settingsHidden;

@end

@implementation OverLayView

- (void)drawRect:(CGRect)rect {
    self.backgroundColor = [UIColor clearColor];
    
    /*UIButton *testButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [testButton setTitle:@"TEST" forState:UIControlStateNormal];
    [testButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [testButton sizeToFit];
    [testButton setCenter:self.center];
    testButton.transform = CGAffineTransformMakeRotation(M_PI_2);
    [self addSubview:testButton];*/
    
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
    
    [self.eventsButton setHidden:YES];
    [self.foodButton setHidden:YES];
    self.settingsHidden = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnView:)];
    [self addGestureRecognizer:tap];
}

-(void) openSettings {
    NSLog(@"Clicked Settings");
    if(self.settingsHidden) {
        [self.eventsButton setHidden:NO];
        [self.foodButton setHidden:NO];
        self.settingsHidden = NO;
    } else {
        [self.eventsButton setHidden:YES];
        [self.foodButton setHidden:YES];
        self.settingsHidden = YES;
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
}


@end
