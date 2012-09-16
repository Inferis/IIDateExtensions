//
//  ViewController.m
//  SolarInfo
//
//  Created by Tom Adriaenssen on 15/09/12.
//  Copyright (c) 2012 Inferis. All rights reserved.
//

#import "ViewController.h"
#import "NSDate+SolarInfo.h"
#import "NSDate+Formatting.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController () <CLLocationManagerDelegate>

@property (nonatomic, retain) IBOutlet UILabel* nowLabel;
@property (nonatomic, retain) IBOutlet UILabel* locationLabel;
@property (nonatomic, retain) IBOutlet UILabel* sunriseLabel;
@property (nonatomic, retain) IBOutlet UILabel* sunsetLabel;

@end

@implementation ViewController {
    CLLocationManager* _manager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _manager = [CLLocationManager new];
    _manager.delegate = self;
    _manager.distanceFilter = 50;
    [_manager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [self update:newLocation];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self update:_manager.location];
}

- (void)update:(CLLocation*)location {
    NSDate* now = [NSDate date];
    
    self.locationLabel.text = [NSString stringWithFormat:@"%1.4f,%1.4f", location.coordinate.latitude, location.coordinate.longitude];
    self.nowLabel.text = [now formatAs:@"dd-MM-yyyy HH:mm:ss"];
    self.sunriseLabel.text = [[now sunriseAtLatitude:location.coordinate.latitude longitude:location.coordinate.longitude] formatAs:@"dd-MM-yyyy HH:mm:ss"];
    self.sunsetLabel.text = [[now sunsetAtLatitude:location.coordinate.latitude longitude:location.coordinate.longitude] formatAs:@"dd-MM-yyyy HH:mm:ss"];
}

@end
