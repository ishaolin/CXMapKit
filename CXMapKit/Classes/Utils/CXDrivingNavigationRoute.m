//
//  CXDrivingNavigationRoute.m
//  Pods
//
//  Created by wshaolin on 2017/5/30.
//
//

#import "CXDrivingNavigationRoute.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import "CXLocationManager.h"
#import "CXMapRouteUtils.h"
#import "MAPolyline+CXMapExtensions.h"
#import <CXUIKit/CXUIKit.h>
#import <objc/runtime.h>
#import "AMapNaviRoute+CXMapEXtensions.h"

@interface CXDrivingNavigationRoute(){
    NSMutableArray<MAPolyline *> *_mutablePolylines;
    NSMutableArray<CXPointAnnotation *> *_mutableAnnotations;
}

@end

@implementation CXDrivingNavigationRoute

- (void)replenishPolylinesForStartCoordinate:(CLLocationCoordinate2D)startCoordinate
                               endCoordinate:(CLLocationCoordinate2D)endCoordinate{
    if(_mutablePolylines.count < 1){
        return;
    }
    
    MAPolyline *startDashPolyline = nil;
    MAPolyline *endDashPolyline = nil;
    
    if(CXLocationCoordinate2DIsValid(startCoordinate)){
        CLLocationCoordinate2D _endCoordinate = startCoordinate;
        MAPolyline *polyline = _mutablePolylines.firstObject;
        [polyline getCoordinates:&_endCoordinate range:NSMakeRange(0, 1)];
        startDashPolyline= [self replenishPolylineWithStartCoordinate:startCoordinate
                                                        endCoordinate:_endCoordinate];
        startDashPolyline.lineDashType = kMALineDashTypeDot;
    }
    
    if(CXLocationCoordinate2DIsValid(endCoordinate)){
        CLLocationCoordinate2D _startCoordinate = endCoordinate;
        MAPolyline *polyline = _mutablePolylines.lastObject;
        [polyline getCoordinates:&_startCoordinate range:NSMakeRange(polyline.pointCount - 1, 1)];
        endDashPolyline = [self replenishPolylineWithStartCoordinate:_startCoordinate
                                                       endCoordinate:endCoordinate];
        
        endDashPolyline.lineDashType = kMALineDashTypeDot;
    }
    
    if(startDashPolyline){
        [_mutablePolylines addObject:startDashPolyline];
    }
    
    if(endDashPolyline){
        [_mutablePolylines addObject:endDashPolyline];
    }
}

- (void)replenishPolylinesForPolyline:(MAPolyline *)polyline
                             nextStep:(AMapStep *)nextStep{
    CLLocationCoordinate2D endCoordinate;
    [polyline getCoordinates:&endCoordinate range:NSMakeRange(0, 1)];
    
    CLLocationCoordinate2D startCoordinate;
    MAPolyline *nextPolyline = [CXMapRouteUtils polylineForMapStep:nextStep];
    [nextPolyline getCoordinates:&startCoordinate range:NSMakeRange(nextPolyline.pointCount - 1, 1)];
    
    if(endCoordinate.latitude == startCoordinate.latitude &&
       endCoordinate.longitude == startCoordinate.longitude){
        return;
    }
    MAPolyline *dashPolyline = [self replenishPolylineWithStartCoordinate:startCoordinate
                                                            endCoordinate:endCoordinate];
    if(dashPolyline){
        [_mutablePolylines addObject:dashPolyline];
    }
}

- (MAPolyline *)replenishPolylineWithStartCoordinate:(CLLocationCoordinate2D)startCoordinate
                                       endCoordinate:(CLLocationCoordinate2D)endCoordinate{
    if(!CXLocationCoordinate2DIsValid(startCoordinate) || !CXLocationCoordinate2DIsValid(endCoordinate)){
        return nil;
    }
    
    if(MAMetersBetweenMapPoints(MAMapPointForCoordinate(startCoordinate), MAMapPointForCoordinate(endCoordinate)) < 5.0){
        return nil;
    }
    
    CLLocationCoordinate2D coordinate[2];
    coordinate[0] = startCoordinate;
    coordinate[1] = endCoordinate;
    return [MAPolyline polylineWithCoordinates:coordinate count:2];
}

