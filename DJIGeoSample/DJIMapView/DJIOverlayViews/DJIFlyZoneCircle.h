//
//  DJIFlyZoneCircle.h
//
//  Copyright © 2014 DJI. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface DJIFlyZoneCircle : MKCircle

@property (nonatomic, assign) CLLocationCoordinate2D flyZoneCoordinate;

@property (nonatomic, assign) CGFloat flyZoneRadius;
@property (nonatomic, assign) uint8_t category;
@property (nonatomic, assign) NSUInteger flyZoneID;
@property (nonatomic, copy) NSString* name;

@end
