//
//  DJILimitSpaceOverlay.h
//  DJIGeoSample
//
//  Copyright © 2017 DJI. All rights reserved.
//

#import "DJIMapOverlay.h"
#import "DJISDK/DJISDK.h"

@interface DJILimitSpaceOverlay : DJIMapOverlay

@property (nonatomic, readonly) DJIFlyZoneInformation *limitSpaceInfo;

- (id)initWithLimitSpace:(DJIFlyZoneInformation *)limitSpaceInfo;

@end
