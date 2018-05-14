//
//  DJIAircraftAnnotation.h
//  Phantom3
//
//  Created by Ares on 14-8-21.
//  Copyright (c) 2014年 Jerome.zhang. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface DJIAircraftAnnotation : NSObject <MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, assign) CGFloat heading;

-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate heading:(CGFloat)heading;
@end
