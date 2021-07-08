//
//  CXMapViewController.m
//  Pods
//
//  Created by wshaolin on 2017/11/22.
//

#import "CXMapViewController.h"
#import "CXUserLocationView.h"
#import "CXMapWebData.h"
#import "CXMapRouteUtils.h"
#import "CXPointAnnotation.h"

@interface CXMapViewController () <MAMapViewDelegate> {
    BOOL _hasUserLocation;
}

@end

@implementation CXMapViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    _mapView.showsUserLocation = self.isShowsUserLocation;
    if(_userLocationView.superview || !self.userLocation){
        return;
    }
    
    if(self.isShowsUserLocation){
        [_mapView addAnnotation:self.userLocation];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    _mapView.showsUserLocation = NO;
}

- (instancetype)init{
    return [self initWithContainsMapView:YES];
}

- (instancetype)initWithContainsMapView:(BOOL)containsMapView{
    if(self = [super init]){
        if(containsMapView){
            self.enableDefaultsAnimation = YES;
            _showsUserLocation = YES;
            [self createMapView];
        }
    }
    
    return self;
}

- (void)createMapView{
    _mapView = [[MAMapView alloc] init];
    _mapView.delegate = self;
    _mapView.mapType = MAMapTypeStandard;
    _mapView.userTrackingMode = MAUserTrackingModeFollow;
    _mapView.showsCompass = NO; // 不显示指南针
    _mapView.showsScale = NO; // 不显示比例尺
    _mapView.rotateEnabled = NO; // 不允许旋转
    _mapView.rotateCameraEnabled = NO; // 不支持倾斜
    _mapView.showsIndoorMap = YES; //是否显示室内地图
    _mapView.showsUserLocation = _showsUserLocation;
    _mapView.showsBuildings = NO;
    _mapView.showTraffic = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(!_mapView){
        return;
    }
    
    CGFloat mapView_X = 0;
    CGFloat mapView_W = self.view.bounds.size.width - mapView_X * 2;
    CGFloat mapView_Y = self.navigationBar.isHidden ? 0 : CGRectGetMaxY(self.navigationBar.frame);
    CGFloat mapView_H = self.view.bounds.size.height - mapView_Y;
    _mapView.frame = (CGRect){mapView_X, mapView_Y, mapView_W, mapView_H};
    _mapView.delegate = self;
    [self.view addSubview:_mapView];
    
    self.trafficColor = @{@(MATrafficStatusSmooth) : [UIColor clearColor]};
    self.screenAnchor = CGPointMake(0.5, 0.5);
    
    MAUserLocationRepresentation *userLocationRepresentation = [self userLocationRepresentation];
    if(userLocationRepresentation){
        [_mapView updateUserLocationRepresentation:userLocationRepresentation];
    }
}

- (MAUserLocationRepresentation *)userLocationRepresentation{
    MAUserLocationRepresentation *representation = [[MAUserLocationRepresentation alloc] init];
    representation.showsAccuracyRing = YES;
    representation.fillColor = [CXHexIColor(0x59D8FF) colorWithAlphaComponent:0.2];
    return representation;
}

- (void)willEnterForegroundNotification:(NSNotification *)notification{
    [super willEnterForegroundNotification:notification];
    
    if(!self.isShowsUserLocation){
        return;
    }
    
    if(self.isAnimating){
        return;
    }
    
    if(self.isDisplaying){
        _mapView.showsUserLocation = YES;
    }
}

- (void)didEnterBackgroundNotification:(NSNotification *)notification{
    [super didEnterBackgroundNotification:notification];
    
    _mapView.showsUserLocation = NO;
}

- (void)setUserLocationInMapViewCenterAnimated:(BOOL)animated{
    if(self.isShowsUserLocation){
        [self setCenterCoordinate:self.userLocation.location.coordinate
                        zoomLevel:CXMapViewDefaultZoomLevel
                         animated:animated];
    }
}

- (void)setShowsUserLocation:(BOOL)showsUserLocation{
    _showsUserLocation = showsUserLocation;
    _mapView.showsUserLocation = showsUserLocation;
}

- (MAUserLocation *)userLocation{
    return _mapView.userLocation;
}

- (NSArray<CXPointAnnotation *> *)annotations{
    return self.mapView.annotations;
}

#pragma mark - zoomLevel

- (CGFloat)zoomLevel{
    return _mapView.zoomLevel;
}

