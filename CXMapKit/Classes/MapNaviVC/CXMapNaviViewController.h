//
//  CXMapNaviViewController.h
//  Pods
//
//  Created by lcc on 2018/6/19.
//

#import <CXUIKit/CXUIKit.h>
#import "CXMapNaviParam.h"
#import "CXMapNaviDelegate.h"
#import "CXMapNaviViewSupportable.h"

@class CXMapNaviViewController;

typedef void(^CXMapNaviVCQuitCompletionBlock)(CXMapNaviViewController *naviVC, CXMapRoutePreference *preference);

@interface CXMapNaviViewController : CXBaseViewController <CXMapNaviDelegate, CXAnimatedTransitioningSupporter>

@property (nonatomic, strong, readonly) MAMapView *mapView;
@property (nonatomic, strong, readonly) CXMapNaviParam *naviParam;
@property (nonatomic, assign, readonly) CGRect speakerRect;
@property (nonatomic, assign) CXMapNaviShowMode naviShowMode;
@property (nonatomic, assign, getter = isShowTraffic) BOOL showTraffic;
@property (nonatomic, assign, getter = isNaviSpeakerEnabled) BOOL naviSpeakerEnabled;
@property (nonatomic, assign) CXMapNaviTrackingType trackingType;
@property (nonatomic, copy) CXMapNaviVCQuitCompletionBlock quitCompletion;

- (instancetype)initWithNaviParam:(CXMapNaviParam *)naviParam;

- (void)naviViewDidLayoutSubviews:(UIView *)naviView naviType:(CXMapNaviType)naviType;

@end
