//
//  DJIGeoCustomUnlockingViewController.m
//  DJIGeoSample
//
//  Copyright © 2018 DJI. All rights reserved.
//

#import "DJIGeoCustomUnlockingViewController.h"
#import <DJISDK/DJISDK.h>
#import "DemoUtility.h"
#import "DJIGeoCustomZoneDetailViewController.h"

@interface DJIGeoCustomUnlockingViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *customUnlockedZonesTableView;
@property (strong, nonatomic) NSArray <DJICustomUnlockZone *> *customUnlockZones;

@end

@implementation DJIGeoCustomUnlockingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadCustomUnlockInfo];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadCustomUnlockInfo {
	WeakRef(target);
	NSString* modeName = [DJISDKManager product].model;
	if ([modeName isEqualToString:DJIAircraftModelNameInspire1] ||
		[modeName isEqualToString:DJIAircraftModelNamePhantom3Professional] ||
		[modeName isEqualToString:DJIAircraftModelNameMatrice100]) {
		target.customUnlockZones = [[DJISDKManager flyZoneManager] getCustomUnlockZonesFromAircraft];
		[target.customUnlockedZonesTableView reloadData];
	} else {
		[[DJISDKManager flyZoneManager] syncUnlockedZoneGroupToAircraftWithCompletion:^(NSError * _Nullable error) {
			WeakReturn(target);
			if (!error) {
				target.customUnlockZones = [[DJISDKManager flyZoneManager] getCustomUnlockZonesFromAircraft];
				[target.customUnlockedZonesTableView reloadData];
			}
		}];
	}
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomUnlock"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CustomUnlock"];
    }
    DJICustomUnlockZone *zone = self.customUnlockZones[indexPath.row];
    cell.textLabel.text = zone.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Lat: %f, Long: %f",zone.center.latitude, zone.center.longitude];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.customUnlockZones.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DJICustomUnlockZone *selectedZone = self.customUnlockZones[indexPath.row];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DJIGeoCustomZoneDetailViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"DJIGeoCustomZoneDetailViewController"];
    vc.customUnlockZone = selectedZone;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