- (MAPolyline *)multiPolylineWithNaviRoute:(AMapNaviRoute *)naviRoute polylineColors:(NSArray<UIColor *> **)polylineColors{
    if(!naviRoute){
        return nil;
    }
    
    NSMutableArray<UIColor *> *mutablePolylineColors = [NSMutableArray array];
    NSMutableArray<AMapNaviPoint *> *naviPoints = [NSMutableArray array];
    NSMutableArray<NSNumber *> *indexes = [NSMutableArray array];
    NSArray<AMapNaviTrafficStatus *> *statuses = naviRoute.routeTrafficStatuses;
    
    __block NSUInteger index = 0;
    __block CLLocationDistance totalLength = 0;
    __block NSUInteger statusIndex = 0;
    __block CLLocationDistance trafficLength = 0;
    
    [naviRoute.routeCoordinates enumerateObjectsUsingBlock:^(AMapNaviPoint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        index = idx;
        AMapNaviTrafficStatus *status = nil;
        
        if(idx == 0){
            [naviPoints addObject:obj];
            status = statuses.firstObject;
            trafficLength = status.length;
            [mutablePolylineColors addObject:[CXMapRouteUtils trafficColorForNaviRouteStatus:status.status]];
            return;
        }
        
        AMapNaviPoint *naviPoint = naviRoute.routeCoordinates[idx - 1];
        MAMapPoint mapPoint1 = MAMapPointForCoordinate(naviPoint.cx_coordinate);
        MAMapPoint mapPoint2 = MAMapPointForCoordinate(obj.cx_coordinate);
        CLLocationDistance distance = MAMetersBetweenMapPoints(mapPoint1, mapPoint2);
        
        if(totalLength + distance < trafficLength){
            [naviPoints addObject:obj];
            totalLength += distance;
            return;
        }
        
        if(totalLength + distance == trafficLength){
            [naviPoints addObject:obj];
            [indexes addObject:@(naviPoints.count - 1)];
        }else{
            double rate = (distance == 0 ? 0 : ((trafficLength - totalLength) / distance));
            AMapNaviPoint *extrnPoint = [self calculateNaviPoint:naviPoint endPoint:obj rate:MAX(MIN(rate, 1.0), 0)];
            if(extrnPoint){
                // 额外插入一个点
                [naviPoints addObject:extrnPoint];
                [indexes addObject:@(naviPoints.count - 1)];
                [naviPoints addObject:obj];
            }else{
                [naviPoints addObject:obj];
                [indexes addObject:@(naviPoints.count - 1)];
            }
        }
        
        totalLength = totalLength + distance - trafficLength;
        if(++statusIndex >= statuses.count){
            *stop = YES;
            return;
        }
        
        status = statuses[statusIndex];
        trafficLength = status.length;
        [mutablePolylineColors addObject:[CXMapRouteUtils trafficColorForNaviRouteStatus:status.status]];
    }];
    
    while(index < naviRoute.routeCoordinates.count){
        [naviPoints addObject:naviRoute.routeCoordinates[index]];
        index ++;
    }
    
    CLLocationCoordinate2D *coordinates = (CLLocationCoordinate2D *)malloc(naviPoints.count * sizeof(CLLocationCoordinate2D));
    [naviPoints enumerateObjectsUsingBlock:^(AMapNaviPoint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        coordinates[idx] = obj.cx_coordinate;
    }];
    
    MAMultiPolyline *polyline = [MAMultiPolyline polylineWithCoordinates:coordinates
                                                                   count:naviPoints.count
                                                        drawStyleIndexes:indexes];
    free(coordinates);
    coordinates = NULL;
    
    if(polylineColors){
        *polylineColors = [mutablePolylineColors copy];
    }
    
    return polyline;
}