- (void)setZoomLevel:(CGFloat)zoomLevel{
    _mapView.zoomLevel = zoomLevel;
}

- (void)setMinZoomLevel:(CGFloat)minZoomLevel{
    _mapView.minZoomLevel = minZoomLevel;
}

- (CGFloat)minZoomLevel{
    return _mapView.minZoomLevel;
}

- (void)setMaxZoomLevel:(CGFloat)maxZoomLevel{
    _mapView.maxZoomLevel = maxZoomLevel;
}

- (CGFloat)maxZoomLevel{
    return _mapView.maxZoomLevel;
}

- (void)setZoomLevel:(CGFloat)zoomLevel animated:(BOOL)animated{
    [_mapView setZoomLevel:zoomLevel animated:animated];
}

- (void)setShowTraffic:(BOOL)showTraffic{
    _mapView.showTraffic = showTraffic;
}

- (BOOL)isShowTraffic{
    return _mapView.isShowTraffic;
}

- (void)setShowsLabels:(BOOL)showsLabels{
    _mapView.showsLabels = showsLabels;
}

- (BOOL)isShowsLabels{
    return _mapView.isShowsLabels;
}

- (void)setUserTrackingMode:(MAUserTrackingMode)userTrackingMode{
    _mapView.userTrackingMode = userTrackingMode;
}

- (MAUserTrackingMode)userTrackingMode{
    return _mapView.userTrackingMode;
}

- (void)setTrafficColor:(NSDictionary<NSNumber *, UIColor *> *)trafficColor{
    _mapView.trafficStatus = trafficColor;
}

- (NSDictionary<NSNumber *,UIColor *> *)trafficColor{
    return _mapView.trafficStatus;
}

- (void)setScreenAnchor:(CGPoint)screenAnchor{
    _mapView.screenAnchor = screenAnchor;
}

- (CGPoint)screenAnchor{
    return _mapView.screenAnchor;
}

#pragma mark - centerCoordinate

- (CLLocationCoordinate2D)centerCoordinate{
    return _mapView.centerCoordinate;
}

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate{
    _mapView.centerCoordinate = centerCoordinate;
}

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate animated:(BOOL)animated{
    [_mapView setCenterCoordinate:centerCoordinate animated:animated];
}

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate zoomLevel:(CGFloat)zoomLevel animated:(BOOL)animated{
    [self setCenterCoordinate:centerCoordinate zoomLevel:zoomLevel screenAnchor:self.screenAnchor animated:animated];
}

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate zoomLevel:(CGFloat)zoomLevel screenAnchor:(CGPoint)screenAnchor animated:(BOOL)animated{
    MAMapStatus *status = [_mapView getMapStatus];
    status.centerCoordinate = centerCoordinate;
    status.zoomLevel = zoomLevel;
    status.screenAnchor = screenAnchor;
    [_mapView setMapStatus:status animated:animated duration:0.25];
}

#pragma mark - annotation

- (void)addAnnotation:(CXPointAnnotation *)annotation{
    [self.mapView addAnnotation:annotation];
}

- (void)addAnnotations:(NSArray<CXPointAnnotation *> *)annotations{
    [self.mapView addAnnotations:annotations];
}

- (void)removeAnnotation:(CXPointAnnotation *)annotation{
    [self.mapView removeAnnotation:annotation];
}

- (void)removeAnnotations:(NSArray<CXPointAnnotation *> *)annotations{
    [self.mapView removeAnnotations:annotations];
}

- (void)selectAnnotation:(CXPointAnnotation *)annotation animated:(BOOL)animated{
    [self.mapView selectAnnotation:annotation animated:animated];
}

- (void)deselectAnnotation:(CXPointAnnotation *)annotation animated:(BOOL)animated{
    [self.mapView deselectAnnotation:annotation animated:animated];
}

- (void)showAnnotations:(NSArray<CXPointAnnotation *> *)annotations animated:(BOOL)animated{
    [self.mapView showAnnotations:annotations animated:animated];
}

