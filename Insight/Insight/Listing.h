//
//  Listing.h
//  Insight
//
//  Created by Krishna Bharathala on 11/7/15.
//  Copyright © 2015 Krishna Bharathala. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Listing : NSObject

@property (nonatomic, strong) NSString *placeName;
@property (nonatomic) float distance;
@property (nonatomic) float latitude;
@property (nonatomic) float longitude;
@property (nonatomic) float heading;
@property (nonatomic, strong) NSString *website;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) UIView *view;
@property (nonatomic, strong) UILabel *label;

@end
