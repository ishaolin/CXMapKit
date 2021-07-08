//
//  CXMapNaviDriveView.m
//  CXMapKit
//
//  Created by lcc on 2018/6/19.
//

#import "CXMapNaviDriveView.h"
#import <CXUIKit/CXUIKit.h>
#import "CXMapWebData.h"
#import "AMapNaviRoute+CXMapEXtensions.h"
#import "CXLocationManager.h"
#import "CXSpeechSynthesizer+CXMapExtensions.h"

@interface CXMapNaviDriveView() <AMapNaviDriveManagerDelegate, AMapNaviDriveViewDelegate, MAMapViewDelegate> {
    BOOL _canDestroyNaviDriveManager;
}

@property (nonatomic, weak) id<MAMapViewDelegate> mapViewDelegate;

@end

@implementation CXMapNaviDriveView

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        AMapNaviDriveManager *naviManager = [AMapNaviDriveManager sharedInstance];
        naviManager.isUseInternalTTS = NO;
        naviManager.delegate = [CXSpeechSynthesizer sharedSynthesizer];
        [naviManager addEventListener:self];
        [naviManager addDataRepresentative:self];
        
        self.delegate = self;
        self.mapView.rotateEnabled = NO;
        self.mapView.rotateCameraEnabled = NO;
        self.cameraDegree = 0.0;
        self.trackingMode = AMapNaviViewTrackingModeCarNorth;
        self.showUIElements = YES;
        self.showBrowseRouteButton = NO;
        self.showMoreButton = NO;
        self.showScale = NO;
        self.showTrafficBar = NO;
        self.showTrafficButton = NO;
        self.autoSwitchShowModeToCarPositionLocked = YES;
        
        UIButton *zoomInButton = [self valueForKey:@"zoomInBtn"];
        UIButton *zoomOutButton = [self valueForKey:@"zoomOutBtn"];
        zoomInButton.hidden = YES;
        zoomOutButton.hidden = YES;
        
        self.mapViewDelegate = (id<MAMapViewDelegate>)[self valueForKey:@"naviMapView"];
        self.mapView.delegate = self;
    }
    
    return self;
}

#pragma mark - CXMapNaviViewSupportable

- (MAMapView *)mapView{
    return (MAMapView *)[self valueForKey:@"internalMapView"];
}

- (UIView *)naviTopInfoView{
    return (UIView *)[self valueForKey:@"topInfoView"];
}

- (UIView *)naviBottomInfoView{
    return (UIView *)[self valueForKey:@"bottomInfoView"];
}

- (void)setNaviShowMode:(CXMapNaviShowMode)naviShowMode{
    switch (naviShowMode) {
        case CXMapNaviShowModeCarPositionLocked:{
            self.showMode = AMapNaviDriveViewShowModeCarPositionLocked;
        }
            break;
        case CXMapNaviShowModeOverview:{
            self.showMode = AMapNaviDriveViewShowModeOverview;
        }
            break;
        case CXMapNaviShowModeNormal:{
            self.showMode = AMapNaviDriveViewShowModeNormal;
        }
            break;
        default:
            break;
    }
}

- (CXMapNaviShowMode)naviShowMode{
    return (CXMapNaviShowMode)self.showMode;
}

- (void)setShowTraffic:(BOOL)showTraffic{
    self.mapView.showTraffic = showTraffic;
}

- (BOOL)isShowTraffic{
    return self.mapView.isShowTraffic;
}

- (void)setNaviSpeakerEnabled:(BOOL)naviSpeakerEnabled{
    [CXSpeechSynthesizer sharedSynthesizer].enableSpeak = naviSpeakerEnabled;
}

- (BOOL)isNaviSpeakerEnabled{
    return [CXSpeechSynthesizer sharedSynthesizer].isEnableSpeak;
}

- (BOOL)recalculateRouteWithPreference:(CXMapRoutePreference *)preference{
    if(!preference){
        return NO;
    }
    
    AMapNaviDrivingStrategy strategy = CXMapNaviDrivingStrategyFromPreference(NO, preference);
    return [[AMapNaviDriveManager sharedInstance] recalculateDriveRouteWithDrivingStrategy:strategy];
}

