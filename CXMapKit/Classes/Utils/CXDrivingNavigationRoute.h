//
//  CXDrivingNavigationRoute.h
//  Pods
//
//  Created by wshaolin on 2017/5/30.
//
//

#import <CoreLocation/CoreLocation.h>
#import "CXPointAnnotation.h"
#import <AMapSearchKit/AMapCommonObj.h>
#import <AMapNaviKit/AMapNaviKit.h>
#import "CXMapRouteRequestOption.h"

@class CXDrivingNavigationRouteLineConfig;

@interface CXDrivingNavigationRoute : NSObject

@property (nonatomic, strong, readonly) NSArray<MAPolyline *> *polylines;
@property (nonatomic, strong, readonly) NSArray<CXPointAnnotation *> *annotations;
@property (nonatomic, strong, readonly) NSArray<UIColor *> *multiPolylineColors;

@property (nonatomic, strong, readonly) CXDrivingNavigationRouteLineConfig *lineConfig;

@property (nonatomic, assign, readonly) MAMapRect calculativeMapRect;
@property (nonatomic, assign) UIEdgeInsets edgePadding;

- (instancetype)initWithMapPath:(AMapPath *)mapPath;

- (instancetype)initWithMapPath:(AMapPath *)mapPath replenish:(BOOL)replenish;

- (instancetype)initWithCoordinates:(NSArray<NSValue *> *)coordinates;

- (instancetype)initWithNaviRoute:(AMapNaviRoute *)naviRoute;

@end

@interface CXDrivingNavigationRouteLineConfig : NSObject

@property (nonatomic, assign) CGFloat width; // 线宽
@property (nonatomic, strong) UIColor *color; // 线的颜色

+ (instancetype)defaultConfig;

@end

@interface AMapPath (CXMapKit)

@property (nonatomic, strong) CXMapRouteRequestOption *requestOption;

@end

@interface AMapNaviPoint (CXMapKit)

@property (nonatomic, assign, readonly) CLLocationCoordinate2D cx_coordinate;

@end
