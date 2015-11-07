//
//  Listing.m
//  Insight
//
//  Created by Krishna Bharathala on 11/7/15.
//  Copyright © 2015 Krishna Bharathala. All rights reserved.
//

#import "Listing.h"

@implementation Listing

-(NSString *) description {
    return([NSString stringWithFormat:@"%@, %f, %f, %f", self.placeName, self.latitude, self.longitude, self.heading]);
}

@end
