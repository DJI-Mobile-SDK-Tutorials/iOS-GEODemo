//
//  DJIFlyLimitPolygonView.h
//  DJIGeoSample
//
//  Copyright © 2016 DJI. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "DJIPolygon.h"

@interface DJIFlyLimitPolygonView : MKPolygonRenderer

- (id)initWithPolygon:(DJIPolygon *)polygon;

@end
