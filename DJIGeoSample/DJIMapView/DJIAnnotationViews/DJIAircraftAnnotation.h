//
//  DJIAircraftAnnotation.h
//  DJIGeoSample
//
//  Copyright © 2014 DJI. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface DJIAircraftAnnotation : NSObject <MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, assign) CGFloat heading;

-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate heading:(CGFloat)heading;
@end
