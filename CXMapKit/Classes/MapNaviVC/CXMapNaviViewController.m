//
//  CXMapNaviViewController.m
//  Pods
//
//  Created by lcc on 2018/6/19.
//

#import "CXMapNaviViewController.h"
#import "CXLocationManager.h"
#import "CXMapNaviDriveView.h"
#import "CXMapNaviRideView.h"
#import "CXMapNaviWalkView.h"
#import "CXMapPOIModel.h"
#import "CXMapRouteRequestOption.h"
#import "AMapNaviRoute+CXMapKit.h"
#import "CXMapSpeedView.h"
#import "CXMapRoutePreferenceView.h"

@interface CXMapNaviViewController () <CXMapRoutePreferenceViewDelegate> {
    CXMapSpeedView *_speedView;
    CXMapRoutePreferenceView *_preferenceView;
    
    UIButton *_fullViewButton;
    UIButton *_speakerButton;
    UIButton *_orientationButton;
}

@property (nonatomic, strong) UIView<CXMapNaviViewSupportable> *naviView;

@end

@implementation CXMapNaviViewController

- (UIView<CXMapNaviViewSupportable> *)naviView{
    if(_naviView){
        return _naviView;
    }
    
    switch (_naviParam.naviType) {
        case CXMapNaviDrive:
            _naviView = [[CXMapNaviDriveView alloc] init];
            _naviView.naviDelegate = self;
            break;
        case CXMapNaviRide:
            _naviView = [[CXMapNaviRideView alloc] init];
            _naviView.naviDelegate = self;
            break;
        case CXMapNaviWalk:{
            _naviView = [[CXMapNaviWalkView alloc] init];
            _naviView.naviDelegate = self;
        }
            break;
        default:
            break;
    }
    
    return _naviView;
}

- (MAMapView *)mapView{
    return self.naviView.mapView;
}

- (CGRect)speakerRect{
    return _speakerButton.frame;
}

- (void)setShowTraffic:(BOOL)showTraffic{
    self.naviView.showTraffic = showTraffic;
}

- (BOOL)isShowTraffic{
    return self.naviView.isShowTraffic;
}

- (void)setNaviSpeakerEnabled:(BOOL)naviSpeakerEnabled{
    self.naviView.naviSpeakerEnabled = naviSpeakerEnabled;
}

- (BOOL)isNaviSpeakerEnabled{
    return self.naviView.isNaviSpeakerEnabled;
}

- (void)setNaviShowMode:(CXMapNaviShowMode)naviShowMode{
    self.naviView.naviShowMode = naviShowMode;
}

- (CXMapNaviShowMode)naviShowMode{
    return self.naviView.naviShowMode;
}

