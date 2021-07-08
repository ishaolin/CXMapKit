//
//  CXRouteViewController.m
//  Pods
//
//  Created by wshaolin on 2017/11/22.
//

#import "CXRouteViewController.h"
#import <AMapNaviKit/AMapNaviKit.h>
#import "CXDrivingNavigationRoute.h"
#import "MAPolyline+CXMapExtensions.h"
#import "AMapDrivingRouteSearchRequest+CXMapExtensions.h"
#import "CXLocationManager.h"
#import "AMapNaviBaseManager+CXMapExtensions.h"
#import "AMapNaviRoute+CXMapEXtensions.h"
#import <CXFoundation/CXFoundation.h>

@interface CXRouteViewController () <AMapSearchDelegate, AMapNaviDriveManagerDelegate, AMapNaviRideManagerDelegate, AMapNaviWalkManagerDelegate> {
    CXDrivingNavigationRoute *_drivingRoute;
}

@property (nonatomic, strong) AMapSearchAPI *searcher;

@end

@implementation CXRouteViewController

- (AMapSearchAPI *)searcher{
    if(!_searcher){
        _searcher = [[AMapSearchAPI alloc] init];
        _searcher.delegate = self;
    }
    
    return _searcher;
}

#pragma mark - 根据AMapSearchObject类api生成路径

- (void)addRouteWithOption:(CXMapRouteRequestOption *)routeOption{
    [self addRouteWithOption:routeOption edgePadding:self.mainContentInset];
}

- (void)addRouteWithOption:(CXMapRouteRequestOption *)routeOption
               edgePadding:(UIEdgeInsets)edgePadding{
    [self addRouteWithOption:routeOption edgePadding:edgePadding completionHandler:nil];
}

- (void)addRouteWithOption:(CXMapRouteRequestOption *)routeOption
               edgePadding:(UIEdgeInsets)edgePadding
         completionHandler:(CXMapDrawRouteCompletionHandler)completionHandler{
    if(!routeOption){
        return;
    }
    
    if(!CXLocationCoordinate2DIsValid(routeOption.startCoordinate) ||
       !CXLocationCoordinate2DIsValid(routeOption.endCoordinate)){
        return;
    }
    
    AMapDrivingRouteSearchRequest *request = [[AMapDrivingRouteSearchRequest alloc] initWithStartCoordinate:routeOption.startCoordinate endCoordinate:routeOption.endCoordinate];
    request.strategy = routeOption.strategy;
    request.edgePadding = edgePadding;
    request.originId = routeOption.originId;
    request.destinationId = routeOption.destinationId;
    request.requireExtension = routeOption.showTraffic;
    request.completionHandler = completionHandler;
    request.routeOption = routeOption;
    
    [self.searcher cancelAllRequests];
    [self.searcher AMapDrivingRouteSearch:request];
}

#pragma mark - 根据Manager规划路径

- (void)addNaviRouteWithOption:(CXMapRouteRequestOption *)routeOption{
    [self addNaviRouteWithOption:routeOption edgePadding:self.mainContentInset];
}

- (void)addNaviRouteWithOption:(CXMapRouteRequestOption *)routeOption edgePadding:(UIEdgeInsets)edgePadding{
    [self addNaviRouteWithOption:routeOption edgePadding:edgePadding completionHandler:nil];
}

