//
//  DJICustomUnlockOverlay.h
//  DJISdkDemo
//
//  Copyright © 2018 DJI. All rights reserved.
//

#import "DJIMapOverlay.h"
#import "DJISDK/DJISDK.h"

@interface DJICustomUnlockOverlay : DJIMapOverlay

@property(nonatomic, strong) DJICustomUnlockZone *customUnlockInformation;

- (instancetype)initWithCustomUnlockInformation:(DJICustomUnlockZone *)information andEnabled:(BOOL)enabled;

@end
