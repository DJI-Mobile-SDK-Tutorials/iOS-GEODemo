//
//  DJIMapViewController.h
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@class DJIMapViewController;

@interface DJIMapViewController : NSObject

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

/**
 *  Get Update Fly Zone Info Strings
 **/
- (NSString *)fetchUpdateFlyZoneInfo;

@end
