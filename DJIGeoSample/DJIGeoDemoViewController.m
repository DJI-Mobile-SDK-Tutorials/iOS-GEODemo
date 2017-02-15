//
//  DJIGeoDemoViewController.m
//  DJIGeoSample
//
//  Created by DJI on 4/7/2016.
//  Copyright © 2016 DJI. All rights reserved.
//

#import "DJIGeoDemoViewController.h"
#import "DJIMapViewController.h"
#import <DJISDK/DJISDK.h>
#import "DemoUtility.h"

@interface DJIGeoDemoViewController ()<DJIFlyZoneDelegate, DJIFlightControllerDelegate, DJISimulatorDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *logoutBtn;
@property (weak, nonatomic) IBOutlet UILabel *loginStateLabel;
@property (weak, nonatomic) IBOutlet UIButton *unlockBtn;
@property (weak, nonatomic) IBOutlet UILabel *flyZoneStatusLabel;
@property (weak, nonatomic) IBOutlet UITextView *flyZoneDataTextView;
@property (weak, nonatomic) IBOutlet UIButton *getUnlockButton;
@property (weak, nonatomic) IBOutlet UIButton *enableGEOButton;

@property (nonatomic, strong) DJIMapViewController* djiMapViewController;
@property (nonatomic, strong) NSTimer* updateLoginStateTimer;
@property (nonatomic, strong) NSTimer* updateFlyZoneDataTimer;
@property (nonatomic, strong) NSMutableArray<NSNumber *> * unlockFlyZoneIDs;
@property (nonatomic, readwrite) BOOL isGEOSystemEnabled;

@end

@implementation DJIGeoDemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"DJI GEO Demo";

    DJIAircraft* aircraft = [DemoUtility fetchAircraft];
    if (aircraft == nil) return;
    
    aircraft.flightController.delegate = self;
    aircraft.flightController.simulator.delegate = self;
    [[DJIFlyZoneManager sharedInstance] setDelegate:self];
    
    [self initUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    DJIAircraft* aircraft = [DemoUtility fetchAircraft];
    if (aircraft != nil) {
        
        [aircraft.flightController.simulator setFlyZoneLimitationEnabled:YES withCompletion:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"setFlyZoneLimitationEnabled failed");
            }else
            {
                NSLog(@"setFlyZoneLimitationEnabled success");
            }
        }];

    }
    
    WeakRef(target);
    
    [[DJIFlyZoneManager sharedInstance] getGEOSystemEnabled:^(BOOL enabled, NSError * _Nullable error) {
        
        WeakReturn(target);
        if (error) {
            ShowResult(@"Get GEOEnable Status Error:%@", error.description);
        } else {
            [target setEnableGEOButtonText:enabled];
        }
    }];
    
    self.updateLoginStateTimer = [NSTimer scheduledTimerWithTimeInterval:4.0f target:self selector:@selector(onUpdateLoginState) userInfo:nil repeats:YES];
    self.updateFlyZoneDataTimer = [NSTimer scheduledTimerWithTimeInterval:4.0f target:self selector:@selector(onUpdateFlyZoneInfo) userInfo:nil repeats:YES];
    
    [self.djiMapViewController updateFlyZonesInSurroundingArea];
    
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    DJIAircraft* aircraft = [DemoUtility fetchAircraft];
    
    [aircraft.flightController.simulator setFlyZoneLimitationEnabled:NO withCompletion:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"setFlyZoneLimitationEnabled failed");
        }else
        {
            NSLog(@"setFlyZoneLimitationEnabled success");
        }
    }];

    if (self.updateLoginStateTimer)
        self.updateLoginStateTimer = nil;
    if (self.updateFlyZoneDataTimer)
        self.updateFlyZoneDataTimer = nil;
}

- (void)initUI
{
    self.title = @"DJI GEO Demo";

    self.djiMapViewController = [[DJIMapViewController alloc] initWithMap:self.mapView];
    self.unlockFlyZoneIDs = [[NSMutableArray alloc] init];
    self.isGEOSystemEnabled = NO;
}

- (void) setEnableGEOButtonText:(BOOL)enabled
{
    self.isGEOSystemEnabled = enabled;
    
    if (enabled) {
        [self.enableGEOButton setTitle:@"DisableGEO" forState:UIControlStateNormal];
    } else {
        [self.enableGEOButton setTitle:@"EnableGEO" forState:UIControlStateNormal];
    }
}

#pragma mark IBAction Methods

