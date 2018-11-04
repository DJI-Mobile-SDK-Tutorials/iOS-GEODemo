//
//  DJIMapView.m
//  DJIGeoSample
//
//  Copyright © 2014 DJI. All rights reserved.
//

#import "DJIMapViewController.h"
#import <DJISDK/DJISDK.h>
#import "DJIAircraftAnnotation.h"
#import "DJIAircraftAnnotationView.h"
#import "DJIFlyZoneCircle.h"
#import "DJIFlyZoneCircleView.h"
#import "DemoUtility.h"
#import "DJILimitSpaceOverlay.h"
#import "DJIMapPolygon.h"
#import "DJIFlyLimitPolygonView.h"
#import "DJICircle.h"
#import "DJICustomUnlockOverlay.h"

#define UPDATETIMESTAMP (10)


@interface DJIMapViewController () <MKMapViewDelegate>

@property (nonatomic) CLLocationCoordinate2D aircraftCoordinate;
@property (weak, nonatomic) MKMapView *mapView;
@property (nonatomic, strong) DJIAircraftAnnotation* aircraftAnnotation;
@property (nonatomic, strong) NSMutableArray<DJIMapOverlay *> *mapOverlays;
@property (nonatomic, strong) NSMutableArray<DJIMapOverlay *> *customUnlockOverlays;
@property (nonatomic, assign) NSTimeInterval lastUpdateTime;

@end

@implementation DJIMapViewController

- (id)initWithMap:(MKMapView*)mapView{
    if (nil != mapView) {
        self = [super init];
        if (self) {
            self.mapView = mapView;
            self.mapView.delegate = self;
            self.flyZones = [NSMutableArray array];
            self.mapOverlays = [NSMutableArray array];
            [self forceUpdateFlyZones];
        }
        return self;
    }
    return nil;
}

- (void)dealloc
{
    if (self.aircraftAnnotation) {
        self.aircraftAnnotation = nil;
    }
    if (self.mapView.delegate) {
        self.mapView.delegate = nil;
    }
    if (self.mapView) {
        self.mapView = nil;
    }
}

-(void) updateAircraftLocation:(CLLocationCoordinate2D)coordinate withHeading:(CGFloat)heading
{
    if (CLLocationCoordinate2DIsValid(coordinate)) {
        
        self.aircraftCoordinate = coordinate;
        
        if (self.aircraftAnnotation == nil) {
            self.aircraftAnnotation =  [[DJIAircraftAnnotation alloc] initWithCoordinate:coordinate heading:heading];
            [self.mapView addAnnotation:self.aircraftAnnotation];
            MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coordinate, 500, 500);
            MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
            [self.mapView setRegion:adjustedRegion animated:YES];
            [self updateFlyZones];
        }
        else
        {
            [self.aircraftAnnotation setCoordinate:coordinate];
            DJIAircraftAnnotationView *annotationView = (DJIAircraftAnnotationView *)[_mapView viewForAnnotation:self.aircraftAnnotation];
            [annotationView updateHeading:heading];
            [self updateFlyZones];
        }
        
    }
}

