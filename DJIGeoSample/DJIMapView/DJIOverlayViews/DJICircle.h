//
//  DJICircle.h
//  DJIGeoSample
//
//  Copyright © 2015 DJI. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface DJICircle : MKCircle

@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, assign) CGFloat lineWidth;

@end