- (void)showAnnotations:(NSArray<CXPointAnnotation *> *)annotations edgePadding:(UIEdgeInsets)insets animated:(BOOL)animated{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(annotations.count > 1){
            [self.mapView showAnnotations:annotations edgePadding:insets animated:animated];
        }else{
            CLLocationCoordinate2D coordinate = self.userLocation.location.coordinate;
            if(annotations.count == 1){
                coordinate = annotations.firstObject.coordinate;
            }
            
            // 锚点
            CGPoint screenAnchor = CGPointMake(0.5, 0.5);
            CGSize mapSize = self.mapView.bounds.size;
            if(mapSize.width > 0 && mapSize.height > 0){
                screenAnchor.x += (insets.left - insets.right) / mapSize.width * 0.5;
                screenAnchor.y += (insets.top - insets.bottom) / mapSize.height * 0.5;
            }
            
            [self setCenterCoordinate:coordinate
                            zoomLevel:CXMapViewDefaultZoomLevel
                         screenAnchor:screenAnchor
                             animated:animated];
        }
    });
}

- (void)showAllAnnotationsWithEdgePadding:(UIEdgeInsets)insets animated:(BOOL)animated{
    NSMutableArray *annotations = [NSMutableArray array];
    if(self.isShowsUserLocation && self.userLocation){
        [annotations addObject:self.userLocation];
    }
    
    if(self.annotations){
        [annotations addObjectsFromArray:self.annotations];
    }
    
    [self showAnnotations:[annotations copy] edgePadding:insets animated:animated];
}

- (void)showAllAnnotationsAnimated:(BOOL)animated{
    [self showAllAnnotationsWithEdgePadding:self.mainContentInset animated:animated];
}

- (void)setAnnotation:(CXPointAnnotation *)annotation coordinate:(CLLocationCoordinate2D)coordinate{
    if(!annotation){
        return;
    }
    
    if([self.mapView.annotations containsObject:annotation]){
        [self.mapView removeAnnotation:annotation];
    }
    
    annotation.coordinate = coordinate;
    [self.mapView addAnnotation:annotation];
}

- (double)metersPerPointForCurrentZoomLevel{
    return [self.mapView metersPerPointForZoomLevel:self.mapView.zoomLevel];
}

- (void)setCustomMapStyleOptions:(MAMapCustomStyleOptions *)options{
    if(!options){
        return;
    }
    
    [self.mapView setCustomMapStyleEnabled:true];
    [self.mapView setCustomMapStyleOptions:options];
}

- (void)setVisibleMapRectForCoordinates:(NSArray<NSValue *> *)coordinates{
    if(CXArrayIsEmpty(coordinates)){
        return;
    }
    
    CLLocationCoordinate2D *_coordinates = (CLLocationCoordinate2D *)malloc(coordinates.count * sizeof(CLLocationCoordinate2D));
    [coordinates enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        _coordinates[idx] = obj.MACoordinateValue;
    }];
    
    [self setVisibleMapRectForCoordinates:_coordinates count:coordinates.count];
    
    free(_coordinates);
    _coordinates = NULL;
}

- (void)setVisibleMapRectForCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count{
    MAMapRect mapRect = [CXMapRouteUtils minMapRectForCoordinates:coordinates count:count];
    if(MAMapRectEqualToRect(mapRect, MAMapRectZero)){
        return;
    }
    
    [self.mapView setVisibleMapRect:mapRect edgePadding:self.mainContentInset animated:self.isEnableDefaultsAnimation];
}

- (void)takeSnapshotInRect:(CGRect)rect completion:(void (^)(UIImage *image, NSInteger state))completion{
    [self.mapView takeSnapshotInRect:rect withCompletionBlock:completion];
}

#pragma mark - MAMapView delegate

- (void)mapViewRegionChanged:(MAMapView *)mapView{
    
}

- (void)mapView:(MAMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    
}

- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
}

- (void)mapView:(MAMapView *)mapView mapWillMoveByUser:(BOOL)wasUserAction{
    [self mapViewWillMoveByUser:wasUserAction];
}

- (void)mapView:(MAMapView *)mapView mapDidMoveByUser:(BOOL)wasUserAction{
    [self mapViewDidMoveByUser:wasUserAction];
}

- (void)mapView:(MAMapView *)mapView mapWillZoomByUser:(BOOL)wasUserAction{
    [self mapViewWillZoomByUser:wasUserAction];
}

- (void)mapView:(MAMapView *)mapView mapDidZoomByUser:(BOOL)wasUserAction{
    [self mapViewDidZoomByUser:wasUserAction];
}

- (void)mapView:(MAMapView *)mapView didSingleTappedAtCoordinate:(CLLocationCoordinate2D)coordinate{
    
}