#pragma mark - MKMapViewDelegate Methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }else if ([annotation isKindOfClass:[DJIAircraftAnnotation class]])
    {
        
        static NSString* aircraftReuseIdentifier = @"DJI_AIRCRAFT_ANNOTATION_VIEW";
        DJIAircraftAnnotationView* aircraftAnno = (DJIAircraftAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:aircraftReuseIdentifier];
        if (aircraftAnno == nil) {
            aircraftAnno = [[DJIAircraftAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:aircraftReuseIdentifier];
        }

        return aircraftAnno;
    }

    return nil;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay
{
   if ([overlay isKindOfClass:[DJIFlyZoneCircle class]]) {
       
       DJIFlyZoneCircleView* circleView = [[DJIFlyZoneCircleView alloc] initWithCircle:overlay];
       return circleView;
   }else if([overlay isKindOfClass:[DJIPolygon class]]){
       DJIFlyLimitPolygonView *polygonRender = [[DJIFlyLimitPolygonView alloc] initWithPolygon:(DJIPolygon *)overlay];
       return polygonRender;
   }else if ([overlay isKindOfClass:[DJIMapPolygon class]]) {
       MKPolygonRenderer *polygonRender = [[MKPolygonRenderer alloc] initWithPolygon:(MKPolygon *)overlay];
       DJIMapPolygon *polygon = (DJIMapPolygon *)overlay;
       polygonRender.strokeColor = polygon.strokeColor;
       polygonRender.lineWidth = polygon.lineWidth;
       polygonRender.lineDashPattern = polygon.lineDashPattern;
       polygonRender.lineJoin = polygon.lineJoin;
       polygonRender.lineCap = polygon.lineCap;
       polygonRender.fillColor = polygon.fillColor;
       return polygonRender;
   } else if ([overlay isKindOfClass:[DJICircle class]]) {
       DJICircle *circle = (DJICircle *)overlay;
       MKCircleRenderer *circleRender = [[MKCircleRenderer alloc] initWithCircle:circle];
       circleRender.strokeColor = circle.strokeColor;
       circleRender.lineWidth = circle.lineWidth;
       circleRender.fillColor = circle.fillColor;
       return circleRender;
   }

    return nil;
}

#pragma mark - Update Fly Zones in Surrounding Area

-(void) updateFlyZones
{
    if ([self canUpdateLimitFlyZoneWithCoordinate]) {
        [self updateFlyZonesInSurroundingArea];
		[self updateCustomUnlockZone];
    }
}

- (void)forceUpdateFlyZones
{
    [self updateFlyZonesInSurroundingArea];
}

-(BOOL) canUpdateLimitFlyZoneWithCoordinate
{
    NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
    
    if ((currentTime - self.lastUpdateTime) < UPDATETIMESTAMP) {
        return NO;
    }
    
    self.lastUpdateTime = [NSDate timeIntervalSinceReferenceDate];
    return YES;
}

-(void) updateFlyZonesInSurroundingArea
{
    WeakRef(target);
    [[DJISDKManager flyZoneManager] getFlyZonesInSurroundingAreaWithCompletion:^(NSArray<DJIFlyZoneInformation *> * _Nullable infos, NSError * _Nullable error) {
        WeakReturn(target);
        if (nil == error && nil != infos) {
            [target updateFlyZoneOverlayWithInfos:infos];
        }else{
            if (target.mapOverlays.count > 0) {
                [target removeMapOverlays:target.mapOverlays];
            }
            if (target.flyZones.count > 0) {
                [target.flyZones removeAllObjects];
            }
        }
    }];
}

- (void)updateFlyZoneOverlayWithInfos:(NSArray<DJIFlyZoneInformation*> *_Nullable)flyZoneInfos
{
    if (flyZoneInfos && flyZoneInfos.count > 0) {
        dispatch_block_t block = ^{
            NSMutableArray *overlays = [NSMutableArray array];
            NSMutableArray *flyZones = [NSMutableArray array];
            
            for (int i = 0; i < flyZoneInfos.count; i++) {
                DJIFlyZoneInformation *flyZoneLimitInfo = [flyZoneInfos objectAtIndex:i];
                DJILimitSpaceOverlay *aOverlay = nil;
                for (DJILimitSpaceOverlay *aMapOverlay in _mapOverlays) {
                    if (aMapOverlay.limitSpaceInfo.flyZoneID == flyZoneLimitInfo.flyZoneID &&
                        (aMapOverlay.limitSpaceInfo.subFlyZones.count == flyZoneLimitInfo.subFlyZones.count)) {
                        aOverlay = aMapOverlay;
                        break;
                    }
                }
                if (!aOverlay) {
                    aOverlay = [[DJILimitSpaceOverlay alloc] initWithLimitSpace:flyZoneLimitInfo];
                }
                [overlays addObject:aOverlay];
                [flyZones addObject:flyZoneLimitInfo];
            }
            [self removeMapOverlays:self.mapOverlays];
            [self.flyZones removeAllObjects];
            [self addMapOverlays:overlays];
            [self.flyZones addObjectsFromArray:flyZones];
        };
        if ([NSThread currentThread].isMainThread) {
            block();
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                block();
            });
        }
    }
}


- (void) updateCustomUnlockZone
{
	WeakRef(target);
	NSArray* zones = [[DJISDKManager flyZoneManager] getCustomUnlockZonesFromAircraft];
	
	if (zones.count > 0) {
		[[DJISDKManager flyZoneManager] getEnabledCustomUnlockZoneWithCompletion:^(DJICustomUnlockZone * _Nullable zone, NSError * _Nullable error) {
			if (!error && zone) {
				[target updateCustomUnlockWithSpaces:@[zone] andEnabledZone:zone];
			}
		}];
	} else {
		if (target.customUnlockOverlays.count > 0) {
			[target removeMapOverlays:self.customUnlockOverlays];
		}
	}
}

