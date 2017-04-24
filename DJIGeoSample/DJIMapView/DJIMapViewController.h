//
//  DJIMapViewController.h
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@class DJIMapViewController;

@interface DJIMapViewController : NSObject

@property (nonatomic, strong) NSMutableArray *flyZones;


- (id)initWithMap:(MKMapView*)mapView;

/**
 *  Update aircraft location and heading.
 *
 *  @param coordinate Aircraft location
 *  @param heading    Aircraft heading
 */
-(void)updateAircraftLocation:(CLLocationCoordinate2D)coordinate withHeading:(CGFloat)heading;

/**
 *  Refresh the map view region
 */
- (void)refreshMapViewRegion;

/**
 *  Update fly zones in the surrounding area of aircraft
 */
- (void)updateFlyZonesInSurroundingArea;


@end