- (MAPolyline *)multiPolylineWithMapPath:(AMapPath *)mapPath polylineColors:(NSArray<UIColor *> **)polylineColors{
    if(!mapPath){
        return nil;
    }
    
    NSMutableArray<UIColor *> *mutablePolylineColors = [NSMutableArray array];
    NSMutableArray<NSValue *> *allCoordinates = [NSMutableArray array];
    NSMutableArray<NSValue *> *coordinates = [NSMutableArray array];
    NSMutableArray<NSNumber *> *indexes = [NSMutableArray array];
    NSMutableArray<AMapTMC *> *tmcs = [NSMutableArray array];
    
    [mapPath.steps enumerateObjectsUsingBlock:^(AMapStep * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [allCoordinates addObjectsFromArray:[CXMapRouteUtils coordinatesForPolyline:obj.polyline]];
        [tmcs addObjectsFromArray:obj.tmcs];
    }];
    
    NSMutableArray<AMapTMC *> *_tmcs = [NSMutableArray array];
    __block NSString *status = tmcs.firstObject.status;
    __block double tmcDistance = 0;
    [tmcs enumerateObjectsUsingBlock:^(AMapTMC * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([status isEqualToString:obj.status]){
            tmcDistance += obj.distance;
            return;
        }
        
        AMapTMC *tmc = [[AMapTMC alloc] init];
        tmc.status = status;
        tmc.distance = tmcDistance;
        [_tmcs addObject:tmc];
        
        tmcDistance = obj.distance;
        status = obj.status;
    }];
    AMapTMC *tmc = [[AMapTMC alloc] init];
    tmc.status = status;
    tmc.distance = tmcDistance;
    [_tmcs addObject:tmc];
    tmcs = _tmcs;
    
    __block NSUInteger index = 0;
    __block NSUInteger totalLength = 0;
    __block NSUInteger statusIndex = 0;
    __block NSUInteger trafficLength = 0;
    [allCoordinates enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        index = idx;
        AMapTMC *tmc = nil;
        
        if(idx == 0){
            [coordinates addObject:obj];
            [indexes addObject:@(idx)];
            
            tmc = tmcs.firstObject;
            trafficLength = tmc.distance;
            [mutablePolylineColors addObject:[CXMapRouteUtils trafficColorForStatus:tmc.status]];
            return;
        }
        
        NSValue *coordinate1 = allCoordinates[idx - 1];
        MAMapPoint mapPoint1 = MAMapPointForCoordinate(coordinate1.MACoordinateValue);
        MAMapPoint mapPoint2 = MAMapPointForCoordinate(obj.MACoordinateValue);
        CLLocationDistance distance = MAMetersBetweenMapPoints(mapPoint1, mapPoint2);
        
        if(totalLength + distance < trafficLength){
            [coordinates addObject:obj];
            totalLength += distance;
            return;
        }
        
        if(totalLength + distance == trafficLength){
            [coordinates addObject:obj];
            [indexes addObject:@(coordinates.count - 1)];
        }else{
            double rate = (distance == 0 ? 0 : ((trafficLength - totalLength) / distance));
            NSValue *extrnPoint = [self calculateValuePoint:coordinate1
                                                   endPoint:obj
                                                       rate:MAX(MIN(rate, 1.0), 0)];
            
            if(extrnPoint){
                // 额外插入一个点
                [coordinates addObject:extrnPoint];
                [indexes addObject:@(coordinates.count - 1)];
                [coordinates addObject:obj];
            }else{
                [coordinates addObject:obj];
                [indexes addObject:@(coordinates.count - 1)];
            }
        }
        
        totalLength = totalLength + distance - trafficLength;
        
        if(++ statusIndex >= tmcs.count){
            *stop = YES;
            return;
        }
        
        tmc = tmcs[statusIndex];
        trafficLength = tmc.distance;
        [mutablePolylineColors addObject:[CXMapRouteUtils trafficColorForStatus:tmc.status]];
    }];
    
    // 将最后一个点对齐到路径终点
    if(index > 0 && index < allCoordinates.count){
        while(index < allCoordinates.count){
            [coordinates addObject:allCoordinates[index]];
            index ++;
        }
        
        [indexes removeLastObject];
        [indexes addObject:@(coordinates.count - 1)];
    }
    
    NSUInteger count = coordinates.count;
    CLLocationCoordinate2D *_coordinates = (CLLocationCoordinate2D *)malloc(count * sizeof(CLLocationCoordinate2D));
    
    [coordinates enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        _coordinates[idx] = obj.MACoordinateValue;
    }];
    
    MAMultiPolyline *polyline = [MAMultiPolyline polylineWithCoordinates:_coordinates
                                                                   count:count
                                                        drawStyleIndexes:indexes];
    free(_coordinates);
    _coordinates = NULL;
    
    if(polylineColors){
        *polylineColors = [mutablePolylineColors copy];
    }
    
    return polyline;
}

