//
//  CXMapNaviWalkView.m
//  Pods
//
//  Created by lcc on 2018/6/19.
//

#import "CXMapNaviWalkView.h"
#import <CXUIKit/CXUIKit.h>
#import "CXMapWebData.h"
#import "CXLocationManager.h"
#import "CXSpeechSynthesizer.h"

@interface AMapNaviWalkView () <MAMapViewDelegate> {
    
}

@end

@interface CXMapNaviWalkView() <AMapNaviWalkManagerDelegate, AMapNaviWalkViewDelegate> {
    UIView *_bottomInfoBackgroundView;
    AMapNaviWalkManager *_naviWalkManager;
}

@end

@implementation CXMapNaviWalkView

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        _bottomInfoBackgroundView = [[UIView alloc] init];
        _bottomInfoBackgroundView.backgroundColor = CXHexIColor(0x282C37);
        
        _naviWalkManager = [AMapNaviWalkManager sharedInstance];
        _naviWalkManager.delegate = self;
        _naviWalkManager.isUseInternalTTS = NO;
        [_naviWalkManager addDataRepresentative:self];
        
        self.delegate = self;
        self.mapView.rotateEnabled = NO;
        self.mapView.rotateCameraEnabled = NO;
        self.mapView.trafficStatus = @{@(MATrafficStatusSmooth) : [UIColor clearColor]};
        
        self.cameraDegree = 0.0;
        self.showBrowseRouteButton = NO;
        self.showMoreButton = NO;
        self.showScale = NO;
        self.showTurnArrow = YES;
        self.cameraDegree = 0;
        self.trackingMode = AMapNaviViewTrackingModeCarNorth; // 车头朝北
        
        UIButton *zoomInButton = [self valueForKey:@"zoomInButton"];
        UIButton *zoomOutButton = [self valueForKey:@"zoomOutButton"];
        zoomInButton.hidden = YES;
        zoomOutButton.hidden = YES;
    }
    
    return self;
}

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
            self.showMode = AMapNaviWalkViewShowModeCarPositionLocked;
        }
            break;
        case CXMapNaviShowModeOverview:{
            self.showMode = AMapNaviWalkViewShowModeOverview;
        }
            break;
        case CXMapNaviShowModeNormal:{
            self.showMode = AMapNaviWalkViewShowModeNormal;
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

- (BOOL)calculateRouteWithNaviParam:(CXMapNaviParam *)naviParam{
    AMapNaviPoint *startPoint = CXMapNaviPointFromCoordinate(naviParam.startCoordinate);
    AMapNaviPoint *endPoint = CXMapNaviPointFromCoordinate(naviParam.endCoordinate);
    if(naviParam.naviRoute){
        startPoint = naviParam.naviRoute.routeStartPoint;
        endPoint = naviParam.naviRoute.routeEndPoint;
    }
    
    if(startPoint){
        return [_naviWalkManager calculateWalkRouteWithStartPoints:@[startPoint]
                                                         endPoints:@[endPoint]];
    }else{
        return [_naviWalkManager calculateWalkRouteWithEndPoints:@[endPoint]];
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

- (BOOL)recalculateRouteWithPreference:(CXMapRoutePreference *)preference {
    return NO;
}

#pragma mark - AMapNaviWalkDataRepresentable

- (void)walkManager:(AMapNaviWalkManager *)walkManager updateNaviInfo:(nullable AMapNaviInfo *)naviInfo{
    if([super respondsToSelector:@selector(walkManager:updateNaviInfo:)]){
        [super walkManager:walkManager updateNaviInfo:naviInfo];
    }
    
    if([self.naviDelegate respondsToSelector:@selector(naviManager:naviType:updateNaviInfo:)]){
        [self.naviDelegate naviManager:walkManager naviType:CXMapNaviWalk updateNaviInfo:naviInfo];
    }
}

- (void)walkManager:(AMapNaviWalkManager *)walkManager updateNaviLocation:(nullable AMapNaviLocation *)naviLocation{
    if([super respondsToSelector:@selector(walkManager:updateNaviLocation:)]){
        [super walkManager:walkManager updateNaviLocation:naviLocation];
    }
    
    if([self.naviDelegate respondsToSelector:@selector(naviManager:naviType:updateNaviLocation:)]){
        [self.naviDelegate naviManager:walkManager naviType:CXMapNaviWalk updateNaviLocation:naviLocation];
    }
}

#pragma mark - MAMapViewDelegate

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation{
    if([self.naviDelegate respondsToSelector:@selector(mapView:viewForAnnotation:)]){
        MAAnnotationView *annotationView = [self.naviDelegate mapView:mapView viewForAnnotation:annotation];
        if(annotationView){
            return annotationView;
        }
    }
    
    return [super mapView:mapView viewForAnnotation:annotation];
}

- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view{
    if([self.naviDelegate respondsToSelector:@selector(mapView:didSelectAnnotationView:)]){
        if([self.naviDelegate mapView:mapView didSelectAnnotationView:view]){
            return;
        }
    }
    
    if([self.superclass instancesRespondToSelector:@selector(mapView:didSelectAnnotationView:)]){
        [super mapView:mapView didSelectAnnotationView:view];
    }
}

#pragma mark - AMapNaviWalkManagerDelegate

- (void)walkManager:(AMapNaviWalkManager *)walkManager error:(NSError *)error{
    if([self.naviDelegate respondsToSelector:@selector(naviManager:naviType:error:)]){
        [self.naviDelegate naviManager:walkManager naviType:CXMapNaviWalk error:error];
    }
}

- (void)walkManagerOnCalculateRouteSuccess:(AMapNaviWalkManager *)walkManager{
    if([walkManager startGPSNavi]){
        if([self.naviDelegate respondsToSelector:@selector(naviManagerOnCalculateRouteSuccess:naviType:)]){
            [self.naviDelegate naviManagerOnCalculateRouteSuccess:walkManager naviType:CXMapNaviWalk];
        }
    }
}

- (void)walkManager:(AMapNaviWalkManager *)walkManager onCalculateRouteFailure:(NSError *)error{
    if([self.naviDelegate respondsToSelector:@selector(naviManager:naviType:onCalculateRouteFailure:)]){
        [self.naviDelegate naviManager:walkManager naviType:CXMapNaviWalk onCalculateRouteFailure:error];
    }
}

- (void)walkManager:(AMapNaviWalkManager *)walkManager didStartNavi:(AMapNaviMode)naviMode{
    if([self.naviDelegate respondsToSelector:@selector(naviManager:naviType:didStartNavi:)]){
        [self.naviDelegate naviManager:walkManager naviType:CXMapNaviWalk didStartNavi:naviMode];
    }
}

- (void)walkManagerDidEndEmulatorNavi:(AMapNaviWalkManager *)walkManager{
    if([self.naviDelegate respondsToSelector:@selector(naviManagerOnArrivedDestination:naviType:)]){
        [self.naviDelegate naviManagerOnArrivedDestination:walkManager naviType:CXMapNaviWalk];
    }
}

- (void)walkManagerOnArrivedDestination:(AMapNaviWalkManager *)walkManager{
    if([self.naviDelegate respondsToSelector:@selector(naviManagerOnArrivedDestination:naviType:)]) {
        [self.naviDelegate naviManagerOnArrivedDestination:walkManager naviType:CXMapNaviWalk];
    }
}

- (void)walkManager:(AMapNaviWalkManager *)walkManager playNaviSoundString:(NSString *)soundString soundStringType:(AMapNaviSoundType)soundStringType{
    [[CXSpeechSynthesizer sharedSynthesizer] speakWord:soundString];
}

#pragma mark - AMapNaviWalkViewDelegate

- (void)walkViewCloseButtonClicked:(AMapNaviWalkView *)walkView{
    if([self.naviDelegate respondsToSelector:@selector(naviView:closeForNaviType:completion:)]){
        [self.naviDelegate naviView:self closeForNaviType:CXMapNaviRide completion:^(BOOL finished) {
            if(finished){
                [self stopWalkNavi];
            }
        }];
    }
}

- (void)walkView:(AMapNaviWalkView *)walkView didChangeShowMode:(AMapNaviWalkViewShowMode)showMode{
    if([self.naviDelegate respondsToSelector:@selector(naviView:didChangeShowMode:naviType:)]){
        [self.naviDelegate naviView:walkView didChangeShowMode:(CXMapNaviShowMode)showMode naviType:CXMapNaviWalk];
    }
}

- (void)notifyDelegateDidLayoutSubviews{
    if([self.naviDelegate respondsToSelector:@selector(naviViewDidLayoutSubviews:naviType:)]){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.naviDelegate naviViewDidLayoutSubviews:self naviType:CXMapNaviWalk];
        });
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    UIView *bottomInfoView = self.naviBottomInfoView;
    bottomInfoView.backgroundColor = CXHexIColor(0x282C37);
    
    UIView *splitViewLeft = [bottomInfoView valueForKey:@"splitViewLeft"];
    splitViewLeft.hidden = YES;
    
    if([UIScreen mainScreen].cx_isBangs){
        self.backgroundColor = CXHexIColor(0x282C37);
        UIView *topInfoView = self.naviTopInfoView;
        CGRect topInfoViewFrame = topInfoView.frame;
        topInfoViewFrame.origin.y = 30.0;
        topInfoView.frame = topInfoViewFrame;
        
        if(!_bottomInfoBackgroundView.superview){
            [self addSubview:_bottomInfoBackgroundView];
        }
        
        CGFloat bottomInfoBackgroundView_W = CGRectGetWidth(self.bounds);
        CGFloat bottomInfoBackgroundView_H = [UIScreen mainScreen].cx_safeAreaInsets.bottom;
        CGFloat bottomInfoBackgroundView_X = 0;
        CGFloat bottomInfoBackgroundView_Y = CGRectGetHeight(self.bounds) - bottomInfoBackgroundView_H;
        _bottomInfoBackgroundView.frame = (CGRect){bottomInfoBackgroundView_X, bottomInfoBackgroundView_Y, bottomInfoBackgroundView_W, bottomInfoBackgroundView_H};
        
        CGRect bottomInfoViewFrame = bottomInfoView.frame;
        bottomInfoViewFrame.origin.y = bottomInfoBackgroundView_Y - bottomInfoViewFrame.size.height;
        bottomInfoView.frame = bottomInfoViewFrame;
    }
    
    [self notifyDelegateDidLayoutSubviews];
}

- (void)stopWalkNavi{
    if(!_naviWalkManager){
        return;
    }
    
    [[CXSpeechSynthesizer sharedSynthesizer] stop];
    [_naviWalkManager stopNavi];
    [AMapNaviWalkManager destroyInstance];
    _naviWalkManager = nil;
}

- (void)dealloc{
    [self stopWalkNavi];
}

@end
