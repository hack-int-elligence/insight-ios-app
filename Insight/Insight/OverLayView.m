//
//  OverLayView.m
//  Insight
//
//  Created by Krishna Bharathala on 11/6/15.
//  Copyright © 2015 Krishna Bharathala. All rights reserved.
//

#import "OverLayView.h"

@implementation OverLayView

- (void)drawRect:(CGRect)rect {
    self.backgroundColor = [UIColor clearColor];
    
    UIButton *testButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [testButton setTitle:@"TEST" forState:UIControlStateNormal];
    [testButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [testButton sizeToFit];
    [testButton setCenter:self.center];
    testButton.transform = CGAffineTransformMakeRotation(M_PI_2);
    [self addSubview:testButton];
    
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingsButton setFrame:CGRectMake(self.frame.size.width-50, self.frame.size.height-50, 40, 40)];
    [settingsButton setImage:[UIImage imageNamed:@"gear.png"] forState:UIControlStateNormal];
    settingsButton.transform = CGAffineTransformMakeRotation(M_PI_2);
    [settingsButton addTarget:self action:@selector(openSettings) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:settingsButton];
}

-(void) openSettings {
    NSLog(@"Clicked Settings");
    
    UIButton *testButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [testButton setTitle:@"TEST" forState:UIControlStateNormal];
    [testButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [testButton sizeToFit];
    [testButton setCenter:self.center];
    testButton.transform = CGAffineTransformMakeRotation(M_PI_2);
    [self addSubview:testButton];
}


@end
