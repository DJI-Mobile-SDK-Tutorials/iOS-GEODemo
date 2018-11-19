//
//  DJIFlyZoneCircleView.m
//
//  Copyright © 2014 DJI. All rights reserved.
//

#import "DJIFlyZoneCircleView.h"
#import <DJISDK/DJISDK.h>
#import "DJIFlyZoneColorProvider.h"

@implementation DJIFlyZoneCircleView

- (id)initWithCircle:(DJIFlyZoneCircle *)circle
{
    self = [super initWithCircle:circle];
    if (self) {
        
        self.fillColor = [DJIFlyZoneColorProvider getFlyZoneOverlayColorWithCategory:circle.category isHeightLimit:NO isFill:YES];
		self.strokeColor = [DJIFlyZoneColorProvider getFlyZoneOverlayColorWithCategory:circle.category isHeightLimit:NO isFill:NO];
        self.lineWidth = 1.0f;
    }
    
    return self;
}

@end
