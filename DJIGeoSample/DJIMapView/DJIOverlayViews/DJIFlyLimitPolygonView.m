//
//  DJIFlyLimitPolygonView.m
//  Phantom3
//
//  Created by tony on 8/8/16.
//  Copyright © 2016 DJIDevelopers.com. All rights reserved.
//

#import "DJIFlyLimitPolygonView.h"
#import <DJISDK/DJISDK.h>

@implementation DJIFlyLimitPolygonView

#pragma mark - life cycle
- (id)initWithPolygon:(DJIPolygon *)polygon {
    if (self = [super initWithPolygon:polygon]) {

        if (polygon.level == DJIFlyZoneCategoryAuthorization) {
            self.strokeColor = UIColorFromRGB(0xFEC300);
            self.fillColor =  UIColorFromRGBA(0xFEC300, 0.1);
        } else if (polygon.level == DJIFlyZoneCategoryRestricted) {
            self.strokeColor = UIColorFromRGB(0xE60000);
            self.fillColor =  UIColorFromRGBA(0xE60000, 0.1);
        } else if (polygon.level == DJIFlyZoneCategoryEnhancedWarning) {
            self.strokeColor =  UIColorFromRGB(0xACDF31);
            self.fillColor =   UIColorFromRGBA(0xACDF31, 0.1);
        }
        self.lineWidth = 3.0;
        self.lineJoin = kCGLineJoinBevel;
        self.lineCap = kCGLineCapButt;
    }
    return self;
}

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context {
    [super drawMapRect:mapRect zoomScale:zoomScale inContext:context];

}

@end
