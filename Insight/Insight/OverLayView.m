//
//  OverLayView.m
//  Insight
//
//  Created by Krishna Bharathala on 11/6/15.
//  Copyright © 2015 Krishna Bharathala. All rights reserved.
//

#import "OverLayView.h"

@implementation OverLayView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    self.backgroundColor = [UIColor clearColor];
    
    UIButton *testButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [testButton setTitle:@"TEST" forState:UIControlStateNormal];
    [testButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [testButton sizeToFit];
    [testButton setCenter:self.center];
    [self addSubview:testButton];
}


@end