- (void)addNaviRouteWithOption:(CXMapRouteRequestOption *)routeOption
                   edgePadding:(UIEdgeInsets)edgePadding
             completionHandler:(CXMapDrawNaviRouteCompletionHandler)completionHandler{
    if(!routeOption){
        return;
    }
    
    if(!CXLocationCoordinate2DIsValid(routeOption.startCoordinate) ||
       !CXLocationCoordinate2DIsValid(routeOption.endCoordinate)){
        return;
    }
    
    AMapNaviPoint *startPoint = [AMapNaviPoint locationWithLatitude:routeOption.startCoordinate.latitude longitude:routeOption.startCoordinate.longitude];
    AMapNaviPoint *endPoint = [AMapNaviPoint locationWithLatitude:routeOption.endCoordinate.latitude longitude:routeOption.endCoordinate.longitude];
    switch (routeOption.naviType) {
        case CXMapNaviDrive:{
            AMapNaviDriveManager *naviDriveManager = [AMapNaviDriveManager sharedInstance];
            naviDriveManager.edgePadding = edgePadding;
            naviDriveManager.completionHandler = completionHandler;
            [naviDriveManager addEventListener:self];
            naviDriveManager.routeOption = routeOption;
            [naviDriveManager calculateDriveRouteWithStartPoints:@[startPoint]
                                                       endPoints:@[endPoint]
                                                       wayPoints:nil
                                                 drivingStrategy:routeOption.strategy];
        }
            break;
        case CXMapNaviRide:{
            
            AMapNaviRideManager *naviRideManager = [AMapNaviRideManager sharedInstance];
            naviRideManager.edgePadding = edgePadding;
            naviRideManager.completionHandler = completionHandler;
            naviRideManager.delegate = self;
            naviRideManager.routeOption = routeOption;
            [naviRideManager calculateRideRouteWithStartPoint:startPoint endPoint:endPoint];
        }
            break;
        case CXMapNaviWalk:{
            AMapNaviWalkManager *naviWalkManager = [AMapNaviWalkManager sharedInstance];
            naviWalkManager.edgePadding = edgePadding;
            naviWalkManager.completionHandler = completionHandler;
            naviWalkManager.delegate = self;
            naviWalkManager.routeOption = routeOption;
            [naviWalkManager calculateWalkRouteWithStartPoints:@[startPoint] endPoints:@[endPoint]];
        }
            break;
        default:
            break;
    }
}

- (void)addRouteWithCoordinates:(NSArray<NSValue *> *)coordinates{
    [self addRouteWithCoordinates:coordinates lineWidth:0];
}

- (void)addRouteWithCoordinates:(NSArray<NSValue *> *)coordinates lineWidth:(CGFloat)lineWidth{
    [self removeRoute];
    
    _drivingRoute = [[CXDrivingNavigationRoute alloc] initWithCoordinates:coordinates];
    if(!_drivingRoute){
        return;
    }
    
    if(self.routeSolidColor){
        _drivingRoute.lineConfig.color = self.routeSolidColor;
    }
    
    if(lineWidth > 0){
        _drivingRoute.lineConfig.width = lineWidth;
    }
    
    _hasRoute = YES;
    _drivingRoute.edgePadding = self.mainContentInset;
    [self.mapView addOverlays:_drivingRoute.polylines];
    [self.mapView addAnnotations:_drivingRoute.annotations];
    [self setVisibleMapRectForRoute];
}

- (void)switchRoutePath:(AMapPath *)mapPath{
    [self switchRoutePath:mapPath edgePadding:self.mainContentInset];
}

- (void)switchRoutePath:(AMapPath *)mapPath edgePadding:(UIEdgeInsets)edgePadding{
    if(!mapPath){
        return;
    }
    
    [self removeRoute];
    _drivingRoute = [[CXDrivingNavigationRoute alloc] initWithMapPath:mapPath];
    if(!_drivingRoute){
        return;
    }
    
    _hasRoute = YES;
    _drivingRoute.edgePadding = edgePadding;
    
    [self.mapView addOverlays:_drivingRoute.polylines];
    [self.mapView addAnnotations:_drivingRoute.annotations];
    [self setVisibleMapRectForRoute];
}

- (void)switchNaviRoute:(AMapNaviRoute *)naviRoute{
    [self switchNaviRoute:naviRoute edgePadding:self.mainContentInset];
}

