//
//  DJIPolygon.h
//  Phantom3
//
//  Created by sunny.li on 15/12/12.
//  Copyright © 2015年 DJIDevelopers.com. All rights reserved.
//

#import <MapKit/MapKit.h>

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

#define UIColorFromRGBA(rgbValue, a) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:a]

@interface DJIPolygon : MKPolygon

/**
 *  根据level决定线条颜色
 */
/*
@property (copy, nonatomic) UIColor *strokeColor;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) CGFloat lineDashPhase;
@property (nonatomic, assign) CGLineCap lineCap;
@property (nonatomic, assign) CGLineJoin lineJoin;
@property (nonatomic, strong) NSArray<NSNumber*> *lineDashPattern;
 */

@property (nonatomic, assign) uint8_t level;

@end
