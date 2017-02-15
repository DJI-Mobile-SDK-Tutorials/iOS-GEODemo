//
//  DJIMapView.m
//  Phantom3
//
//  Created by Jayce Yang on 14-4-10.
//  Copyright (c) 2014年 Jerome.zhang. All rights reserved.
//

#import "DJIMapViewController.h"
#import <DJISDK/DJISDK.h>
#import "DJIAircraftAnnotation.h"
#import "DJIAircraftAnnotationView.h"
#import "DJIFlyZoneCircle.h"
#import "DJIFlyZoneCircleView.h"
#import "DemoUtility.h"

@interface DJIMapViewController () <MKMapViewDelegate>

@property (nonatomic) CLLocationCoordinate2D aircraftCoordinate;
@property (weak, nonatomic) MKMapView *mapView;
@property (nonatomic, strong) DJIAircraftAnnotation* aircraftAnnotation;
@property (nonatomic, strong) NSMutableArray *flyZones;

@end

@implementation DJIMapViewController

- (id)initWithMap:(MKMapView*)mapView{
    if (nil != mapView) {
        self = [super init];
        if (self) {
            self.mapView = mapView;
            self.mapView.delegate = self;
            self.flyZones = [NSMutableArray array];
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
            [self updateFlyZonesInSurroundingArea];
        }
        else
        {
            [self.aircraftAnnotation setCoordinate:coordinate];
            DJIAircraftAnnotationView *annotationView = (DJIAircraftAnnotationView *)[_mapView viewForAnnotation:self.aircraftAnnotation];
            [annotationView updateHeading:heading];
            [self updateFlyZonesInSurroundingArea];
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
    }

    return nil;
}

#pragma mark - Update Fly Zones in Surrounding Area

-(void) updateFlyZonesInSurroundingArea
{
    [[DJIFlyZoneManager sharedInstance] getFlyZonesInSurroundingAreaWithCompletion:^(NSArray<DJIGEOFlyZoneInformation *> * _Nullable infos, NSError * _Nullable error) {
        if (nil == error && nil != infos) {
            [self updateFlyZoneOverlayWithInfos:infos];
        }
    }];
}

- (void)updateFlyZoneOverlayWithInfos:(NSArray<DJIGEOFlyZoneInformation*> *_Nullable)flyZoneInfos
{
    NSMutableArray *removeFlyZones = [NSMutableArray array];
    BOOL *flyZoneExistFlag = (BOOL *)malloc(sizeof(BOOL) * flyZoneInfos.count);
    bzero(flyZoneExistFlag, sizeof(BOOL) * flyZoneInfos.count);
    
    for (DJIFlyZoneCircle *flyZoneCircle in self.flyZones) {
        BOOL exist = NO;
        for (int i = 0; i < flyZoneInfos.count; i++) {
            DJIGEOFlyZoneInformation* flyZoneInfo = [flyZoneInfos objectAtIndex:i];
            CLLocationCoordinate2D flyZoneCoordinate = flyZoneInfo.coordinate;
            
            if (fabs(flyZoneCircle.flyZoneCoordinate.latitude - flyZoneCoordinate.latitude) < 0.0001 && fabs(flyZoneCircle.flyZoneCoordinate.longitude - flyZoneCoordinate.longitude) < 0.0001 && flyZoneInfo.category == flyZoneCircle.category) {
                exist = YES;
                flyZoneExistFlag[i] = YES;
                break;
            }
        }
        
        if (!exist) {
            [removeFlyZones addObject:flyZoneCircle];
            if ([NSThread currentThread].isMainThread) {
                [self.mapView removeOverlay:flyZoneCircle];
            } else {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self.mapView removeOverlay:flyZoneCircle];
                });
            }
        }
    }
    
    [self.flyZones removeObjectsInArray:removeFlyZones];
    
    if (flyZoneInfos && flyZoneInfos.count > 0) {
        
        WeakRef(target);
        dispatch_block_t block = ^{
            for (int i = 0; i < flyZoneInfos.count; i++) {
                if (!flyZoneExistFlag[i]) {
                    DJIGEOFlyZoneInformation *flyZoneInfo = [flyZoneInfos objectAtIndex:i];
                    CLLocationCoordinate2D flyZoneCoordinate = flyZoneInfo.coordinate;
                    CGFloat radius = flyZoneInfo.radius;
                    
                    CLLocationCoordinate2D coordinateInMap = flyZoneCoordinate;
                    DJIFlyZoneCircle *circle = [DJIFlyZoneCircle circleWithCenterCoordinate:coordinateInMap radius:radius];
                    circle.flyZoneRadius = radius;
                    circle.flyZoneCoordinate = flyZoneCoordinate;
                    circle.category = flyZoneInfo.category;
                    circle.flyZoneID = flyZoneInfo.flyZoneID;
                    circle.name = flyZoneInfo.name;
                    [target.flyZones addObject:circle];
                    [target.mapView addOverlay:circle];
                }
            }
            
            free(flyZoneExistFlag);
        };
        
        if ([NSThread currentThread].isMainThread) {
            block();
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                block();
            });
        }
    } else {
        free(flyZoneExistFlag);
    }
}

- (void)refreshMapViewRegion
{
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(_aircraftCoordinate, 500, 500);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:adjustedRegion animated:YES];
}

- (NSString *)fetchUpdateFlyZoneInfo
{
    NSString* flyZoneDataString = @"";
    if ([self.flyZones count] > 0) {
        flyZoneDataString = [NSString stringWithFormat:@"flyZones:%tu\n", [self.flyZones count]];
        for (int i = 0; i < self.flyZones.count; ++i) {
            DJIFlyZoneCircle* flyZoneArea = [self.flyZones objectAtIndex:i];
            NSString* flyZoneInfoString = [NSString stringWithFormat:@"\nID:%lu, level:%d\n Name:%@", (unsigned long)flyZoneArea.flyZoneID, flyZoneArea.category, flyZoneArea.name];
            flyZoneDataString = [flyZoneDataString stringByAppendingString:flyZoneInfoString];
        }
    }
    
    return flyZoneDataString;
}

@end
