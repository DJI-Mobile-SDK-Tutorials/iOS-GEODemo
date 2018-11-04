//
//  DJIAircraftAnnotationView.h
//  DJIGeoSample
//
//  Copyright © 2015 DJI. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface DJIAircraftAnnotationView : MKAnnotationView

- (instancetype)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier;

-(void)updateHeading:(float)heading;

@end
