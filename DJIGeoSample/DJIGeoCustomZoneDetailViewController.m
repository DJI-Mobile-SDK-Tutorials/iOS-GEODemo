//
//  DJIGeoCustomZoneDetailViewController.m
//  DJIGeoSample
//
//  Created by DJI on 3/1/18.
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
                    target.enableZoneButton.titleLabel.text = @"Disable";
                } else {
                    target.enableZoneButton.titleLabel.text = @"Enable Zone";
                }
                target.enableZoneButton.enabled = YES;
            } else {
                NSLog(@"Error: %@",error.description);
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
    [[DJISDKManager flyZoneManager] enableCustomUnlockZone:self.customUnlockZone withCompletion:^(NSError * _Nullable error) {
        WeakReturn(target);
        if (!error) {
            target.enableZoneButton.titleLabel.text = @"Disable";
        } else {
            NSLog(@"Error: %@",error.description);
        }
    }];
}

@end
