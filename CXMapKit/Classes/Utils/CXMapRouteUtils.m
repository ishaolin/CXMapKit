//
//  CXMapRouteUtils.m
//  Pods
//
//  Created by wshaolin on 2017/6/7.
//
//

#import "CXMapRouteUtils.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapNaviKit/AMapNaviHeaderHandler.h>
#import <CXUIKit/CXUIKit.h>

@implementation CXMapRouteUtils

+ (UIColor *)trafficColorForNaviRouteStatus:(AMapNaviRouteStatus)status{
    switch (status) {
        case AMapNaviRouteStatusSlow:
            return CXHexIColor(0xFBB446);
        case AMapNaviRouteStatusJam:
            return CXHexIColor(0xFF5F5F);
        case AMapNaviRouteStatusSeriousJam:
            return CXHexIColor(0xB40F0F);
        case AMapNaviRouteStatusUnknow:
        case AMapNaviRouteStatusSmooth:
        default:
            return CXHexIColor(0x3CD26E);
    }
}

+ (UIColor *)trafficColorForStatus:(NSString *)status{
    if(!status || ![status isKindOfClass:[NSString class]] || status.length == 0){
        return CXHexIColor(0x3CD26E);
    }
    
    static NSDictionary<NSString *, UIColor *> *_trafficColors = nil;
    if(!_trafficColors){
        _trafficColors = @{@"未知" : CXHexIColor(0x3CD26E),
                           @"畅通" : CXHexIColor(0x3CD26E),
                           @"缓行" : CXHexIColor(0xFBB446),
                           @"拥堵" : CXHexIColor(0xFF5F5F)};
    }
    
    return _trafficColors[status] ?: CXHexIColor(0x3CD26E);
}

+ (NSArray<NSValue *> *)coordinatesForPolyline:(NSString *)polyline{
    NSArray<NSString *> *components1 = [polyline componentsSeparatedByString:@";"];
    if(CXArrayIsEmpty(components1)){
        return nil;
    }
    
    NSMutableArray<NSValue *> *coordinates = [NSMutableArray array];
    
    [components1 enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray<NSString *> *components2 = [obj componentsSeparatedByString:@","];
        CLLocationCoordinate2D coordinate = kCLLocationCoordinate2DInvalid;
        if(components2.count == 2){
            coordinate = CLLocationCoordinate2DMake(components2[1].doubleValue, components2[0].doubleValue);
        }
        
        [coordinates addObject:[NSValue valueWithMACoordinate:coordinate]];
    }];
    
    return [coordinates copy];
}

+ (MAPolyline *)polylineForMapStep:(AMapStep *)mapStep{
    NSArray<NSValue *> *coordinates = [self coordinatesForPolyline:mapStep.polyline];
    return [self polylineForCoordinates:coordinates];
}

+ (MAPolyline *)polylineForCoordinates:(NSArray<NSValue *> *)coordinates{
    if(CXArrayIsEmpty(coordinates)){
        return nil;
    }
    
    CLLocationCoordinate2D *_coordinates = (CLLocationCoordinate2D*)malloc(coordinates.count * sizeof(CLLocationCoordinate2D));
    [coordinates enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        _coordinates[idx] = [obj MACoordinateValue];
    }];
    
    MAPolyline *polyline = [MAPolyline polylineWithCoordinates:_coordinates count:coordinates.count];
    
    free(_coordinates);
    _coordinates = NULL;
    
    return polyline;
}

+ (MAPolyline *)polylineForNaviPoints:(NSArray<AMapNaviPoint *> *)naviPoints{
    if(CXArrayIsEmpty(naviPoints)){
        return nil;
    }
    
    CLLocationCoordinate2D *_coordinates = (CLLocationCoordinate2D*)malloc(naviPoints.count * sizeof(CLLocationCoordinate2D));
    [naviPoints enumerateObjectsUsingBlock:^(AMapNaviPoint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        _coordinates[idx] = CLLocationCoordinate2DMake(obj.latitude, obj.longitude);
    }];
    
    MAPolyline *polyline = [MAPolyline polylineWithCoordinates:_coordinates count:naviPoints.count];
    
    free(_coordinates);
    _coordinates = NULL;
    
    return polyline;
}

+ (MAMapRect)mapRectForOverlays:(NSArray *)overlays{
    if(CXArrayIsEmpty(overlays)){
        return MAMapRectZero;
    }
    
    MAMapRect *mapRects = (MAMapRect *)malloc(overlays.count * sizeof(MAMapRect));
    [overlays enumerateObjectsUsingBlock:^(id<MAOverlay>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        mapRects[idx] = [obj boundingMapRect];
    }];
    
    MAMapRect mapRect = [self mapRectUnion:mapRects count:overlays.count];
    free(mapRects);
    mapRects = NULL;
    
    return mapRect;
}

+ (MAMapRect)unionMapRect:(MAMapRect)mapRect1 mapRect2:(MAMapRect)mapRect2{
    CGRect rect1 = CGRectMake(mapRect1.origin.x, mapRect1.origin.y, mapRect1.size.width, mapRect1.size.height);
    CGRect rect2 = CGRectMake(mapRect2.origin.x, mapRect2.origin.y, mapRect2.size.width, mapRect2.size.height);
    CGRect unionRect = CGRectUnion(rect1, rect2);
    return MAMapRectMake(unionRect.origin.x, unionRect.origin.y, unionRect.size.width, unionRect.size.height);
}

+ (MAMapRect)mapRectUnion:(MAMapRect *)mapRects count:(NSUInteger)count{
    if(mapRects == NULL || count == 0){
        return MAMapRectZero;
    }
    
    MAMapRect unionMapRect = mapRects[0];
    for(NSUInteger index = 1; index < count; index ++){
        unionMapRect = [self unionMapRect:unionMapRect mapRect2:mapRects[index]];
    }
    return unionMapRect;
}

+ (MAMapRect)minMapRectForCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count{
    if(coordinates == NULL || count == 0){
        return MAMapRectZero;
    }
    
    MAMapPoint mapPoint = MAMapPointForCoordinate(coordinates[0]);
    CGFloat minX = mapPoint.x;
    CGFloat minY = mapPoint.y;
    CGFloat maxX = minX;
    CGFloat maxY = minY;
    
    for(NSUInteger i = 1; i < count; i ++){
        MAMapPoint point = MAMapPointForCoordinate(coordinates[i]);
        if(point.x < minX) minX = point.x;
        if(point.x > maxX) maxX = point.x;
        if(point.y < minY) minY = point.y;
        if(point.y > maxY) maxY = point.y;
    }
    
    return MAMapRectMake(minX, minY, fabs(maxX - minX), fabs(maxY - minY));
}

@end