- (IBAction)onLoginButtonClicked:(id)sender
{
    [[DJIFlyZoneManager sharedInstance] logIntoDJIUserAccountWithCompletion:^(DJIUserAccountStatus status, NSError * _Nullable error) {
        if (error) {
            ShowResult([NSString stringWithFormat:@"GEO Login Error: %@", error.description]);
            
        } else {
            ShowResult(@"GEO Login Success");
        }
    }];
}

- (IBAction)onLogoutButtonClicked:(id)sender {
    
    [[DJIFlyZoneManager sharedInstance] logOutOfDJIUserAccountWithCompletion:^(NSError * _Nullable error) {
        if (error) {
            ShowResult(@"Login out error:%@", error.description);
        } else {
            ShowResult(@"Login out success");
        }
    }];
}

- (IBAction)onUnlockButtonClicked:(id)sender
{
    [self showFlyZoneIDInputView];
}

- (IBAction)onGetUnlockButtonClicked:(id)sender
{
    [[DJIFlyZoneManager sharedInstance] getUnlockedFlyZonesWithCompletion:^(NSArray<DJIGEOFlyZoneInformation *> * _Nullable infos, NSError * _Nullable error) {
        if (error) {
            ShowResult(@"Get Unlock Error:%@", error.description);
        } else {
            NSString* unlockInfo = [NSString stringWithFormat:@"unlock zone count = %lu\n", infos.count];
            
            for (DJIGEOFlyZoneInformation* info in infos) {
                unlockInfo = [unlockInfo stringByAppendingString:[NSString stringWithFormat:@"ID:%lu Name:%@ Begin:%@ end:%@\n", (unsigned long)info.flyZoneID, info.name, info.unlockStartTime, info.unlockEndTime]];
            };
            ShowResult(@"%@", unlockInfo);
        }
    }];
    
}

- (IBAction)onEnableGEOButtonClicked:(id)sender
{
    WeakRef(target);
    [[DJIFlyZoneManager sharedInstance] setGEOSystemEnabled:!self.isGEOSystemEnabled withCompletion:^(NSError * _Nullable error) {
        WeakReturn(target);

        if (error) {
            ShowResult(@"Set GEO Enable status error:%@", error.description);
        } else {
            
            [[DJIFlyZoneManager sharedInstance] getGEOSystemEnabled:^(BOOL enabled, NSError * _Nullable error) {
                if (error) {
                    ShowResult(@"Get GEOEnable Status Error:%@", error.description);
                } else {
                    ShowResult(@"Current GEO status is %@", enabled ? @"On" : @"Off");
                    [target setEnableGEOButtonText:enabled];
                }
                
            }];
        }
    }];
}

- (IBAction)onStartSimulatorButtonClicked:(id)sender {
    
    DJIFlightController* flightController = [DemoUtility fetchFlightController];
    if (!flightController) {
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"Input coordinate" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"latitude";
    }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"longitude";
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *startAction = [UIAlertAction actionWithTitle:@"Start" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UITextField* latTextField = alertController.textFields[0];
        UITextField* lngTextField = alertController.textFields[1];
        
        float latitude = [latTextField.text floatValue];
        float longitude = [lngTextField.text floatValue];
        
        if (latitude && longitude) {
            CLLocationCoordinate2D location = CLLocationCoordinate2DMake(latitude, longitude);
            WeakRef(target);
            
            [flightController.simulator startWithLocation:location updateFrequency:20 GPSSatellitesNumber:10 withCompletion:^(NSError * _Nullable error) {
                WeakReturn(target);
                if (error) {
                    ShowResult(@"Start simulator error:%@", error.description);
                } else {
                    ShowResult(@"Start simulator success");
                    [self.djiMapViewController refreshMapViewRegion];
                }
            }];
            
        }

    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:startAction];
    
    [self presentViewController:alertController animated:YES completion:nil];

}

- (IBAction)onStopSimulatorButtonClicked:(id)sender {
    
    DJIFlightController* flightController = [DemoUtility fetchFlightController];
    if (!flightController) {
        return;
    }
    
    [flightController.simulator stopWithCompletion:^(NSError * _Nullable error) {
        if (error) {
            ShowResult(@"Stop simulator error:%@", error.description);
        }else
        {
            ShowResult(@"Stop simulator success");
        }
    }];
}

