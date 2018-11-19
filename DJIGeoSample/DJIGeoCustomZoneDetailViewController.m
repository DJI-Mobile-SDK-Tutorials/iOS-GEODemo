//
//  DJIGeoCustomZoneDetailViewController.m
//  DJIGeoSample
//
//  Copyright © 2018 DJI. All rights reserved.
//

#import "DJIGeoCustomZoneDetailViewController.h"
#import "DemoUtility.h"

@interface DJIGeoCustomZoneDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *idLabel;
@property (weak, nonatomic) IBOutlet UILabel *latitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *longitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *radiusLabel;
@property (weak, nonatomic) IBOutlet UILabel *startLabel;
@property (weak, nonatomic) IBOutlet UILabel *endLabel;
@property (weak, nonatomic) IBOutlet UILabel *expiredLabel;
@property (weak, nonatomic) IBOutlet UIButton *enableZoneButton;
@property (strong, nonatomic) DJICustomUnlockZone *enabledCustomUnlockZone;
@end

@implementation DJIGeoCustomZoneDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.nameLabel.text = self.customUnlockZone.name;
    self.idLabel.text = [NSString stringWithFormat:@"%lu",self.customUnlockZone.ID];
    self.latitudeLabel.text = [NSString stringWithFormat:@"%f",self.customUnlockZone.center.latitude];
    self.longitudeLabel.text = [NSString stringWithFormat:@"%f",self.customUnlockZone.center.longitude];
    self.radiusLabel.text = [NSString stringWithFormat:@"%f",self.customUnlockZone.radius];
    self.startLabel.text = [NSString stringWithFormat:@"%@",self.customUnlockZone.startTime];
    self.endLabel.text = [NSString stringWithFormat:@"%@",self.customUnlockZone.endTime];
    if (self.customUnlockZone.isExpired) {
        self.enableZoneButton.titleLabel.text = @"Expired";
        self.expiredLabel.text = @"Yes";
        self.enableZoneButton.enabled = NO;
    } else {
        self.expiredLabel.text = @"No";
        WeakRef(target);
        [[DJISDKManager flyZoneManager] getEnabledCustomUnlockZoneWithCompletion:^(DJICustomUnlockZone * _Nullable zone, NSError * _Nullable error) {
            WeakReturn(target);
            if (!error) {
                if (zone && zone.ID == target.customUnlockZone.ID) {
					[target.enableZoneButton setTitle:@"Disable" forState:UIControlStateNormal];
                    target.enabledCustomUnlockZone = zone;
                } else {
					[target.enableZoneButton setTitle:@"Enable Zone" forState:UIControlStateNormal];
                }
                target.enableZoneButton.enabled = YES;
            } else {
                ShowResult(@"get enabled custom ulock zone failed:%@", error.description);
            }
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)enableZoneButtonPressed:(id)sender {
    WeakRef(target);
    if (self.enabledCustomUnlockZone) {
        [[DJISDKManager flyZoneManager] enableCustomUnlockZone:nil withCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowResult(@"Disable custom unlock zone failed:%@", error.description);
            } else {
				[target.enableZoneButton setTitle:@"Enable Zone" forState:UIControlStateNormal];
				target.enabledCustomUnlockZone = nil;
                ShowResult(@"Disable custom unlock zone succeed");
            }
        }];
    } else {
        [[DJISDKManager flyZoneManager] enableCustomUnlockZone:self.customUnlockZone withCompletion:^(NSError * _Nullable error) {
            WeakReturn(target);
            if (!error) {
				[target.enableZoneButton setTitle:@"Disable" forState:UIControlStateNormal];
                target.enabledCustomUnlockZone = self.customUnlockZone;
                ShowResult(@"Enable custom unlock zone success");
            } else {
                ShowResult(@"Enable custom unlock zone Error: %@",error.description);
            }
        }];
    }
}

@end
