//
//  CXLocationManager.m
//  Pods
//
//  Created by wshaolin on 2017/5/12.
//
//

#import "CXLocationManager.h"
#import <AMapLocationKit/AMapLocationKit.h>
#import <CXFoundation/CXFoundation.h>

@interface CXLocationManager()<AMapLocationManagerDelegate>{
    AMapLocationManager *_locationService;
    NSHashTable<id<CXLocationManagerDelegate>> *_delegates;
    BOOL _startUpdatingLocationAfterAuthorized;
}

@end

@implementation CXLocationManager

+ (instancetype)sharedManager{
    static CXLocationManager *_locationManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _locationManager = [[self alloc] init];
    });
    
    return _locationManager;
}

- (instancetype)init{
    if(self = [super init]){
        _delegates = [NSHashTable weakObjectsHashTable];
        _locationService = [[AMapLocationManager alloc] init];
        _locationService.delegate = self;
        _locationService.reGeocodeTimeout = 30.0;
        
        self.distanceFilter = 5.0;
        self.reverseGeoCodeForLocationEnabled = YES;
        
        [NSNotificationCenter addObserver:self
                                   action:@selector(applicationDidBecomeActiveNotification:)
                                     name:UIApplicationDidBecomeActiveNotification];
    }
    
    return self;
}

- (void)reloadLocation{
    [_locationService requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *reGeocode, NSError *error) {
        [self didReloadLocation:location reGeocode:reGeocode error:error];
    }];
}

- (void)didReloadLocation:(CLLocation *)location reGeocode:(AMapLocationReGeocode *)reGeocode error:(NSError *)error{
    if(location && reGeocode){
        [self amapLocationManager:_locationService didUpdateLocation:location reGeocode:reGeocode];
        return;
    }
    
    [_delegates.allObjects enumerateObjectsUsingBlock:^(id<CXLocationManagerDelegate> delegate, NSUInteger idx, BOOL *stop) {
        if([delegate respondsToSelector:@selector(locationManager:didReverseGeoCodeResult:)]){
            [delegate locationManager:self didReverseGeoCodeResult:self->_reverseGeoCodeResult];
        }
    }];
}

- (void)requestAuthorization:(void (^)(CLLocationManager *))block{
    if(!block){
        return;
    }
    
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    if(authorizationStatus != kCLAuthorizationStatusNotDetermined && authorizationStatus != kCLAuthorizationStatusRestricted){
        block(nil);
        return;
    }
    
    CLLocationManager *locationManager = [_locationService valueForKey:@"locationManager"];
    block(locationManager);
}

- (void)applicationDidBecomeActiveNotification:(NSNotification *)notification{
    _locationService.locatingWithReGeocode = self.isReverseGeoCodeForLocationEnabled;
}

- (void)startUpdatingLocation{
    [self requestAuthorization:^(CLLocationManager *locationManager) {
        if(locationManager){
            _startUpdatingLocationAfterAuthorized = true;
            [locationManager requestAlwaysAuthorization];
        }else{
            [_locationService startUpdatingLocation];
        }
    }];
}

- (void)stopUpdatingLocation{
    [_locationService stopUpdatingLocation];
}

- (void)startUpdatingHeading{
    [_locationService startUpdatingHeading];
}

- (void)stopUpdatingHeading{
    [_locationService stopUpdatingHeading];
}

- (void)bind:(id<CXLocationManagerDelegate>)delegate{
    if(!delegate || [_delegates containsObject:delegate]){
        return;
    }
    
    [_delegates addObject:delegate];
}

- (void)unbind:(id<CXLocationManagerDelegate>)delegate{
    if(!delegate || ![_delegates containsObject:delegate]){
        return;
    }
    
    [_delegates removeObject:delegate];
}

- (void)setDistanceFilter:(CLLocationDistance)distanceFilter{
    _locationService.distanceFilter = distanceFilter;
}

- (CLLocationDistance)distanceFilter{
    return _locationService.distanceFilter;
}

- (void)setDesiredAccuracy:(CLLocationAccuracy)desiredAccuracy{
    _locationService.desiredAccuracy = desiredAccuracy;
}

- (CLLocationAccuracy)desiredAccuracy{
    return _locationService.desiredAccuracy;
}

- (void)setPausesLocationUpdatesAutomatically:(BOOL)pausesLocationUpdatesAutomatically{
    _locationService.pausesLocationUpdatesAutomatically = pausesLocationUpdatesAutomatically;
}

- (BOOL)isPausesLocationUpdatesAutomatically{
    return _locationService.pausesLocationUpdatesAutomatically;
}

