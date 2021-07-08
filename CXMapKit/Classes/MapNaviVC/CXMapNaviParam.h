//
//  CXMapNaviParam.h
//  CXMapKit
//
//  Created by lcc on 2018/6/29.
//

#import <CoreLocation/CoreLocation.h>
#import <AMapNaviKit/AMapNaviKit.h>
#import "CXMapRouteRequestOption.h"
#import "CXMapKitDefines.h"

@interface CXMapNaviParam : NSObject

@property (nonatomic, assign) CLLocationCoordinate2D startCoordinate;
@property (nonatomic, assign) CLLocationCoordinate2D endCoordinate;
@property (nonatomic, assign) CXMapNaviType naviType;
@property (nonatomic, strong) CXMapRoutePreference *preference;
@property (nonatomic, strong) AMapNaviRoute *naviRoute;
@property (nonatomic, assign, readonly) AMapNaviDrivingStrategy strategy;

- (instancetype)initWithStartCoordinate:(CLLocationCoordinate2D)startCoordinate
                          endCoordinate:(CLLocationCoordinate2D)endCoordinate
                              naviRoute:(AMapNaviRoute *)naviRoute
                             preference:(CXMapRoutePreference *)preference
                               naviType:(CXMapNaviType)naviType;

@end

CX_MAPKIT_EXTERN AMapNaviDrivingStrategy CXMapNaviDrivingStrategyFromPreference(BOOL multiple, CXMapRoutePreference *preference);

CX_MAPKIT_EXTERN AMapNaviPoint *CXMapNaviPointFromCoordinate(CLLocationCoordinate2D coordinate);
