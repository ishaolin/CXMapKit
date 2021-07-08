//
//  CXMapRouteUtils.h
//  Pods
//
//  Created by wshaolin on 2017/6/7.
//
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AMapNaviKit/AMapNaviKit.h>

@class MAPolyline;
@class AMapStep;

@interface CXMapRouteUtils : NSObject

+ (UIColor *)trafficColorForNaviRouteStatus:(AMapNaviRouteStatus)status;
+ (UIColor *)trafficColorForStatus:(NSString *)status;

+ (NSArray<NSValue *> *)coordinatesForPolyline:(NSString *)polyline;

+ (MAPolyline *)polylineForMapStep:(AMapStep *)mapStep;
+ (MAPolyline *)polylineForCoordinates:(NSArray<NSValue *> *)coordinates;
+ (MAPolyline *)polylineForNaviPoints:(NSArray<AMapNaviPoint *> *)naviPoints;

+ (MAMapRect)mapRectForOverlays:(NSArray *)overlays;
+ (MAMapRect)minMapRectForCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count;

@end
