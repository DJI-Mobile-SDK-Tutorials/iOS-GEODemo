//
//  DJIGeoDemoViewController.m
//  DJIGeoSample
//
//  Copyright © 2016 DJI. All rights reserved.
//

#import "DJIGeoDemoViewController.h"
#import "DJIMapViewController.h"
#import <DJISDK/DJISDK.h>
#import "DemoUtility.h"
#import "DJIScrollView.h"

@interface DJIGeoDemoViewController ()<DJIFlyZoneDelegate, DJIFlightControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *logoutBtn;
@property (weak, nonatomic) IBOutlet UILabel *loginStateLabel;
@property (weak, nonatomic) IBOutlet UIButton *unlockBtn;
@property (weak, nonatomic) IBOutlet UILabel *flyZoneStatusLabel;
@property (weak, nonatomic) IBOutlet UIButton *getUnlockButton;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIView *pickerContainerView;

@property (nonatomic, strong) DJIMapViewController* djiMapViewController;
@property (nonatomic, strong) NSTimer* updateLoginStateTimer;
@property (nonatomic, strong) NSTimer* updateFlyZoneDataTimer;
@property (nonatomic, strong) NSMutableArray<NSNumber *> * unlockFlyZoneIDs;
@property (nonatomic, strong) NSMutableArray<DJIFlyZoneInformation *> * unlockedFlyZoneInfos;
@property (nonatomic, strong) DJIFlyZoneInformation *selectedFlyZoneInfo;
@property (nonatomic) BOOL isUnlockEnable;
@property (weak, nonatomic) IBOutlet UITableView *showFlyZoneMessageTableView;
@property(nonatomic, strong) DJIScrollView *flyZoneInfoView;
@property (weak, nonatomic) IBOutlet UIButton *customUnlockButton;

@end

@implementation DJIGeoDemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"DJI GEO Demo";
    
    [self.pickerContainerView setHidden:YES];

    DJIAircraft* aircraft = [DemoUtility fetchAircraft];
    if (aircraft == nil) return;
    
    aircraft.flightController.delegate = self;
    [[DJISDKManager flyZoneManager] setDelegate:self];
    
    [self initUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    DJIAircraft* aircraft = [DemoUtility fetchAircraft];
    if (aircraft != nil) {
        
        [aircraft.flightController.simulator setFlyZoneLimitationEnabled:YES withCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowResult(@"setFlyZoneLimitationEnabled failed:%@", error.description);
            } else {
                NSLog(@"setFlyZoneLimitationEnabled success");
            }
        }];
        
//        if (!DJISDKManager.flyZoneManager.isCustomUnlockZoneSupported) {
//            self.customUnlockButton.hidden = NO;
//        } else {
//            self.customUnlockButton.hidden = YES;
//        }
    }
    
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
            ShowResult(@"setFlyZoneLimitationEnabled failed:%@", error.description);
        } else {
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
    self.unlockedFlyZoneInfos = [[NSMutableArray alloc] init];
    self.flyZoneInfoView = [DJIScrollView viewWithViewController:self];
    self.flyZoneInfoView.hidden = YES;
    [self.flyZoneInfoView setDefaultSize];
}

#pragma mark IBAction Methods

- (IBAction)onLoginButtonClicked:(id)sender
{
    [[DJISDKManager userAccountManager] logIntoDJIUserAccountWithAuthorizationRequired:YES withCompletion:^(DJIUserAccountState status, NSError * _Nullable error) {
        if (error) {
            ShowResult([NSString stringWithFormat:@"GEO Login Error: %@", error.description]);
            
        } else {
            ShowResult(@"GEO Login Success");
        }
    }];
}

