//
//  DJIAircraftAnnotation.m
//  Phantom3
//
//  Created by Ares on 14-8-21.
//  Copyright (c) 2014年 Jerome.zhang. All rights reserved.
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