- (NSValue *)calculateValuePoint:(NSValue *)startPoint
                        endPoint:(NSValue *)endPoint
                            rate:(double)rate{
    CLLocationCoordinate2D coordinate = [self calculateCoordinate:startPoint.MACoordinateValue enCoordinate:endPoint.MACoordinateValue rate:rate];
    if(CLLocationCoordinate2DIsValid(coordinate)){
        return [NSValue valueWithMACoordinate:coordinate];
    }
    
    return nil;
}

- (AMapNaviPoint *)calculateNaviPoint:(AMapNaviPoint *)startPoint
                             endPoint:(AMapNaviPoint *)endPoint
                                 rate:(double)rate{
    CLLocationCoordinate2D coordinate = [self calculateCoordinate:startPoint.cx_coordinate enCoordinate:endPoint.cx_coordinate rate:rate];
    if(CLLocationCoordinate2DIsValid(coordinate)){
        return [AMapNaviPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    }
    
    return nil;
}

- (CLLocationCoordinate2D)calculateCoordinate:(CLLocationCoordinate2D)startCoordinate
                                 enCoordinate:(CLLocationCoordinate2D)enCoordinate
                                         rate:(double)rate{
    if(rate > 1.0 || rate < 0){
        return kCLLocationCoordinate2DInvalid;
    }
    
    MAMapPoint startPoint = MAMapPointForCoordinate(startCoordinate);
    MAMapPoint endPoint = MAMapPointForCoordinate(enCoordinate);
    
    double latitudeDelta = (endPoint.y - startPoint.y) * rate;
    double longitudeDelta = (endPoint.x - startPoint.x) * rate;
    
    MAMapPoint mapPoint = MAMapPointMake(startPoint.x + longitudeDelta, startPoint.y + latitudeDelta);
    return MACoordinateForMapPoint(mapPoint);
}

- (instancetype)initWithMapPath:(AMapPath *)mapPath{
    return [self initWithMapPath:mapPath replenish:NO];
}

- (instancetype)initWithMapPath:(AMapPath *)mapPath replenish:(BOOL)replenish{
    if(CXArrayIsEmpty(mapPath.steps)){
        return nil;
    }
    
    if(self = [super init]){
        _mutablePolylines = [NSMutableArray array];
        _mutableAnnotations = [NSMutableArray array];
        _lineConfig = [CXDrivingNavigationRouteLineConfig defaultConfig];
        
        if(mapPath.requestOption.isShowTraffic){
            NSArray<UIColor *> *polylineColors = nil;
            MAPolyline *polyline = [self multiPolylineWithMapPath:mapPath
                                                   polylineColors:&polylineColors];
            if(polyline){
                [_mutablePolylines addObject:polyline];
                _multiPolylineColors = polylineColors;
            }
        }else{
            [mapPath.steps enumerateObjectsUsingBlock:^(AMapStep * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                MAPolyline *polyline = [CXMapRouteUtils polylineForMapStep:obj];
                if(!polyline){
                    return;
                }
                
                [self->_mutablePolylines addObject:polyline];
                
                if(idx == 0){
                    return;
                }
                
                [self replenishPolylinesForPolyline:polyline nextStep:mapPath.steps[idx - 1]];
            }];
        }
        
        [self handleAnnotationWithStartCoordinate:mapPath.requestOption.startCoordinate
                                    endCoordinate:mapPath.requestOption.endCoordinate
                                      routeOption:mapPath.requestOption];
        
        if(replenish){
            // 补充起点和终点的虚线
            [self replenishPolylinesForStartCoordinate:mapPath.requestOption.startCoordinate
                                         endCoordinate:mapPath.requestOption.endCoordinate];
        }
        
        _calculativeMapRect = [CXMapRouteUtils mapRectForOverlays:self.polylines];
    }
    
    return self;
}

- (instancetype)initWithCoordinates:(NSArray<NSValue *> *)coordinates{
    if(!coordinates || coordinates.count < 2){
        return nil;
    }
    
    if(self = [super init]){
        _mutablePolylines = [NSMutableArray array];
        _mutableAnnotations = [NSMutableArray array];
        
        [self handleAnnotationWithStartCoordinate:[coordinates.firstObject MACoordinateValue]
                                    endCoordinate:[coordinates.lastObject MACoordinateValue]
                                      routeOption:nil];
        
        _lineConfig = [CXDrivingNavigationRouteLineConfig defaultConfig];
        [_mutablePolylines addObject:[CXMapRouteUtils polylineForCoordinates:coordinates]];
        _calculativeMapRect = [CXMapRouteUtils mapRectForOverlays:self.polylines];
    }
    
    return self;
}

- (instancetype)initWithNaviRoute:(AMapNaviRoute *)naviRoute{
    if(self = [super init]){
        _mutablePolylines = [NSMutableArray array];
        _mutableAnnotations = [NSMutableArray array];
        _lineConfig = [CXDrivingNavigationRouteLineConfig defaultConfig];
        
        if(naviRoute.requestOption.isShowTraffic){
            NSArray<UIColor *> *polylineColors = nil;
            MAPolyline *polyline = [self multiPolylineWithNaviRoute:naviRoute polylineColors:&polylineColors];
            if(polyline){
                [_mutablePolylines addObject:polyline];
                _multiPolylineColors = polylineColors;
            }
        }else{
            MAPolyline *polyline = [CXMapRouteUtils polylineForNaviPoints:naviRoute.routeCoordinates];
            [_mutablePolylines addObject:polyline];
        }
        
        [self handleAnnotationWithStartNaviPoint:naviRoute.routeStartPoint
                                    endNaviPoint:naviRoute.routeEndPoint
                                     routeOption:naviRoute.requestOption];
        
        _calculativeMapRect = [CXMapRouteUtils mapRectForOverlays:self.polylines];
    }
    
    return self;
}

- (void)handleAnnotationWithStartNaviPoint:(AMapNaviPoint *)startNaviPoint
                              endNaviPoint:(AMapNaviPoint *)endNaviPoint
                               routeOption:(CXMapRouteRequestOption *)routeOption{
    [self handleAnnotationWithStartCoordinate:startNaviPoint.cx_coordinate
                                endCoordinate:endNaviPoint.cx_coordinate
                                  routeOption:routeOption];
}

- (void)handleAnnotationWithStartCoordinate:(CLLocationCoordinate2D)startCoordinate
                              endCoordinate:(CLLocationCoordinate2D)endCoordinate
                                routeOption:(CXMapRouteRequestOption *)routeOption{
    CXPointAnnotation *startAnnotation = nil;
    if(routeOption.startAnnotationBlock){
        startAnnotation = routeOption.startAnnotationBlock(startCoordinate);
    }else{
        startAnnotation = [[CXPointAnnotation alloc] initWithCoordinate:startCoordinate image: CX_MAPKIT_IMAGE(@"map_annotation_start")];
        startAnnotation.enabled = NO;
        startAnnotation.centerOffset = CGPointMake(0, -18.0);
    }
    if(startAnnotation){
        [_mutableAnnotations addObject:startAnnotation];
    }
    
    CXPointAnnotation *endAnnotation = nil;
    if(routeOption.endAnnotationBlock){
        endAnnotation = routeOption.endAnnotationBlock(endCoordinate);
    }else{
        endAnnotation = [[CXPointAnnotation alloc] initWithCoordinate:endCoordinate image: CX_MAPKIT_IMAGE(@"map_annotation_end")];
        endAnnotation.enabled = NO;
        endAnnotation.centerOffset = CGPointMake(0, -18.0);
    }
    
    if(endAnnotation){
        [_mutableAnnotations addObject:endAnnotation];
    }
}

- (NSArray<MAPolyline *> *)polylines{
    return [_mutablePolylines copy];
}

- (NSArray<CXPointAnnotation *> *)annotations{
    return [_mutableAnnotations copy];
}

@end

@implementation CXDrivingNavigationRouteLineConfig

+ (instancetype)defaultConfig{
    CXDrivingNavigationRouteLineConfig *config = [[CXDrivingNavigationRouteLineConfig alloc] init];
    config.width = 12.0;
    config.color = CXHexIColor(0x67DC98);
    
    return config;
}

@end

@implementation AMapPath (CXMapRouteExtensions)

- (void)setRequestOption:(CXMapRouteRequestOption *)requestOption{
    objc_setAssociatedObject(self, @selector(requestOption), requestOption, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CXMapRouteRequestOption *)requestOption{
    return objc_getAssociatedObject(self, _cmd);
}

@end

@implementation AMapNaviPoint (CXMapRouteExtensions)

- (CLLocationCoordinate2D)cx_coordinate{
    return CLLocationCoordinate2DMake(self.latitude, self.longitude);
}

@end