- (void)setAllowsBackgroundLocationUpdates:(BOOL)allowsBackgroundLocationUpdates{
    _locationService.allowsBackgroundLocationUpdates = allowsBackgroundLocationUpdates;
}

- (BOOL)isAllowsBackgroundLocationUpdates{
    return _locationService.allowsBackgroundLocationUpdates;
}

- (void)setReverseGeoCodeForLocationEnabled:(BOOL)reverseGeoCodeForLocationEnabled{
    _reverseGeoCodeForLocationEnabled = reverseGeoCodeForLocationEnabled;
    _locationService.locatingWithReGeocode = reverseGeoCodeForLocationEnabled;
}

#pragma mark - delegate

- (void)amapLocationManager:(AMapLocationManager *)manager didFailWithError:(NSError *)error{
    [_delegates.allObjects enumerateObjectsUsingBlock:^(id<CXLocationManagerDelegate> delegate, NSUInteger idx, BOOL *stop) {
        if([delegate respondsToSelector:@selector(locationManager:didFailWithError:)]){
            [delegate locationManager:self didFailWithError:error];
        }
    }];
}

- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location reGeocode:(AMapLocationReGeocode *)reGeocode{
    if(!location || !CXLocationCoordinate2DIsValid(location.coordinate)){
        return;
    }
    
    _location = location;
    [_delegates.allObjects enumerateObjectsUsingBlock:^(id<CXLocationManagerDelegate> delegate, NSUInteger idx, BOOL *stop) {
        if([delegate respondsToSelector:@selector(locationManager:didUpdateLocation:)]){
            [delegate locationManager:self didUpdateLocation:location];
        }
    }];
    
    if(!reGeocode){
        return;
    }
    
    _reverseGeoCodeResult = [[CXLocationReverseGeoCodeResult alloc] init];
    _reverseGeoCodeResult.formattedAddress = reGeocode.formattedAddress;
    _reverseGeoCodeResult.country = reGeocode.country;
    _reverseGeoCodeResult.province = reGeocode.province;
    _reverseGeoCodeResult.city = reGeocode.city;
    _reverseGeoCodeResult.district = reGeocode.district;
    _reverseGeoCodeResult.citycode = reGeocode.citycode;
    _reverseGeoCodeResult.adcode = reGeocode.adcode;
    _reverseGeoCodeResult.street = reGeocode.street;
    _reverseGeoCodeResult.number = reGeocode.number;
    _reverseGeoCodeResult.POIName = reGeocode.POIName;
    _reverseGeoCodeResult.AOIName = reGeocode.AOIName;
    _reverseGeoCodeResult.coordinate = location.coordinate;
    
    [_delegates.allObjects enumerateObjectsUsingBlock:^(id<CXLocationManagerDelegate> delegate, NSUInteger idx, BOOL *stop) {
        if([delegate respondsToSelector:@selector(locationManager:didReverseGeoCodeResult:)]){
            [delegate locationManager:self didReverseGeoCodeResult:self->_reverseGeoCodeResult];
        }
    }];
    
    _locationService.locatingWithReGeocode = NO;
}

- (void)amapLocationManager:(AMapLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if(_startUpdatingLocationAfterAuthorized &&
       (status == kCLAuthorizationStatusAuthorized ||
        status == kCLAuthorizationStatusAuthorizedWhenInUse ||
        status == kCLAuthorizationStatusAuthorizedAlways)){
        [_locationService startUpdatingLocation];
        _startUpdatingLocationAfterAuthorized = NO;
    }
    
    [_delegates.allObjects enumerateObjectsUsingBlock:^(id<CXLocationManagerDelegate> delegate, NSUInteger idx, BOOL *stop) {
        if([delegate respondsToSelector:@selector(locationManager:didChangeAuthorizationStatus:)]){
            [delegate locationManager:self didChangeAuthorizationStatus:status];
        }
    }];
}

- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateHeading:(CLHeading *)heading{
    [_delegates.allObjects enumerateObjectsUsingBlock:^(id<CXLocationManagerDelegate> delegate, NSUInteger idx, BOOL *stop) {
        if([delegate respondsToSelector:@selector(locationManager:didUpdateHeading:)]){
            [delegate locationManager:self didUpdateHeading:heading];
        }
    }];
}

@end

BOOL CXLocationCoordinate2DIsValid(CLLocationCoordinate2D coordinate){
    if(isnan(coordinate.latitude) || isnan(coordinate.longitude)){
        return NO;
    }
    
    if(fabs(coordinate.latitude) == 0.0 || fabs(coordinate.longitude) == 0.0){
        return NO;
    }
    
    return CLLocationCoordinate2DIsValid(coordinate);
}
