//
//  DJICustomUnlockOverlay.m
//  DJISdkDemo
//
//  Copyright © 2018 DJI. All rights reserved.
//

#import "DJICustomUnlockOverlay.h"
#import "DJICircle.h"

@implementation DJICustomUnlockOverlay

- (instancetype)initWithCustomUnlockInformation:(DJICustomUnlockZone *)information andEnabled:(BOOL)enabled
{
    self = [self init];
    if (self) {
        _customUnlockInformation = information;
        [self createOverlaysWithEnabled:enabled];
    }
    return self;
}

- (void)createOverlaysWithEnabled:(BOOL)enabled
{
    CLLocationCoordinate2D coordinateInMap = _customUnlockInformation.center;
    DJICircle *circle = [DJICircle circleWithCenterCoordinate:coordinateInMap
                                                       radius:_customUnlockInformation.radius];
    circle.lineWidth = 1;
    circle.fillColor = enabled ? [UIColor colorWithRed:0 green:1 blue:0 alpha:0.2] : [UIColor colorWithRed:0 green:0 blue:1 alpha:.2];
    circle.strokeColor = enabled ? [UIColor colorWithRed:0 green:1 blue:0 alpha:0.2] : [UIColor colorWithRed:0 green:0 blue:1 alpha:.2];
    self.subOverlays = [NSMutableArray array];
    [self.subOverlays addObject:circle];
}

@end