- (BOOL)calculateRouteWithNaviParam:(CXMapNaviParam *)naviParam{
    AMapNaviDriveManager *driveManager = [AMapNaviDriveManager sharedInstance];
    if(naviParam.naviRoute){
        [driveManager.naviRoutes enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, AMapNaviRoute * _Nonnull obj, BOOL * _Nonnull stop) {
            if(naviParam.naviRoute == obj){
                [driveManager selectNaviRouteWithRouteID:[key integerValue]];
                [driveManager startGPSNavi];
                *stop = YES;
            }
        }];
        return YES;
    }
    
    AMapNaviPoint *endPoint = CXMapNaviPointFromCoordinate(naviParam.endCoordinate);
    if(!endPoint){
        [AMapNaviDriveManager destroyInstance];
        return NO;
    }
    
    _canDestroyNaviDriveManager = YES;
    AMapNaviPoint *startPoint = CXMapNaviPointFromCoordinate(naviParam.startCoordinate);
    if(startPoint){
        return [driveManager calculateDriveRouteWithStartPoints:@[startPoint]
                                                      endPoints:@[endPoint]
                                                      wayPoints:nil
                                                drivingStrategy:naviParam.strategy];
    }else{
        return [driveManager calculateDriveRouteWithEndPoints:@[endPoint]
                                                    wayPoints:nil
                                              drivingStrategy:naviParam.strategy];
    }
}

- (void)setTrackingType:(CXMapNaviTrackingType)trackingType{
    switch (trackingType) {
        case CXMapNaviTracking2D:{
            self.cameraDegree = 0.0;
            self.trackingMode = AMapNaviViewTrackingModeCarNorth; // 车头朝北
        }
            break;
        case CXMapNaviTracking3D:{
            self.cameraDegree = 60.0;
            self.trackingMode = AMapNaviViewTrackingModeCarNorth; // 车头朝北
        }
            break;
        case CXMapNaviTrackingNorth:{
            self.cameraDegree = 0.0;
            self.trackingMode = AMapNaviViewTrackingModeMapNorth; // 地图朝北
        }
            break;
        default:
            break;
    }
}

#pragma mark - AMapNaviDriveDataRepresentable

