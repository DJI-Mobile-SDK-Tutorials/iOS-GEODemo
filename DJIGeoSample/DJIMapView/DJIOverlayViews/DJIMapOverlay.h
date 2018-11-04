//
//  DJIMapOverlay.h
//  DJIGeoSample
//
//  Copyright © 2017 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface DJIMapOverlay : NSObject

@property (nonatomic, strong) NSMutableArray<id<MKOverlay>> *subOverlays;

@end
