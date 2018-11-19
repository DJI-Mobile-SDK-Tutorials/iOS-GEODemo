//
//  DJIFlyLimitPolygonView.m
//  DJIGeoSample
//
//  Copyright © 2016 DJI. All rights reserved.
//

#import "DJIFlyLimitPolygonView.h"
#import <DJISDK/DJISDK.h>
#import "DJIFlyZoneColorProvider.h"

@implementation DJIFlyLimitPolygonView

#pragma mark - life cycle
- (id)initWithPolygon:(DJIPolygon *)polygon {
    if (self = [super initWithPolygon:polygon]) {
		self.fillColor = [DJIFlyZoneColorProvider getFlyZoneOverlayColorWithCategory:polygon.level isHeightLimit:NO isFill:NO];
		self.strokeColor = [DJIFlyZoneColorProvider getFlyZoneOverlayColorWithCategory:polygon.level isHeightLimit:NO isFill:YES];
        self.lineWidth = 1.0;
        self.lineJoin = kCGLineJoinBevel;
        self.lineCap = kCGLineCapButt;
    }
    return self;
}

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context {
    [super drawMapRect:mapRect zoomScale:zoomScale inContext:context];

}

@end
