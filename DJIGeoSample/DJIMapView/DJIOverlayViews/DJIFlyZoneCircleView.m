//
//  DJIFlyZoneCircleView.m
//
//  Copyright © 2014 DJI. All rights reserved.
//

#import "DJIFlyZoneCircleView.h"
#import <DJISDK/DJISDK.h>

#define AuthorizationColor      [UIColor yellowColor]
#define RestrictedColor         [UIColor redColor]
#define WarningColor        [UIColor greenColor]
#define EnhancedWarningColor [UIColor greenColor]

@implementation DJIFlyZoneCircleView

- (id)initWithCircle:(DJIFlyZoneCircle *)circle
{
    self = [super initWithCircle:circle];
    if (self) {
        
        self.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.2];
        self.strokeColor = [[UIColor redColor] colorWithAlphaComponent:0.9];
        
        if (circle.category == DJIFlyZoneCategoryAuthorization) {
            
            self.fillColor = [AuthorizationColor colorWithAlphaComponent:0.1];
            self.strokeColor = [AuthorizationColor colorWithAlphaComponent:1.0];
            
        } else if (circle.category == DJIFlyZoneCategoryRestricted) {

            self.fillColor = [RestrictedColor colorWithAlphaComponent:0.1];
            self.strokeColor = [RestrictedColor colorWithAlphaComponent:1.0];
            
        } else if (circle.category == DJIFlyZoneCategoryWarning) {
            
            self.fillColor = [WarningColor colorWithAlphaComponent:0.1];
            self.strokeColor = [WarningColor colorWithAlphaComponent:1.0];
            
        } else if (circle.category == DJIFlyZoneCategoryEnhancedWarning) {
            
            self.fillColor  = [EnhancedWarningColor colorWithAlphaComponent:0.1];
            self.strokeColor = [EnhancedWarningColor colorWithAlphaComponent:1.0f];
        }
        
        self.lineWidth = 3.0f;
    }
    
    return self;
}

@end
