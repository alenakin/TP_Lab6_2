//
//  ViewController.m
//  WeatherForecast
//
//  Created by Elena on 30.04.17.
//  Copyright © 2017 Elena. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *indicator;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *buttonShow;
@property (weak, nonatomic) IBOutlet UIButton *btGPS;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;

@end

@implementation ViewController

CLLocationManager *locationManager;

- (void)viewDidLoad {
    _buttonShow.layer.cornerRadius = 10;
    _btGPS.layer.cornerRadius = 10;
    locationManager = [[CLLocationManager alloc] init];
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)getCurrentLocatiion:(id)sender {
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter=kCLDistanceFilterNone;
    [locationManager requestWhenInUseAuthorization];
    NSLog(@"Meow");
    [locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Failed to Get Your Location" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {}];
    
    [errorAlert addAction:defaultAction];
    [self presentViewController:errorAlert animated:YES completion:nil];
    [locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        NSString *s = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&units=metric&APPID=02a8f8d24cadb133ebdb19e924e0f02e",
                       currentLocation.coordinate.latitude, currentLocation.coordinate.longitude];
        NSURL *url = [[NSURL alloc] initWithString:s];
        NSData *contents = [[NSData alloc] initWithContentsOfURL:url];
        if (contents == nil)
        {
            [[self cityLabel] setText:@"Can't find such city"];
        }
        else {
            NSDictionary *forcasting = [NSJSONSerialization JSONObjectWithData:contents options:NSJSONReadingMutableContainers error:nil];
            [[self cityLabel] setText:forcasting[@"name"]];
            [self setTemperature:[forcasting[@"main"][@"temp"] doubleValue]];
        }

    }
    [locationManager stopUpdatingLocation];
}

- (IBAction)refresh:(id)sender {
    NSLog(@"%@", [[self textField] text]);
    NSString *s = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?q=%@&type=accurate&units=metric&APPID=02a8f8d24cadb133ebdb19e924e0f02e",
                   [[self textField] text]];
    NSURL *url = [[NSURL alloc] initWithString:s];
    NSData *contents = [[NSData alloc] initWithContentsOfURL:url];
    if (contents == nil)
    {
        [[self cityLabel] setText:@"Can't find such city"];
        [[self indicator] setText:@""];
    }
    else {
        NSDictionary *forcasting = [NSJSONSerialization JSONObjectWithData:contents options:NSJSONReadingMutableContainers error:nil];
        [[self cityLabel] setText:forcasting[@"name"]];
        [[self textField] setText:@""];
        [self setTemperature:[forcasting[@"main"][@"temp"] doubleValue]];
    }
}

- (void)setTemperature:(double)temp {
    UIColor *tempColor;
    if (temp < -20)
        tempColor = [UIColor colorWithRed:127.0/255.0 green:156.0/255.0 blue:244.0/255.0 alpha:1];
    else if (temp < -10)
        tempColor = [UIColor colorWithRed:150.0/255.0 green:195.0/255.0 blue:244.0/255.0 alpha:1];
    else if (temp < 0)
        tempColor = [UIColor colorWithRed:150.0/255.0 green:208.0/255.0 blue:250.0/255.0 alpha:1];
    else if (temp < 10)
        tempColor = [UIColor colorWithRed:88.0/255.0 green:200.0/255.0 blue:219.0/255.0 alpha:1];
    else if (temp < 20)
        tempColor = [UIColor colorWithRed:119.0/255.0 green:222.0/255.0 blue:219.0/255.0 alpha:1];
    else if (temp < 30)
        tempColor = [UIColor colorWithRed:144.0/255.0 green:230.0/255.0 blue:183/255.0 alpha:1];
    else
        tempColor = [UIColor colorWithRed:253.0/255.0 green:185.0/255.0 blue:187.0/255.0 alpha:1];
    [[self indicator] setTextColor:tempColor];
    [[self indicator] setText:[NSString stringWithFormat:@"%.1f˚C", temp]];
}

@end