- (void)mapView:(MAMapView *)mapView didLongPressedAtCoordinate:(CLLocationCoordinate2D)coordinate{
    
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation{
    if([annotation isKindOfClass:[MAUserLocation class]]){
        if(!_userLocationView){
            MAUserLocation *userLocation = (MAUserLocation *)annotation;
            _userLocationView = [self mapView:mapView viewForUserLocation:userLocation];
        }
        
        return _userLocationView;
    }
    
    if([annotation isKindOfClass:[CXPointAnnotation class]]){
        CXPointAnnotation *pointAnnotation = (CXPointAnnotation *)annotation;
        return [self mapView:mapView viewForPointAnnotation:pointAnnotation];
    }
    
    return nil;
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForPointAnnotation:(CXPointAnnotation *)annotation{
    MAAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:annotation.identifier];
    if(!annotationView){
        annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotation.identifier];
    }
    
    annotationView.image = annotation.image;
    annotationView.customCalloutView = annotation.customCalloutView;
    annotationView.canShowCallout = annotation.customCalloutView != nil;
    annotationView.enabled = annotation.isEnabled;
    annotationView.draggable = NO;
    annotationView.zIndex = annotation.zIndex;
    annotationView.centerOffset = annotation.centerOffset;
    annotationView.calloutOffset = annotation.calloutOffset;
    return annotationView;
}

- (CXUserLocationView *)mapView:(MAMapView *)mapView viewForUserLocation:(MAUserLocation *)userLocation{
    static NSString *identifier = @"CXUserLocationView";
    CXUserLocationView *annotationView = (CXUserLocationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if(!annotationView){
        annotationView = [[CXUserLocationView alloc] initWithAnnotation:userLocation reuseIdentifier:identifier];
    }
    
    return annotationView;
}

- (void)mapView:(MAMapView *)mapView didAddAnnotationViews:(NSArray *)views{
    
}

- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view{
    [mapView deselectAnnotation:view.annotation animated:YES];
    [self didSelectedAnnotation:(CXPointAnnotation *)view.annotation];
}

- (void)mapView:(MAMapView *)mapView didDeselectAnnotationView:(MAAnnotationView *)view{
    
}

- (void)mapView:(MAMapView *)mapView annotationView:(MAAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    
}

- (void)mapView:(MAMapView *)mapView didAnnotationViewCalloutTapped:(MAAnnotationView *)view{
    
}

- (void)mapViewWillStartLocatingUser:(MAMapView *)mapView{
    
}

- (void)mapViewDidStopLocatingUser:(MAMapView *)mapView{
    
}

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation{
    if(!userLocation.location){
        return;
    }
    
    if(!_hasUserLocation){
        _hasUserLocation = YES;
        [self setCenterCoordinate:userLocation.location.coordinate zoomLevel:CXMapViewDefaultZoomLevel animated:NO];
    }
    
    if(_userLocationView){
        _userLocationView.rotationDegree = userLocation.heading.trueHeading - mapView.rotationDegree;
    }
    
    if(updatingLocation){
        [self didUpdateUserLocation:userLocation];
    }
}

- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error{
    
}

- (void)mapView:(MAMapView *)mapView didChangeUserTrackingMode:(MAUserTrackingMode)mode animated:(BOOL)animated{
    
}

- (void)mapView:(MAMapView *)mapView annotationView:(MAAnnotationView *)view didChangeDragState:(MAAnnotationViewDragState)newState fromOldState:(MAAnnotationViewDragState)oldState{
    
}

- (void)mapView:(MAMapView *)mapView didTouchPois:(NSArray *)pois{
    
}

- (void)mapInitComplete:(MAMapView *)mapView{
    
}

- (void)offlineDataWillReload:(MAMapView *)mapView{
    
}

- (void)offlineDataDidReload:(MAMapView *)mapView{
    
}

#pragma mark - 处理回调，供子类使用

- (void)didSelectedAnnotation:(CXPointAnnotation *)annotation{
    
}

- (void)didUpdateUserLocation:(MAUserLocation *)userLocation{
    
}

- (void)mapViewWillMoveByUser:(BOOL)wasUserAction{
    
}

- (void)mapViewDidMoveByUser:(BOOL)wasUserAction{
    
}

- (void)mapViewWillZoomByUser:(BOOL)wasUserAction{
    
}

- (void)mapViewDidZoomByUser:(BOOL)wasUserAction{
    
}

- (BOOL)disableGesturePopInteraction{
    return YES;
}

@end