- (void)driveManager:(AMapNaviDriveManager *)driveManager updateNaviInfo:(nullable AMapNaviInfo *)naviInfo{
    if([super respondsToSelector:@selector(driveManager:updateNaviInfo:)]){
        [super driveManager:driveManager updateNaviInfo:naviInfo];
    }
    
    if([self.naviDelegate respondsToSelector:@selector(naviManager:naviType:updateNaviInfo:)]){
        [self.naviDelegate naviManager:driveManager naviType:CXMapNaviDrive updateNaviInfo:naviInfo];
    }
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager updateNaviLocation:(nullable AMapNaviLocation *)naviLocation{
    if([super respondsToSelector:@selector(driveManager:updateNaviInfo:)]){
        [super driveManager:driveManager updateNaviLocation:naviLocation];
    }
    
    if([self.naviDelegate respondsToSelector:@selector(naviManager:naviType:updateNaviLocation:)]){
        [self.naviDelegate naviManager:driveManager naviType:CXMapNaviDrive updateNaviLocation:naviLocation];
    }
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager showCrossImage:(UIImage *)crossImage{
    if([super respondsToSelector:@selector(driveManager:showCrossImage:)]){
        [super driveManager:driveManager showCrossImage:crossImage];
    }
    
    if([self.naviDelegate respondsToSelector:@selector(driveManager:showCrossImage:)]){
        [self.naviDelegate driveManager:driveManager showCrossImage:crossImage];
    }
    
    [self notifyDelegateDidLayoutSubviews];
}

- (void)driveManagerHideCrossImage:(AMapNaviDriveManager *)driveManager{
    if([super respondsToSelector:@selector(driveManagerHideCrossImage:)]){
        [super driveManagerHideCrossImage:driveManager];
    }
    
    if([self.naviDelegate respondsToSelector:@selector(driveManagerHideCrossImage:)]){
        [self.naviDelegate driveManagerHideCrossImage:driveManager];
    }
    
    [self notifyDelegateDidLayoutSubviews];
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager showLaneBackInfo:(NSString *)laneBackInfo laneSelectInfo:(NSString *)laneSelectInfo{
    if([super respondsToSelector:@selector(driveManager:showLaneBackInfo:laneSelectInfo:)]){
        [super driveManager:driveManager showLaneBackInfo:laneBackInfo laneSelectInfo:laneSelectInfo];
    }
    
    if([self.naviDelegate respondsToSelector:@selector(driveManager:showLaneInfoImage:)]){
        UIImage *laneInfoImage = CreateLaneInfoImageWithLaneInfo(laneBackInfo, laneSelectInfo);
        [self.naviDelegate driveManager:driveManager showLaneInfoImage:laneInfoImage];
    }
}

- (void)driveManagerHideLaneInfo:(AMapNaviDriveManager *)driveManager{
    if([super respondsToSelector:@selector(driveManagerHideLaneInfo:)]){
        [super driveManagerHideLaneInfo:driveManager];
    }
    
    if([self.naviDelegate respondsToSelector:@selector(driveManagerHideLaneInfo:)]){
        [self.naviDelegate driveManagerHideLaneInfo:driveManager];
    }
}

#pragma mark - AMapNaviDriveManagerDelegate

- (void)driveManager:(AMapNaviDriveManager *)driveManager error:(NSError *)error{
    if([self.naviDelegate respondsToSelector:@selector(naviManager:naviType:error:)]){
        [self.naviDelegate naviManager:driveManager naviType:CXMapNaviDrive error:error];
    }
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager onCalculateRouteSuccessWithType:(AMapNaviRoutePlanType)type{
    if([driveManager startGPSNavi]){
        if([self.naviDelegate respondsToSelector:@selector(naviManagerOnCalculateRouteSuccess:naviType:)]){
            [self.naviDelegate naviManagerOnCalculateRouteSuccess:driveManager naviType:CXMapNaviDrive];
        }
    }
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager onCalculateRouteFailure:(NSError *)error{
    if([self.naviDelegate respondsToSelector:@selector(naviManager:naviType:onCalculateRouteFailure:)]){
        [self.naviDelegate naviManager:driveManager naviType:CXMapNaviDrive onCalculateRouteFailure:error];
    }
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager didStartNavi:(AMapNaviMode)naviMode{
    if([self.naviDelegate respondsToSelector:@selector(naviManager:naviType:didStartNavi:)]){
        [self.naviDelegate naviManager:driveManager naviType:CXMapNaviDrive didStartNavi:naviMode];
    }
}

- (void)driveManagerDidEndEmulatorNavi:(AMapNaviDriveManager *)driveManager{
    if([self.naviDelegate respondsToSelector:@selector(naviManagerOnArrivedDestination:naviType:)]){
        [self.naviDelegate naviManagerOnArrivedDestination:driveManager naviType:CXMapNaviDrive];
    }
}

- (void)driveManagerOnArrivedDestination:(AMapNaviDriveManager *)driveManager{
    if([self.naviDelegate respondsToSelector:@selector(naviManagerOnArrivedDestination:naviType:)]){
        [self.naviDelegate naviManagerOnArrivedDestination:driveManager naviType:CXMapNaviDrive];
    }
}

#pragma mark - AMapNaviDriveViewDelegate

- (void)driveViewCloseButtonClicked:(AMapNaviDriveView *)driveView{
    if([self.naviDelegate respondsToSelector:@selector(naviView:closeForNaviType:completion:)]) {
        [self.naviDelegate naviView:self closeForNaviType:CXMapNaviDrive completion:^(BOOL finished) {
            if(finished){
                [[CXSpeechSynthesizer sharedSynthesizer] stop];
                [[AMapNaviDriveManager sharedInstance] stopNavi];
                [AMapNaviDriveManager sharedInstance].delegate = nil;
                if(self->_canDestroyNaviDriveManager){
                    [AMapNaviDriveManager destroyInstance];
                }
            }
        }];
    }
}

- (void)driveView:(AMapNaviDriveView *)driveView didChangeShowMode:(AMapNaviDriveViewShowMode)showMode{
    if([self.naviDelegate respondsToSelector:@selector(naviView:didChangeShowMode:naviType:)]) {
        [self.naviDelegate naviView:driveView
                  didChangeShowMode:(CXMapNaviShowMode)showMode
                           naviType:CXMapNaviDrive];
    }
}

#pragma mark - MAMapViewDelegate

- (void)mapViewRegionChanged:(MAMapView *)mapView{
    if([self.mapViewDelegate respondsToSelector:@selector(mapViewRegionChanged:)]){
        [self.mapViewDelegate mapViewRegionChanged:mapView];
    }
}

- (void)mapView:(MAMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    if([self.mapViewDelegate respondsToSelector:@selector((mapView:regionWillChangeAnimated:))]){
        [self.mapViewDelegate mapView:mapView regionWillChangeAnimated:animated];
    }
}

- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    if([self.mapViewDelegate respondsToSelector:@selector((mapView:regionWillChangeAnimated:))]){
        [self.mapViewDelegate mapView:mapView regionDidChangeAnimated:animated];
    }
}

- (void)mapView:(MAMapView *)mapView mapWillMoveByUser:(BOOL)wasUserAction{
    if([self.mapViewDelegate respondsToSelector:@selector((mapView:mapWillMoveByUser:))]){
        [self.mapViewDelegate mapView:mapView mapWillMoveByUser:wasUserAction];
    }
}

- (void)mapView:(MAMapView *)mapView mapDidMoveByUser:(BOOL)wasUserAction{
    if([self.mapViewDelegate respondsToSelector:@selector((mapView:mapDidMoveByUser:))]){
        [self.mapViewDelegate mapView:mapView mapDidMoveByUser:wasUserAction];
    }
}

- (void)mapView:(MAMapView *)mapView mapWillZoomByUser:(BOOL)wasUserAction{
    if([self.mapViewDelegate respondsToSelector:@selector((mapView:mapWillZoomByUser:))]){
        [self.mapViewDelegate mapView:mapView mapWillZoomByUser:wasUserAction];
    }
}

- (void)mapView:(MAMapView *)mapView mapDidZoomByUser:(BOOL)wasUserAction{
    if([self.mapViewDelegate respondsToSelector:@selector((mapView:mapDidZoomByUser:))]){
        [self.mapViewDelegate mapView:mapView mapDidZoomByUser:wasUserAction];
    }
}

- (void)mapViewWillStartLoadingMap:(MAMapView *)mapView{
    if([self.mapViewDelegate respondsToSelector:@selector(mapViewWillStartLoadingMap:)]){
        [self.mapViewDelegate mapViewWillStartLoadingMap:mapView];
    }
}

- (void)mapViewDidFinishLoadingMap:(MAMapView *)mapView{
    if([self.mapViewDelegate respondsToSelector:@selector(mapViewDidFinishLoadingMap:)]){
        [self.mapViewDelegate mapViewDidFinishLoadingMap:mapView];
    }
}

- (void)mapViewDidFailLoadingMap:(MAMapView *)mapView withError:(NSError *)error{
    if([self.mapViewDelegate respondsToSelector:@selector(mapViewDidFailLoadingMap:withError:)]){
        [self.mapViewDelegate mapViewDidFailLoadingMap:mapView withError:error];
    }
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation{
    if([self.naviDelegate respondsToSelector:@selector(mapView:viewForAnnotation:)]){
        MAAnnotationView *annotationView = [self.naviDelegate mapView:mapView viewForAnnotation:annotation];
        if(annotationView){
            return annotationView;
        }
    }
    
    if([self.mapViewDelegate respondsToSelector:@selector(mapView:viewForAnnotation:)]){
        return [self.mapViewDelegate mapView:mapView viewForAnnotation:annotation];
    }
    
    return nil;
}

- (void)mapView:(MAMapView *)mapView didAddAnnotationViews:(NSArray *)views{
    if([self.mapViewDelegate respondsToSelector:@selector(mapView:didAddAnnotationViews:)]){
        [self.mapViewDelegate mapView:mapView didAddAnnotationViews:views];
    }
}

- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view{
    if([self.naviDelegate respondsToSelector:@selector(mapView:didSelectAnnotationView:)]){
        if([self.naviDelegate mapView:mapView didSelectAnnotationView:view]){
            return;
        }
    }
    
    if([self.mapViewDelegate respondsToSelector:@selector(mapView:didSelectAnnotationView:)]){
        [self.mapViewDelegate mapView:mapView didSelectAnnotationView:view];
    }
}

- (void)mapView:(MAMapView *)mapView didDeselectAnnotationView:(MAAnnotationView *)view{
    if([self.mapViewDelegate respondsToSelector:@selector(mapView:didDeselectAnnotationView:)]){
        [self.mapViewDelegate mapView:mapView didDeselectAnnotationView:view];
    }
}

- (void)mapViewWillStartLocatingUser:(MAMapView *)mapView{
    if([self.mapViewDelegate respondsToSelector:@selector(mapViewWillStartLocatingUser:)]){
        [self.mapViewDelegate mapViewWillStartLocatingUser:mapView];
    }
}

- (void)mapViewDidStopLocatingUser:(MAMapView *)mapView{
    if([self.mapViewDelegate respondsToSelector:@selector(mapViewDidStopLocatingUser:)]){
        [self.mapViewDelegate mapViewDidStopLocatingUser:mapView];
    }
}

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation{
    if([self.mapViewDelegate respondsToSelector:@selector(mapView:didUpdateUserLocation:updatingLocation:)]){
        [self.mapViewDelegate mapView:mapView didUpdateUserLocation:userLocation updatingLocation:updatingLocation];
    }
}

- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error{
    if([self.mapViewDelegate respondsToSelector:@selector(mapView:didFailToLocateUserWithError:)]){
        [self.mapViewDelegate mapView:mapView didFailToLocateUserWithError:error];
    }
}

- (void)mapView:(MAMapView *)mapView annotationView:(MAAnnotationView *)view didChangeDragState:(MAAnnotationViewDragState)newState fromOldState:(MAAnnotationViewDragState)oldState{
    if([self.mapViewDelegate respondsToSelector:@selector(mapView:annotationView:didChangeDragState:fromOldState:)]){
        [self.mapViewDelegate mapView:mapView annotationView:view didChangeDragState:newState fromOldState:oldState];
    }
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay{
    if([self.mapViewDelegate respondsToSelector:@selector(mapView:rendererForOverlay:)]){
        return [self.mapViewDelegate mapView:mapView rendererForOverlay:overlay];
    }
    return nil;
}

- (void)mapView:(MAMapView *)mapView didAddOverlayRenderers:(NSArray *)overlayRenderers{
    if([self.mapViewDelegate respondsToSelector:@selector(mapView:didAddOverlayRenderers:)]){
        [self.mapViewDelegate mapView:mapView didAddOverlayRenderers:overlayRenderers];
    }
}

- (void)mapView:(MAMapView *)mapView annotationView:(MAAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    if([self.mapViewDelegate respondsToSelector:@selector(mapView:annotationView:calloutAccessoryControlTapped:)]){
        [self.mapViewDelegate mapView:mapView annotationView:view calloutAccessoryControlTapped:control];
    }
}

- (void)mapView:(MAMapView *)mapView didAnnotationViewCalloutTapped:(MAAnnotationView *)view{
    if([self.mapViewDelegate respondsToSelector:@selector(mapView:didAnnotationViewCalloutTapped:)]){
        [self.mapViewDelegate mapView:mapView didAnnotationViewCalloutTapped:view];
    }
}

- (void)mapView:(MAMapView *)mapView didAnnotationViewTapped:(MAAnnotationView *)view{
    if([self.mapViewDelegate respondsToSelector:@selector(mapView:didAnnotationViewTapped:)]){
        [self.mapViewDelegate mapView:mapView didAnnotationViewTapped:view];
    }
}

- (void)mapView:(MAMapView *)mapView didChangeUserTrackingMode:(MAUserTrackingMode)mode animated:(BOOL)animated{
    if([self.mapViewDelegate respondsToSelector:@selector(mapView:didChangeUserTrackingMode:animated:)]){
        [self.mapViewDelegate mapView:mapView didChangeUserTrackingMode:mode animated:animated];
    }
}

- (void)mapView:(MAMapView *)mapView didChangeOpenGLESDisabled:(BOOL)openGLESDisabled{
    if([self.mapViewDelegate respondsToSelector:@selector(mapView:didChangeOpenGLESDisabled:)]){
        [self.mapViewDelegate mapView:mapView didChangeOpenGLESDisabled:openGLESDisabled];
    }
}

- (void)mapView:(MAMapView *)mapView didTouchPois:(NSArray *)pois{
    if([self.mapViewDelegate respondsToSelector:@selector(mapView:didTouchPois:)]){
        [self.mapViewDelegate mapView:mapView didTouchPois:pois];
    }
}

- (void)mapView:(MAMapView *)mapView didSingleTappedAtCoordinate:(CLLocationCoordinate2D)coordinate{
    if([self.mapViewDelegate respondsToSelector:@selector(mapView:didSingleTappedAtCoordinate:)]){
        [self.mapViewDelegate mapView:mapView didSingleTappedAtCoordinate:coordinate];
    }
}

- (void)mapView:(MAMapView *)mapView didLongPressedAtCoordinate:(CLLocationCoordinate2D)coordinate{
    if([self.mapViewDelegate respondsToSelector:@selector(mapView:didLongPressedAtCoordinate:)]){
        [self.mapViewDelegate mapView:mapView didLongPressedAtCoordinate:coordinate];
    }
}

- (void)mapInitComplete:(MAMapView *)mapView{
    if([self.mapViewDelegate respondsToSelector:@selector(mapInitComplete:)]){
        [self.mapViewDelegate mapInitComplete:mapView];
    }
}

- (void)mapView:(MAMapView *)mapView didIndoorMapShowed:(MAIndoorInfo *)indoorInfo{
    if([self.mapViewDelegate respondsToSelector:@selector(mapView:didIndoorMapShowed:)]){
        [self.mapViewDelegate mapView:mapView didIndoorMapShowed:indoorInfo];
    }
}

- (void)mapView:(MAMapView *)mapView didIndoorMapFloorIndexChanged:(MAIndoorInfo *)indoorInfo{
    if([self.mapViewDelegate respondsToSelector:@selector(mapView:didIndoorMapFloorIndexChanged:)]){
        [self.mapViewDelegate mapView:mapView didIndoorMapFloorIndexChanged:indoorInfo];
    }
}

- (void)mapView:(MAMapView *)mapView didIndoorMapHidden:(MAIndoorInfo *)indoorInfo{
    if([self.mapViewDelegate respondsToSelector:@selector(mapView:didIndoorMapHidden:)]){
        [self.mapViewDelegate mapView:mapView didIndoorMapHidden:indoorInfo];
    }
}

- (void)offlineDataWillReload:(MAMapView *)mapView{
    if([self.mapViewDelegate respondsToSelector:@selector(offlineDataWillReload:)]){
        [self.mapViewDelegate offlineDataWillReload:mapView];
    }
}

- (void)offlineDataDidReload:(MAMapView *)mapView{
    if([self.mapViewDelegate respondsToSelector:@selector(offlineDataDidReload:)]){
        [self.mapViewDelegate offlineDataDidReload:mapView];
    }
}

- (void)notifyDelegateDidLayoutSubviews{
    if([self.naviDelegate respondsToSelector:@selector(naviViewDidLayoutSubviews:naviType:)]){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.naviDelegate naviViewDidLayoutSubviews:self naviType:CXMapNaviDrive];
        });
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self notifyDelegateDidLayoutSubviews];
}

@end
