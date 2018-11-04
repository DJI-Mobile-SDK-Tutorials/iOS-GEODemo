//
//  DJIMapPolygon.h
//  DJIGeoSample
//
//  Copyright © 2017 DJI. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface DJIMapPolygon : MKPolygon

@property (copy, nonatomic) UIColor *strokeColor;
@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) CGFloat lineDashPhase;
@property (nonatomic, assign) CGLineCap lineCap;
@property (nonatomic, assign) CGLineJoin lineJoin;
@property (nonatomic, strong) NSArray<NSNumber*> *lineDashPattern;

@end
