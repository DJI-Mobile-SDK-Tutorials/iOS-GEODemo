//
//  DJIAircraftAnnotation.m
//  DJIGeoSample
//
//  Copyright © 2014 DJI. All rights reserved.
//

#import "DJIAircraftAnnotation.h"

@implementation DJIAircraftAnnotation

-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate heading:(CGFloat)heading
{
    self = [super init];
    if (self) {
        self.coordinate = coordinate;
        self.heading = heading;
    }
    
    return self;
}

@end