- (void)showFlyZoneIDInputView
{
    WeakRef(target);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"Input ID" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Input";
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *continueAction = [UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UITextField* textField = alertController.textFields[0];
        NSString* content = textField.text;
        if (content) {
            int flyZoneID = [content intValue];
            [target.unlockFlyZoneIDs addObject:@(flyZoneID)];
        }
        [target showFlyZoneIDInputView];
    }];
    
    UIAlertAction *unlockAction = [UIAlertAction actionWithTitle:@"Unlock" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField* textField = alertController.textFields[0];
        NSString* content = textField.text;
        if (content) {
            int flyZoneID = [content intValue];
            [target.unlockFlyZoneIDs addObject:@(flyZoneID)];
        }
        [[DJIFlyZoneManager sharedInstance] unlockFlyZones:target.unlockFlyZoneIDs withCompletion:^(NSError * _Nullable error) {
            
            [target.unlockFlyZoneIDs removeAllObjects];

            if (error) {
                ShowResult(@"unlock fly zones failed%@", error.description);
            } else {
                                
                [[DJIFlyZoneManager sharedInstance] getUnlockedFlyZonesWithCompletion:^(NSArray<DJIGEOFlyZoneInformation *> * _Nullable infos, NSError * _Nullable error) {
                    if (error) {
                        ShowResult(@"get unlocked fly zone failed:%@", error.description);
                    } else {
                        NSString* resultMessage = [NSString stringWithFormat:@"unlock zone: %tu ", [infos count]];
                        for (int i = 0; i < infos.count; ++i) {
                            DJIGEOFlyZoneInformation* info = [infos objectAtIndex:i];
                            resultMessage = [resultMessage stringByAppendingString:[NSString stringWithFormat:@"\n ID:%lu Name:%@ Begin:%@ End:%@\n", (unsigned long)info.flyZoneID, info.name, info.unlockStartTime, info.unlockEndTime]];
                        }
                        ShowResult(resultMessage);
                    }
                }];
            }
        }];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:continueAction];
    [alertController addAction:unlockAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)onUpdateLoginState
{
    DJIUserAccountStatus state = [[DJIFlyZoneManager sharedInstance] getUserAccountStatus];
    NSString* stateString = @"DJIUserAccountStatusUnknown";
    
    switch (state) {
        case DJIUserAccountStatusNotLoggedIn:
            stateString = @"DJIUserAccountStatusNotLoggin";
            break;
        case DJIUserAccountStatusNotAuthorized:
            stateString = @"DJIUserAccountStatusNotVerified";
            break;
        case DJIUserAccountStatusAuthorized:
            stateString = @"DJIUserAccountStatusSuccessful";
            break;
        case DJIUserAccountStatusTokenOutOfDate:
            stateString = @"DJIUserAccountStatusTokenOutOfDate";
            break;
        default:
            break;
    }
    
    [self.loginStateLabel setText:[NSString stringWithFormat:@"%@", stateString]];
}

- (void)onUpdateFlyZoneInfo
{
    [self.flyZoneDataTextView setText:[self.djiMapViewController fetchUpdateFlyZoneInfo]];
}

#pragma mark - DJIFlyZoneDelegate Method

- (void)flyZoneManager:(DJIFlyZoneManager *)manager didUpdateFlyZoneStatus:(DJIFlyZoneState)status
{
    NSString* flyZoneStatusString = @"Unknown";
    switch (status) {
        case DJIFlyZoneStateClear:
            flyZoneStatusString = @"NoRestriction";
            break;
        case DJIFlyZoneStateInWarningZone:
            flyZoneStatusString = @"AlreadyInWarningArea";
            break;
        case DJIFlyZoneStateNearRestrictedZone:
            flyZoneStatusString = @"ApproachingRestrictedArea";
            break;
        case DJIFlyZoneStateInRestrictedZone:
            flyZoneStatusString = @"AlreadyInRestrictedArea";
            break;
        default:
            break;
    }
    
    [self.flyZoneStatusLabel setText:flyZoneStatusString];
}

#pragma mark - DJIFlightControllerDelegate Method

- (void)flightController:(DJIFlightController *)fc didUpdateState:(DJIFlightControllerState *)state
{
    if (CLLocationCoordinate2DIsValid(state.aircraftLocation)) {
        double heading = RADIAN(state.attitude.yaw);
        [self.djiMapViewController updateAircraftLocation:state.aircraftLocation withHeading:heading];
    }
}

#pragma mark - DJISimulatorDelegate method

- (void)simulator:(DJISimulator *)simulator updateSimulatorState:(DJISimulatorState *)state
{

}

@end
