//
//  DJIGeoGroupInfoViewController.m
//  DJIGeoSample
//
//  Copyright © 2018 DJI. All rights reserved.
//

#import "DJIGeoGroupInfoViewController.h"
#import <DJISDK/DJISDK.h>
#import "DJIScrollView.h"

@interface DJIGeoGroupInfoViewController () 

@property (weak, nonatomic) IBOutlet UITableView *selfUnlockingTable;
@property (weak, nonatomic) IBOutlet UITableView *customUnlockingTable;
@property(nonatomic, strong) DJIScrollView *flyZoneInfoView;

@end

@implementation DJIGeoGroupInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.flyZoneInfoView = [DJIScrollView viewWithViewController:self];
    self.flyZoneInfoView.hidden = YES;
    [self.flyZoneInfoView setDefaultSize];
    
	[self.selfUnlockingTable reloadData];
	[self.customUnlockingTable reloadData];

}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
	if ([tableView isEqual:self.selfUnlockingTable]) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SelfUnlockingCell"];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"SelfUnlockingCell"];
		}
		DJIFlyZoneInformation *zone = self.unlockedZoneGroup.selfUnlockedFlyZones[indexPath.row];
		cell.textLabel.text = zone.name;
		cell.detailTextLabel.text = [NSString stringWithFormat:@"AreaID:%tu, Lat: %f, Long: %f",zone.flyZoneID, zone.center.latitude, zone.center.longitude];
		return cell;
		
	} else if ([tableView isEqual:self.customUnlockingTable]) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomUnlockCell"];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CustomUnlockCell"];
		}
		DJICustomUnlockZone *zone = self.unlockedZoneGroup.customUnlockZones[indexPath.row];
		cell.textLabel.text = zone.name;
		cell.detailTextLabel.text = [NSString stringWithFormat:@"UnlockID:%tu, Lat: %f, Long: %f",zone.ID, zone.center.latitude, zone.center.longitude];
		return cell;
	}
	return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if ([tableView isEqual:self.selfUnlockingTable]) {
		return self.unlockedZoneGroup.selfUnlockedFlyZones.count;
	} else if ([tableView isEqual:self.customUnlockingTable]) {
		return self.unlockedZoneGroup.customUnlockZones.count;
	}
	return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.flyZoneInfoView.hidden = NO;
    [self.flyZoneInfoView show];
    
    if ([tableView isEqual:self.selfUnlockingTable]) {
        DJIFlyZoneInformation *information = self.unlockedZoneGroup.selfUnlockedFlyZones[indexPath.row];
        [self.flyZoneInfoView writeStatus:[self formatFlyZoneInformtionString:information]];

    } else if ([tableView isEqual:self.customUnlockingTable]) {
        DJICustomUnlockZone *customUnlockZone = self.unlockedZoneGroup.customUnlockZones[indexPath.row];
        [self.flyZoneInfoView writeStatus:[self formatCustomUnlockZoneInformtionString:customUnlockZone]];
    }
}

- (NSString*)formatCustomUnlockZoneInformtionString:(DJICustomUnlockZone*)customUnlockZone
{
    NSMutableString* infoString = [[NSMutableString alloc] init];
    if (customUnlockZone) {
        [infoString appendString:[NSString stringWithFormat:@"ID:%lu\n", (unsigned long)customUnlockZone.ID]];
        [infoString appendString:[NSString stringWithFormat:@"Name:%@\n", customUnlockZone.name]];
        [infoString appendString:[NSString stringWithFormat:@"Coordinate:(%f,%f)\n", customUnlockZone.center.latitude, customUnlockZone.center.longitude]];
        [infoString appendString:[NSString stringWithFormat:@"Radius:%f\n", customUnlockZone.radius]];
        [infoString appendString:[NSString stringWithFormat:@"StartTime:%@, EndTime:%@\n", customUnlockZone.startTime, customUnlockZone.endTime]];
        [infoString appendString:[NSString stringWithFormat:@"isExpired:%@\n", customUnlockZone.isExpired ? @"YES":@"NO"]];
    }
    NSString *result = [NSString stringWithString:infoString];
    return result;
}

