//
//  DJIGeoUnlockingGroupViewController.m
//  DJIGeoSample
//
//  Created by DJI on 26/04/2018.
//  Copyright © 2018 DJI. All rights reserved.
//

#import "DJIGeoUnlockingGroupViewController.h"
#import "DJIGeoGroupInfoViewController.h"
#import <DJISDK/DJISDK.h>
#import "DemoUtility.h"

@interface DJIGeoUnlockingGroupViewController ()

@property (weak, nonatomic) IBOutlet UITableView *userUnlockingTableView;
@property (strong, nonatomic) NSArray <DJIUnlockedZoneGroup *> *unlockZoneGroups;

@end

@implementation DJIGeoUnlockingGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	[self loadUserUnlockGroupInfo];
}

- (void)loadUserUnlockGroupInfo {
	WeakRef(target);
	
	[[DJISDKManager flyZoneManager] reloadUnlockedZoneGroupsFromServerWithCompletion:^(NSError * _Nullable error) {
		WeakReturn(target);
		if (!error) {
			[[DJISDKManager flyZoneManager] getLoadedUnlockedZoneGroupsWithCompletion:^(NSArray<DJIUnlockedZoneGroup *> * _Nullable groups, NSError * _Nullable error) {
				if (!error) {
					target.unlockZoneGroups = groups;
					[target.userUnlockingTableView reloadData];
				}
			}];
		}
	}];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserUnlockingGroup"];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UserUnlockingGroup"];
	}
	DJIUnlockedZoneGroup *group = self.unlockZoneGroups[indexPath.row];
	cell.textLabel.text = group.SN;
	cell.detailTextLabel.text = [NSString stringWithFormat:@"self-unlocking: %tu, custom-unlocking: %tu", group.selfUnlockedFlyZones.count, group.customUnlockZones.count];
	
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.unlockZoneGroups.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	DJIUnlockedZoneGroup *unlockedZoneGroup = self.unlockZoneGroups[indexPath.row];
	UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
	DJIGeoGroupInfoViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"DJIGeoGroupInfoViewController"];
	vc.unlockedZoneGroup = unlockedZoneGroup;
	[self.navigationController pushViewController:vc animated:YES];
}

@end
