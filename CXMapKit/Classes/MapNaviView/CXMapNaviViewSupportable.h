//
//  CXMapNaviViewSupportable.h
//  Pods
//
//  Created by wshaolin on 2019/4/12.
//

#import "CXMapNaviParam.h"
#import "CXMapNaviDelegate.h"

@protocol CXMapNaviViewSupportable <NSObject>

@property (nonatomic, strong, readonly) MAMapView *mapView;
@property (nonatomic, weak) id<CXMapNaviDelegate> naviDelegate;
@property (nonatomic, assign) CXMapNaviShowMode naviShowMode;
@property (nonatomic, assign, getter = isShowTraffic) BOOL showTraffic;
@property (nonatomic, assign, getter = isNaviSpeakerEnabled) BOOL naviSpeakerEnabled;
@property (nonatomic, strong, readonly) UIView *naviTopInfoView;
@property (nonatomic, strong, readonly) UIView *naviBottomInfoView;

- (BOOL)calculateRouteWithNaviParam:(CXMapNaviParam *)naviParam;
- (BOOL)recalculateRouteWithPreference:(CXMapRoutePreference *)preference; // 仅驾车导航有效
- (void)setTrackingType:(CXMapNaviTrackingType)trackingType;

@end