- (NSString*)formatFlyZoneInformtionString:(DJIFlyZoneInformation*)information
{
    NSMutableString* infoString = [[NSMutableString alloc] init];
    if (information) {
        [infoString appendString:[NSString stringWithFormat:@"ID:%lu\n", (unsigned long)information.flyZoneID]];
        [infoString appendString:[NSString stringWithFormat:@"Name:%@\n", information.name]];
        [infoString appendString:[NSString stringWithFormat:@"Coordinate:(%f,%f)\n", information.center.latitude, information.center.longitude]];
        [infoString appendString:[NSString stringWithFormat:@"Radius:%f\n", information.radius]];
        [infoString appendString:[NSString stringWithFormat:@"StartTime:%@, EndTime:%@\n", information.startTime, information.endTime]];
        [infoString appendString:[NSString stringWithFormat:@"unlockStartTime:%@, unlockEndTime:%@\n", information.unlockStartTime, information.unlockEndTime]];
        [infoString appendString:[NSString stringWithFormat:@"GEOZoneType:%d\n", information.type]];
        [infoString appendString:[NSString stringWithFormat:@"FlyZoneType:%@\n", information.shape == DJIFlyZoneShapeCylinder ? @"Cylinder" : @"Cone"]];
        [infoString appendString:[NSString stringWithFormat:@"FlyZoneCategory:%@\n",[self getFlyZoneCategoryString:information.category]]];
        
        if (information.subFlyZones.count > 0) {
            NSString* subInfoString = [self formatSubFlyZoneInformtionString:information.subFlyZones];
            [infoString appendString:subInfoString];
        }
    }
    NSString *result = [NSString stringWithString:infoString];
    return result;
}

- (NSString*)formatSubFlyZoneInformtionString:(NSArray<DJISubFlyZoneInformation *> *)subFlyZoneInformations
{
    NSMutableString *subInfoString = [NSMutableString string];
    for (DJISubFlyZoneInformation* subInformation in subFlyZoneInformations) {
        [subInfoString appendString:@"-----------------\n"];
        [subInfoString appendString:[NSString stringWithFormat:@"SubAreaID:%@\n", @(subInformation.areaID)]];
        [subInfoString appendString:[NSString stringWithFormat:@"Graphic:%@\n", DJISubFlyZoneShapeCylinder == subInformation.shape ? @"Circle": @"Polygon"]];
        [subInfoString appendString:[NSString stringWithFormat:@"MaximumFlightHeight:%ld\n", (long)subInformation.maximumFlightHeight]];
        [subInfoString appendString:[NSString stringWithFormat:@"Radius:%f\n", subInformation.radius]];
        [subInfoString appendString:[NSString stringWithFormat:@"Coordinate:(%f,%f)\n", subInformation.center.latitude, subInformation.center.longitude]];
        for (NSValue* point in subInformation.vertices) {
            CLLocationCoordinate2D coordinate = [point MKCoordinateValue];
            [subInfoString appendString:[NSString stringWithFormat:@"     (%f,%f)\n", coordinate.latitude, coordinate.longitude]];
        }
        [subInfoString appendString:@"-----------------\n"];
    }
    return subInfoString;
}

- (NSString*)getFlyZoneCategoryString:(DJIFlyZoneCategory)category
{
    switch (category) {
        case DJIFlyZoneCategoryWarning:
            return @"Waring";
        case DJIFlyZoneCategoryRestricted:
            return @"Restricted";
        case DJIFlyZoneCategoryAuthorization:
            return @"Authorization";
        case DJIFlyZoneCategoryEnhancedWarning:
            return @"EnhancedWarning";
        default:
            break;
    }
    return @"Unknown";
}


@end
