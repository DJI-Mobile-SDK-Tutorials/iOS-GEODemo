//
//  DJIFlyZoneCircle.h
//
//  Created by Ares on 14-4-28.
//  Copyright (c) 2014年 Sachsen & DJI. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface DJIFlyZoneCircle : MKCircle

@property (nonatomic, assign) CLLocationCoordinate2D flyZoneCoordinate;

@property (nonatomic, assign) CGFloat flyZoneRadius;
@property (nonatomic, assign) uint8_t category;
@property (nonatomic, assign) NSUInteger flyZoneID;
@property (nonatomic, copy) NSString* name;

@end