- (void)switchNaviRoute:(AMapNaviRoute *)naviRoute edgePadding:(UIEdgeInsets)edgePadding{
    if (!naviRoute) {
        return;
    }
    
    [self removeRoute];
    
    _drivingRoute = [[CXDrivingNavigationRoute alloc] initWithNaviRoute:naviRoute];
    if(!_drivingRoute){
        return;
    }
    
    _hasRoute = YES;
    _drivingRoute.edgePadding = edgePadding;
    
    [self.mapView addOverlays:_drivingRoute.polylines];
    [self.mapView addAnnotations:_drivingRoute.annotations];
    [self setVisibleMapRectForRoute];
}

- (void)removeRoute{
    if(!self.hasRoute || !_drivingRoute){
        return;
    }
    
    [self.mapView removeOverlays:_drivingRoute.polylines];
    [self.mapView removeAnnotations:_drivingRoute.annotations];
    
    _drivingRoute = nil;
    _hasRoute = NO;
}

- (void)setVisibleMapRectForRoute{
    [self setVisibleMapRectForRouteEdgePadding:_drivingRoute.edgePadding];
}

- (void)setVisibleMapRectForRouteEdgePadding:(UIEdgeInsets)edgePadding{
    if(!self.hasRoute || !_drivingRoute){
        return;
    }
    
    if(_drivingRoute.calculativeMapRect.size.width < 10.0 ||
       _drivingRoute.calculativeMapRect.size.height < 10.0){
        // 锚点
        CGPoint screenAnchor = CGPointMake(0.5, 0.5);
        CGSize mapSize = self.mapView.bounds.size;
        if(mapSize.width > 0 && mapSize.height > 0){
            screenAnchor.x += (edgePadding.left - edgePadding.right) / mapSize.width * 0.5;
            screenAnchor.y += (edgePadding.top - edgePadding.bottom) / mapSize.height * 0.5;
        }
        
        [self setCenterCoordinate:[CXLocationManager sharedManager].location.coordinate
                        zoomLevel:CXMapViewDefaultZoomLevel
                     screenAnchor:screenAnchor
                         animated:self.isEnableDefaultsAnimation];
    }else{
        [self.mapView setVisibleMapRect:_drivingRoute.calculativeMapRect
                            edgePadding:edgePadding
                               animated:self.isEnableDefaultsAnimation];
    }
}

#pragma mark - AMapSearchDelegate

- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response{
    if(!response.route){
        [request invokeHandler:self mapRoute:nil error:nil];
        return;
    }
    
    AMapDrivingRouteSearchRequest *routeRequest = (AMapDrivingRouteSearchRequest *)request;
    [response.route.paths enumerateObjectsUsingBlock:^(AMapPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.requestOption = request.routeOption;
    }];
    
    [self removeRoute];
    
    _drivingRoute = [[CXDrivingNavigationRoute alloc] initWithMapPath:response.route.paths.firstObject];
    if(!_drivingRoute){
        return;
    }
    
    if(!routeRequest.requireExtension && self.routeSolidColor){
        _drivingRoute.lineConfig.color = self.routeSolidColor;
    }
    
    _hasRoute = YES;
    _drivingRoute.edgePadding = request.edgePadding;
    
    [self.mapView addOverlays:_drivingRoute.polylines];
    [self.mapView addAnnotations:_drivingRoute.annotations];
    [self setVisibleMapRectForRoute];
    
    [request invokeHandler:self mapRoute:response.route error:nil];
}

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error{
    if([request isKindOfClass:[AMapRouteSearchBaseRequest class]]){
        [(AMapRouteSearchBaseRequest *)request invokeHandler:self mapRoute:nil error:error];
    }
}

