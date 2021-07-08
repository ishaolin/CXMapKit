//
//  CXMapNaviParam.m
//  CXMapKit
//
//  Created by lcc on 2018/6/29.
//

#import "CXMapNaviParam.h"
#import "CXLocationManager.h"

@implementation CXMapNaviParam

- (instancetype)initWithStartCoordinate:(CLLocationCoordinate2D)startCoordinate
                          endCoordinate:(CLLocationCoordinate2D)endCoordinate
                              naviRoute:(AMapNaviRoute *)naviRoute
                             preference:(CXMapRoutePreference *)preference
                               naviType:(CXMapNaviType)naviType{
    if(self = [super init]){
        _startCoordinate = startCoordinate;
        _endCoordinate = endCoordinate;
        _naviRoute = naviRoute;
        _naviType = naviType;
        
        self.preference = preference;
    }
    
    return self;
}

- (void)setPreference:(CXMapRoutePreference *)preference{
    _preference = preference;
    _strategy = CXMapNaviDrivingStrategyFromPreference(NO, preference);
}

@end

AMapNaviDrivingStrategy CXMapNaviDrivingStrategyFromPreference(BOOL multiple, CXMapRoutePreference *preference){
    if(!preference){
        return multiple ? AMapNaviDrivingStrategyMultipleDefault : AMapNaviDrivingStrategySingleDefault;
    }
    
    return ConvertDrivingPreferenceToDrivingStrategy(multiple,
                                                     preference.avoidCongestion,
                                                     preference.avoidHighway,
                                                     preference.avoidCost,
                                                     preference.prioritiseHighway);
}

AMapNaviPoint *CXMapNaviPointFromCoordinate(CLLocationCoordinate2D coordinate){
    if(CXLocationCoordinate2DIsValid(coordinate)){
        return [AMapNaviPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    }
    
    return nil;
}
