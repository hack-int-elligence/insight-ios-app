//
//  InfoViewController.m
//  Insight
//
//  Created by Krishna Bharathala on 11/8/15.
//  Copyright © 2015 Krishna Bharathala. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController ()

@end

@implementation InfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *logoButton=[UIButton buttonWithType:UIButtonTypeCustom];
    logoButton.frame= CGRectMake(0,0,self.view.frame.size.height,self.view.frame.size.width*3/4);
    [logoButton setImage:[UIImage imageNamed:@"insight.jpg"] forState:UIControlStateNormal];
    logoButton.center = CGPointMake(80, self.view.frame.size.height/2);
    logoButton.transform = CGAffineTransformMakeRotation(M_PI_2);
    [logoButton setUserInteractionEnabled:NO];
    [self.view addSubview:logoButton];
    
    UITextView *textView = [[UITextView alloc] init];
    textView.frame = CGRectMake(200, 100, 200, 200);
    textView.text = self.info;
    textView.textColor = [UIColor blackColor];
    [textView setCenter:CGPointMake(200, self.view.frame.size.height/2)];
    textView.allowsEditingTextAttributes = NO;
    textView.transform = CGAffineTransformMakeRotation(M_PI_2);
    [textView setUserInteractionEnabled:NO];
    [self.view addSubview:textView];
    
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [self.view addGestureRecognizer:gr];
    
}

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