#pragma mark - MAMapViewDelegate
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay{
    CXDrivingNavigationRouteLineConfig *lineConfig = _drivingRoute.lineConfig;
    
    if([overlay isKindOfClass:[MAMultiPolyline class]]){
        MAMultiPolyline *multiPolyline = (MAMultiPolyline *)overlay;
        
        MAMultiColoredPolylineRenderer * polylineRenderer = [[MAMultiColoredPolylineRenderer alloc] initWithMultiPolyline:multiPolyline];
        
        polylineRenderer.strokeColors = [_drivingRoute.multiPolylineColors copy];
        polylineRenderer.lineWidth = lineConfig.width;
        polylineRenderer.gradient = NO;
        polylineRenderer.lineDashType = multiPolyline.lineDashType;
        polylineRenderer.lineJoinType = kMALineJoinRound;
        polylineRenderer.lineCapType = kMALineCapRound;
        return polylineRenderer;
    }
    
    if([overlay isKindOfClass:[MAPolyline class]]){
        MAPolyline *polyline = (MAPolyline *)overlay;
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:polyline];
        polylineRenderer.strokeColor = lineConfig.color;
        polylineRenderer.lineWidth = lineConfig.width;
        polylineRenderer.lineDashType = polyline.lineDashType;
        polylineRenderer.lineJoinType = kMALineJoinRound;
        polylineRenderer.lineCapType = kMALineCapRound;
        return polylineRenderer;
    }
    
    return nil;
}

- (void)mapView:(MAMapView *)mapView didAddOverlayRenderers:(NSArray *)overlayRenderers{
    
}

#pragma mark - AMapNaviDriveManagerDelegate

- (void)driveManager:(AMapNaviDriveManager *)driveManager onCalculateRouteSuccessWithType:(AMapNaviRoutePlanType)type{
    NSArray<NSNumber *> *naviRouteIds = [driveManager.naviRoutes.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    
    NSMutableArray <AMapNaviRoute *> *naviRoutes = [NSMutableArray array];
    [naviRouteIds enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        AMapNaviRoute *naviRoute = driveManager.naviRoutes[obj];
        naviRoute.routeId = obj;
        naviRoute.requestOption = driveManager.routeOption;
        [naviRoutes addObject:naviRoute];
    }];
    
    [driveManager invokeHandler:self
                     naviRoutes:naviRoutes.copy
                          error:nil];
    [[AMapNaviDriveManager sharedInstance] removeEventListener:self];
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager onCalculateRouteFailure:(NSError *)error routePlanType:(AMapNaviRoutePlanType)type{
    [driveManager invokeHandler:self
                     naviRoutes:nil
                          error:error];
    
    [[AMapNaviDriveManager sharedInstance] removeEventListener:self];
}

#pragma mark - AMapNaviRideManagerDelegate

- (void)rideManagerOnCalculateRouteSuccess:(AMapNaviRideManager *)rideManager{
    NSMutableArray *naviRoutes = [NSMutableArray array];
    AMapNaviRoute *route = rideManager.naviRoute;
    route.routeId = @(rideManager.naviRouteID);
    if(route){
        [naviRoutes addObject:route];
    }
    
    [rideManager invokeHandler:self
                    naviRoutes:naviRoutes.copy
                         error:nil];
    [AMapNaviRideManager destroyInstance];
}

- (void)rideManager:(AMapNaviRideManager *)rideManager onCalculateRouteFailure:(NSError *)error{
    [rideManager invokeHandler:self
                    naviRoutes:nil
                         error:error];
    [AMapNaviRideManager destroyInstance];
}

#pragma mark - AMapNaviWalkManagerDelegate

- (void)walkManagerOnCalculateRouteSuccess:(AMapNaviWalkManager *)walkManager{
    NSMutableArray *naviRoutes = [NSMutableArray array];
    AMapNaviRoute *route = walkManager.naviRoute;
    route.routeId = @(walkManager.naviRouteID);
    if(route){
        [naviRoutes addObject:route];
    }
    
    [walkManager invokeHandler:self
                    naviRoutes:[naviRoutes copy]
                         error:nil];
    [AMapNaviWalkManager destroyInstance];
}

- (void)walkManager:(AMapNaviWalkManager *)walkManager onCalculateRouteFailure:(NSError *)error{
    [walkManager invokeHandler:self
                    naviRoutes:nil
                         error:error];
    [AMapNaviWalkManager destroyInstance];
}

@end