- (void)updateCustomUnlockWithSpaces:(NSArray<DJICustomUnlockZone *> * _Nullable)spaceInfos andEnabledZone:(DJICustomUnlockZone *)enabledZone
{
	if (spaceInfos && spaceInfos.count > 0) {
		NSMutableArray *overlays = [NSMutableArray array];
		
		for (int i = 0; i < spaceInfos.count; i++) {
			DJICustomUnlockZone *flyZoneLimitInfo = [spaceInfos objectAtIndex:i];
			DJICustomUnlockOverlay *aOverlay = nil;
			for (DJICustomUnlockOverlay *aCustomUnlockOverlay in _customUnlockOverlays) {
				if (aCustomUnlockOverlay.customUnlockInformation.ID == flyZoneLimitInfo.ID) {
					//&& aCustomUnlockOverlay.CustomUnlockInformation.license.enabled == flyZoneLimitInfo.license.enabled) {
					aOverlay = aCustomUnlockOverlay;
					break;
				}
			}
			if (!aOverlay) {
				//TODO
				BOOL enabled = [flyZoneLimitInfo isEqual:enabledZone];
				aOverlay = [[DJICustomUnlockOverlay alloc] initWithCustomUnlockInformation:flyZoneLimitInfo andEnabled:enabled];
			}
			[overlays addObject:aOverlay];
		}
		[self removeCustomUnlockOverlays:self.customUnlockOverlays];
		[self addCustomUnlockOverlays:overlays];
	}
}

- (void)setMapType:(MKMapType)mapType
{
    self.mapView.mapType = mapType;
}

- (void)addMapOverlays:(NSArray *)objects
{
    if (objects.count <= 0) {
        return;
    }
    NSMutableArray *overlays = [NSMutableArray array];
    for (DJIMapOverlay *aMapOverlay in objects) {
        for (id<MKOverlay> aOverlay in aMapOverlay.subOverlays) {
            [overlays addObject:aOverlay];
        }
    }
    
    if ([NSThread isMainThread]) {
        [self.mapOverlays addObjectsFromArray:objects];
        [self.mapView addOverlays:overlays];
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.mapOverlays addObjectsFromArray:objects];
            [self.mapView addOverlays:overlays];
        });
    }
}

- (void)removeMapOverlays:(NSArray *)objects
{
    if (objects.count <= 0) {
        return;
    }
    NSMutableArray *overlays = [NSMutableArray array];
    for (DJIMapOverlay *aMapOverlay in objects) {
        for (id<MKOverlay> aOverlay in aMapOverlay.subOverlays) {
            [overlays addObject:aOverlay];
        }
    }
    if ([NSThread isMainThread]) {
        [self.mapOverlays removeObjectsInArray:objects];
        [self.mapView removeOverlays:overlays];
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.mapOverlays removeObjectsInArray:objects];
            [self.mapView removeOverlays:overlays];
        });
    }
}

- (void)addCustomUnlockOverlays:(NSArray *)objects
{
	if (objects.count <= 0) {
		return;
	}
	NSMutableArray *overlays = [NSMutableArray array];
	for (DJIMapOverlay *aMapOverlay in objects) {
		for (id<MKOverlay> aOverlay in aMapOverlay.subOverlays) {
			[overlays addObject:aOverlay];
		}
	}
	
	if ([NSThread isMainThread]) {
		[self.customUnlockOverlays addObjectsFromArray:objects];
		[self.mapView addOverlays:overlays];
	} else {
		dispatch_sync(dispatch_get_main_queue(), ^{
			[self.customUnlockOverlays addObjectsFromArray:objects];
			[self.mapView addOverlays:overlays];
		});
	}
}

- (void)removeCustomUnlockOverlays:(NSArray *)objects
{
	if (objects.count <= 0) {
		return;
	}
	NSMutableArray *overlays = [NSMutableArray array];
	for (DJIMapOverlay *aMapOverlay in objects) {
		for (id<MKOverlay> aOverlay in aMapOverlay.subOverlays) {
			[overlays addObject:aOverlay];
		}
	}
	if ([NSThread isMainThread]) {
		[self.customUnlockOverlays removeObjectsInArray:objects];
		[self.mapView removeOverlays:overlays];
	} else {
		dispatch_sync(dispatch_get_main_queue(), ^{
			[self.customUnlockOverlays removeObjectsInArray:objects];
			[self.mapView removeOverlays:overlays];
		});
	}
}

- (void)refreshMapViewRegion
{
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(_aircraftCoordinate, 500, 500);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:adjustedRegion animated:YES];
}

@end
