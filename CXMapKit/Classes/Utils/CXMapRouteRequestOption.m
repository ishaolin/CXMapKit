//
//  CXMapRouteRequestOption.m
//  Pods
//
//  Created by wshaolin on 2018/4/27.
//

#import "CXMapRouteRequestOption.h"
#import "CXMapNaviParam.h"

@implementation CXMapRouteRequestOption

- (instancetype)initWithStartPOIModel:(CXMapPOIModel *)startPOIModel
                          endPOIModel:(CXMapPOIModel *)endPOIModel
                             naviType:(CXMapNaviType)naviType
                           preference:(CXMapRoutePreference *)preference{
    if(self = [self initWithStartCoordinate:startPOIModel.coordinate
                              endCoordinate:endPOIModel.coordinate
                                   naviType:naviType
                                 preference:preference]){
        _originId = startPOIModel.identifier;
        _destinationId = endPOIModel.identifier;
    }
    
    return self;
}

- (instancetype)initWithStartCoordinate:(CLLocationCoordinate2D)startCoordinate
                          endCoordinate:(CLLocationCoordinate2D)endCoordinate
                               naviType:(CXMapNaviType)naviType
                             preference:(CXMapRoutePreference *)preference{
    if(self = [super init]){
        _startCoordinate = startCoordinate;
        _endCoordinate = endCoordinate;
        _naviType = naviType;
        _strategy = CXMapNaviDrivingStrategyFromPreference(YES, preference);
    }
    
    return self;
}

@end

@implementation CXMapRoutePreference

- (BOOL)isEqual:(id)object{
    if([object isKindOfClass:[CXMapRoutePreference class]]){
        return [self isEqualToPreference:(CXMapRoutePreference *)object];
    }
    
    return NO;
}

- (BOOL)isEqualToPreference:(CXMapRoutePreference *)preference{
    if(!preference){
        return NO;
    }
    
    if(self.avoidCongestion != preference.avoidCongestion){
        return NO;
    }
    
    if(self.avoidCost != preference.avoidCost){
        return NO;
    }
    
    if(self.avoidHighway != preference.avoidHighway){
        return NO;
    }
    
    if(self.prioritiseHighway != preference.prioritiseHighway){
        return NO;
    }
    
    return YES;
}

- (CXMapRoutePreference *)copyPreference{
    CXMapRoutePreference *preference = [[CXMapRoutePreference alloc] init];
    preference.avoidCongestion = self.avoidCongestion;
    preference.avoidCost = self.avoidCost;
    preference.avoidHighway = self.avoidHighway;
    preference.prioritiseHighway = self.prioritiseHighway;
    return preference;
}

@end