- (void)setTrackingType:(CXMapNaviTrackingType)trackingType{
    _trackingType = trackingType;
    _fullViewButton.selected = NO;
    self.naviView.naviShowMode = CXMapNaviShowModeCarPositionLocked;
    [self.naviView setTrackingType:trackingType];
    
    switch (trackingType) {
        case CXMapNaviTracking2D:{
            [_orientationButton setImage:CX_MAPKIT_IMAGE(@"map_navi_tracking_2d") forState:UIControlStateNormal];
        }
            break;
        case CXMapNaviTracking3D:{
            [_orientationButton setImage:CX_MAPKIT_IMAGE(@"map_navi_tracking_3d") forState:UIControlStateNormal];
        }
            break;
        case CXMapNaviTrackingNorth:{
            [_orientationButton setImage:CX_MAPKIT_IMAGE(@"map_navi_tracking_north") forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (instancetype)initWithNaviParam:(CXMapNaviParam *)naviParam{
    if(self = [super init]){
        _naviParam = naviParam;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationBar.hidden = YES;
    self.naviView.frame = self.view.bounds;
    [self.view addSubview:self.naviView];
    
    _speedView = [[CXMapSpeedView alloc]init];
    _speedView.layer.cornerRadius = 32.0;
    _speedView.layer.borderWidth = 4.0;
    _speedView.layer.borderColor = CXHexIColor(0x1DBEFF).CGColor;
    _speedView.hidden = YES;
    [self.view addSubview:_speedView];
    
    _fullViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_fullViewButton setBackgroundImage:CX_MAPKIT_IMAGE(@"map_navi_full_view_selected_0") forState:UIControlStateNormal];
    [_fullViewButton setBackgroundImage:CX_MAPKIT_IMAGE(@"map_navi_full_view_selected_1") forState:UIControlStateSelected];
    [_fullViewButton addTarget:self action:@selector(handleActionForFullViewButton:) forControlEvents:UIControlEventTouchUpInside];
    _fullViewButton.hidden = YES;
    [self.view addSubview:_fullViewButton];
    
    _speakerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_speakerButton setBackgroundImage:CX_MAPKIT_IMAGE(@"map_navi_speaker_off") forState:UIControlStateNormal];
    [_speakerButton setBackgroundImage:CX_MAPKIT_IMAGE(@"map_navi_speaker_on") forState:UIControlStateSelected];
    [_speakerButton addTarget:self action:@selector(handleActionForSpeakerButton:) forControlEvents:UIControlEventTouchUpInside];
    _speakerButton.selected = YES;
    _speakerButton.hidden = YES;
    [self.view addSubview:_speakerButton];
    
    if(_naviParam.naviType == CXMapNaviDrive){
        _preferenceView = [[CXMapRoutePreferenceView alloc] init];
        _preferenceView.preference = _naviParam.preference;
        _preferenceView.delegate = self;
        _preferenceView.hidden = YES;
        [self.view addSubview:_preferenceView];
        
        _orientationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _orientationButton.hidden = YES;
        [_orientationButton addTarget:self action:@selector(handleActionForOrientationButton:) forControlEvents:UIControlEventTouchUpInside];
        [_orientationButton setImage:CX_MAPKIT_IMAGE(@"map_navi_tracking_2d") forState:UIControlStateNormal];
        [self.view addSubview:_orientationButton];
    }
    
    [self.naviView calculateRouteWithNaviParam:_naviParam];
}

#pragma mark - CXMapNaviDelegate

- (void)naviViewDidLayoutSubviews:(UIView *)naviView naviType:(CXMapNaviType)naviType{
    _speedView.hidden = NO;
    _fullViewButton.hidden = NO;
    _speakerButton.hidden = NO;
    _preferenceView.hidden = NO;
    _orientationButton.hidden = NO;
    
    CGFloat speedView_X = 15.0;
    CGFloat speedView_Y = 0;
    CGFloat speedView_H = 64.0;
    CGFloat speedView_W = speedView_H;
    if(naviType == CXMapNaviDrive){
        UIView *laneInfoView = [self.naviView valueForKey:@"laneInfoView"];
        speedView_Y = CGRectGetMinY(laneInfoView.frame);
        
        CGFloat preferenceView_W = 80.0;
        CGFloat preferenceView_H = 30.0;
        CGFloat preferenceView_X = 15.0;
        CGFloat preferenceView_Y = CGRectGetMinY(self.naviView.naviBottomInfoView.frame) - preferenceView_H - preferenceView_X;
        _preferenceView.frame = (CGRect){preferenceView_X, preferenceView_Y, preferenceView_W, preferenceView_H};
        
        CGFloat orientationButton_W = 46.0;
        CGFloat orientationButton_H = orientationButton_W;
        CGFloat orientationButton_X = 11.0;
        CGFloat orientationButton_Y = preferenceView_Y - orientationButton_H - 5.0;
        _orientationButton.frame = (CGRect){orientationButton_X, orientationButton_Y, orientationButton_W, orientationButton_H};
        
        CGPoint logoCenter = self.naviView.mapView.logoCenter;
        logoCenter.x = CGRectGetMaxX(self.naviView.frame) - 48.0;
        self.naviView.mapView.logoCenter = logoCenter;
    }else{
        speedView_Y = CGRectGetMaxY(self.naviView.naviTopInfoView.frame) + 10.0;
    }
    _speedView.frame = (CGRect){speedView_X, speedView_Y, speedView_W, speedView_H};
    
    CGFloat fullViewButton_W = 47.0;
    CGFloat fullViewButton_H = fullViewButton_W;
    CGFloat fullViewButton_X = CGRectGetWidth(self.view.frame) - fullViewButton_W - 10.0;
    CGFloat fullViewButton_Y = speedView_Y;
    _fullViewButton.frame = (CGRect){fullViewButton_X, fullViewButton_Y, fullViewButton_W, fullViewButton_H};
    
    CGFloat speakerButton_W = fullViewButton_W;
    CGFloat speakerButton_H = speakerButton_W;
    CGFloat speakerButton_X = fullViewButton_X;
    CGFloat speakerButton_Y = CGRectGetMaxY(_fullViewButton.frame);
    _speakerButton.frame = (CGRect){speakerButton_X, speakerButton_Y, speakerButton_W, speakerButton_H};
}

- (void)naviManager:(AMapNaviBaseManager *)manager naviType:(CXMapNaviType)naviType updateNaviLocation:(AMapNaviLocation *)naviLocation{
    if(naviLocation && naviLocation.speed >= 0){
        _speedView.speed = [NSString stringWithFormat:@"%ld", (long)naviLocation.speed];
    }else{
        _speedView.speed = @"--";
    }
}

- (void)naviView:(UIView *)driveView didChangeShowMode:(CXMapNaviShowMode)showMode naviType:(CXMapNaviType)naviType{
    if(showMode == CXMapNaviShowModeCarPositionLocked){
        _fullViewButton.selected = NO;
    }else if(showMode == CXMapNaviShowModeOverview){
        _fullViewButton.selected = YES;
    }
}

- (void)naviView:(UIView *)naviView closeForNaviType:(CXMapNaviType)naviType completion:(void (^)(BOOL))completion{
    [CXAlertControllerUtils showAlertWithConfigBlock:^(CXAlertControllerConfigModel *config) {
        config.title = @"确认退出导航吗？";
        config.buttonTitles = @[@"取消", @"退出"];
    } completion:^(NSUInteger buttonIndex) {
        if(buttonIndex == 1){
            !completion ?:completion(YES);
            [[CXLocationManager sharedManager] reloadLocation];
            [self didClickBackBarButtonItem:self.navigationBar.navigationItem.backBarButtonItem];
            !self.quitCompletion ?: self.quitCompletion(self, self->_preferenceView.preference ?: self->_naviParam.preference);
            self.quitCompletion = nil;
        }
    }];
}

- (void)naviManagerOnArrivedDestination:(AMapNaviBaseManager *)manager naviType:(CXMapNaviType)naviType{
    [manager stopNavi];
}

- (void)routePreferenceView:(CXMapRoutePreferenceView *)preferenceView didChangePreference:(CXMapRoutePreference *)preference{
    [self.naviView recalculateRouteWithPreference:preference];
}

- (void)handleActionForFullViewButton:(UIButton *)fullViewButton{
    _fullViewButton.selected = !fullViewButton.isSelected;
    
    if(self.naviShowMode == CXMapNaviShowModeOverview){
        self.naviShowMode = CXMapNaviShowModeCarPositionLocked;
    }else{
        self.naviShowMode = CXMapNaviShowModeOverview;
    }
}

- (void)handleActionForSpeakerButton:(UIButton *)speakerButton{
    speakerButton.selected = !speakerButton.isSelected;
    self.naviSpeakerEnabled = speakerButton.isSelected;
}

- (void)handleActionForOrientationButton:(UIButton *)orientationButton{
    self.trackingType = (self.trackingType + 1) % 3;
}

- (CXAnimatedTransitioningStyle)animatedTransitioningStyle{
    return CXAnimatedTransitioningStyleCoverVertical;
}

@end