- (IBAction)onLogoutButtonClicked:(id)sender {
    
    [[DJISDKManager userAccountManager] logOutOfDJIUserAccountWithCompletion:^(NSError * _Nullable error) {
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
    
	WeakRef(target);
	
	[[DJISDKManager flyZoneManager] getUnlockedFlyZonesForAircraftWithCompletion:^(NSArray<DJIFlyZoneInformation *> * _Nullable infos, NSError * _Nullable error) {
		
		WeakReturn(target);
		if (error) {
			ShowResult(@"Get Unlock Error:%@", error.description);
		} else {
			NSString* unlockInfo = [NSString stringWithFormat:@"unlock zone count = %lu\n", infos.count];
			
			if ([target.unlockedFlyZoneInfos count] > 0) {
				[target.unlockedFlyZoneInfos removeAllObjects];
			}
			[target.unlockedFlyZoneInfos addObjectsFromArray:infos];
			
			for (DJIFlyZoneInformation* info in infos) {
				unlockInfo = [unlockInfo stringByAppendingString:[NSString stringWithFormat:@"ID:%lu Name:%@ Begin:%@ end:%@\n", (unsigned long)info.flyZoneID, info.name, info.unlockStartTime, info.unlockEndTime]];
			};
			ShowResult(@"%@", unlockInfo);
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
                    [target.djiMapViewController refreshMapViewRegion];
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
    
    WeakRef(target);
    [flightController.simulator stopWithCompletion:^(NSError * _Nullable error) {
        WeakReturn(target);
        if (error) {
            ShowResult(@"Stop simulator error:%@", error.description);
        }else
        {
            ShowResult(@"Stop simulator success");

        }
    }];
}

- (IBAction)enableUnlocking:(id)sender {
    
    [self.pickerContainerView setHidden:NO];
    [self.pickerView reloadAllComponents];
}

- (IBAction)conformButtonAction:(id)sender {

    if (self.selectedFlyZoneInfo) {
        [self.selectedFlyZoneInfo setUnlockingEnabled:self.isUnlockEnable withCompletion:^(NSError * _Nullable error) {
            
            if (error) {
                ShowResult(@"Set unlocking enabled failed %@", error.description);
            }else
            {
                ShowResult(@"Set unlocking enabled success");
            }
        }];
    }
    
}

- (IBAction)cancelButtonAction:(id)sender {
    
    [self.pickerContainerView setHidden:YES];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    NSInteger rowNum = 0;
    
    if (component == 0) {
        rowNum = [self.unlockedFlyZoneInfos count];
    } else if (component == 1){
        rowNum = 2;
    }
    return rowNum;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSString *title = @"";
    
    if (component == 0) {
      
        DJIFlyZoneInformation *infoObject = [self.unlockedFlyZoneInfos objectAtIndex:row];
        title = [NSString stringWithFormat:@"%lu", (unsigned long)infoObject.flyZoneID];
        
    } else if (component == 1) {
        
        if (row == 0) {
            title = @"YES";
        } else {
            title = @"NO";
        }
    }
    
    return title;
}

#pragma mark - UIPickerViewDelegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    if (component == 0) {
        if ([self.unlockedFlyZoneInfos count] > row) {
            self.selectedFlyZoneInfo = [self.unlockedFlyZoneInfos objectAtIndex:row];
        }
    } else if (component == 1) {
        self.isUnlockEnable = [pickerView selectedRowInComponent:1] == 0 ? YES: NO;
    }
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
		[[DJISDKManager flyZoneManager] unlockFlyZones:target.unlockFlyZoneIDs withCompletion:^(NSError * _Nullable error) {
			
			[target.unlockFlyZoneIDs removeAllObjects];
			
			if (error) {
				ShowResult(@"unlock fly zones failed%@", error.description);
			} else {
				[[DJISDKManager flyZoneManager] getUnlockedFlyZonesForAircraftWithCompletion:^(NSArray<DJIFlyZoneInformation *> * _Nullable infos, NSError * _Nullable error) {
					if (error) {
						ShowResult(@"get unlocked fly zone failed:%@", error.description);
					} else {
						NSString* resultMessage = [NSString stringWithFormat:@"unlock zone: %tu ", [infos count]];
						for (int i = 0; i < infos.count; ++i) {
							DJIFlyZoneInformation* info = [infos objectAtIndex:i];
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
    
	DJIUserAccountState state = [DJISDKManager userAccountManager].userAccountState;
    NSString* stateString = @"DJIUserAccountStatusUnknown";
    
    switch (state) {
        case DJIUserAccountStateNotLoggedIn:
            stateString = @"DJIUserAccountStatusNotLoggin";
            break;
        case DJIUserAccountStateNotAuthorized:
            stateString = @"DJIUserAccountStatusNotVerified";
            break;
        case DJIUserAccountStateAuthorized:
            stateString = @"DJIUserAccountStatusSuccessful";
            break;
        case DJIUserAccountStateTokenOutOfDate:
            stateString = @"DJIUserAccountStatusTokenOutOfDate";
            break;
        default:
            break;
    }
    
    [self.loginStateLabel setText:[NSString stringWithFormat:@"%@", stateString]];
}

- (void)onUpdateFlyZoneInfo
{
    [self.showFlyZoneMessageTableView reloadData];
}

#pragma mark - DJIFlyZoneDelegate Method

-(void)flyZoneManager:(DJIFlyZoneManager *)manager didUpdateFlyZoneState:(DJIFlyZoneState)state
{
    NSString* flyZoneStatusString = @"Unknown";
    switch (state) {
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

- (void)flyZoneManager:(nonnull DJIFlyZoneManager *)manager didUpdateBasicDatabaseUpgradeProgress:(float)progress andError:(NSError * _Nullable)error {
    
}

#pragma mark - DJIFlightControllerDelegate Method

- (void)flightController:(DJIFlightController *)fc didUpdateState:(DJIFlightControllerState *)state
{
    if (CLLocationCoordinate2DIsValid(state.aircraftLocation.coordinate)) {
        double heading = RADIAN(state.attitude.yaw);
        [self.djiMapViewController updateAircraftLocation:state.aircraftLocation.coordinate withHeading:heading];
    }
}

#pragma mark - UITableViewDelgete

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.djiMapViewController.flyZones.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"flyzone-id"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"flyzone-id"];
    }
    
    DJIFlyZoneInformation* flyZoneInfo = self.djiMapViewController.flyZones[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%lu:%@:%@", (unsigned long)flyZoneInfo.flyZoneID, @(flyZoneInfo.category), flyZoneInfo.name];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    return cell;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.flyZoneInfoView.hidden = NO;
    [self.flyZoneInfoView show];
    DJIFlyZoneInformation* information = self.djiMapViewController.flyZones[indexPath.row];
    [self.flyZoneInfoView writeStatus:[self formatFlyZoneInformtionString:information]];
}

@end
