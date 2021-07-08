//
//  CXPOIDragViewController.m
//  Pods
//
//  Created by wshaolin on 2019/4/15.
//

#import "CXPOIDragViewController.h"
#import "CXLocationManager.h"
#import "CXMapSearcher.h"
#import "CXPOIDragInfoView.h"
#import "CXMapKitDefines.h"

@interface CXPOIDragViewController() <CXLocationManagerDelegate, CXPOIDragInfoViewDelegate> {
    UIImageView *_pointView;
    CXPOIDragInfoView *_infoView;
}

@end

@implementation CXPOIDragViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"地图选点";
    self.showsUserLocation = NO;
    self.navigationBar.shadowEnabled = YES;
    
    _pointView = [[UIImageView alloc] init];
    _pointView.image = CX_MAPKIT_IMAGE(@"map_poi_drag_point");
    CGFloat pointView_W = 24.0;
    CGFloat pointView_H = pointView_W;
    CGFloat pointView_X = (CGRectGetWidth(self.view.bounds) - pointView_W) * 0.5;
    CGFloat pointView_Y = (CGRectGetHeight(self.view.bounds) - pointView_H) * 0.5;
    _pointView.frame = (CGRect){pointView_X, pointView_Y, pointView_W, pointView_H};
    [self.view addSubview:_pointView];
    
    _infoView = [[CXPOIDragInfoView alloc] init];
    _infoView.delegate = self;
    CXShadowView *infoShadowView = [[CXShadowView alloc] initWithShadowOptions:CXShadowAll cornerRadii:4.0];
    CGFloat infoShadowView_X = CX_MARGIN(15.0);
    CGFloat infoShadowView_H = 80.0;
    CGFloat infoShadowView_W = CGRectGetWidth(self.view.bounds) - infoShadowView_X * 2;
    CGFloat infoShadowView_Y = CGRectGetHeight(self.view.bounds) - infoShadowView_H - MAX(infoShadowView_X, [UIScreen mainScreen].cx_safeAreaInsets.bottom);
    infoShadowView.frame = (CGRect){infoShadowView_X, infoShadowView_Y, infoShadowView_W, infoShadowView_H};
    [infoShadowView addSubview:_infoView];
    _infoView.frame = infoShadowView.bounds;
    [_infoView cx_roundedCornerRadii:4.0];
    [self.view addSubview:infoShadowView];
    
    CLLocation *location = [CXLocationManager sharedManager].location;
    [self setCenterCoordinate:location.coordinate zoomLevel:CXMapViewDefaultZoomLevel animated:YES];
    [CXMapSearcher reverseGeoCodeSearch:location.coordinate completionHandler:^(CXMapPOIModel *POIModel) {
        [self POIInfoDidUpdate:POIModel];
    }];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    _pointView.center = self.view.center;
}

- (void)POIInfoWillUpdate{
    [_infoView willUpdateInfo];
}

- (void)POIInfoDidUpdate:(CXMapPOIModel *)POIModel{
    if([self.delegate respondsToSelector:@selector(POIDragViewController:didUpdatePOIModel:)]){
        [self.delegate POIDragViewController:self didUpdatePOIModel:POIModel];
    }
    
    [_infoView setUpdateInfoWithPOIModel:POIModel];
}

- (void)mapViewWillMoveByUser:(BOOL)wasUserAction{
    if(!wasUserAction){
        return;
    }
    
    [self POIInfoWillUpdate];
    
    if([self.delegate respondsToSelector:@selector(POIDragViewControllerWillMoveMapByUser:)]){
        [self.delegate POIDragViewControllerWillMoveMapByUser:self];
    }
}

- (void)mapViewDidMoveByUser:(BOOL)wasUserAction{
    if(!wasUserAction){
        return;
    }
    
    CGPoint point = (CGPoint){CGRectGetMidX(_pointView.frame), CGRectGetMaxY(_pointView.frame)};
    CLLocationCoordinate2D coordinate = [self.mapView convertPoint:point toCoordinateFromView:nil];
    [CXMapSearcher reverseGeoCodeSearch:coordinate completionHandler:^(CXMapPOIModel *POIModel) {
        [self POIInfoDidUpdate:POIModel];
    }];
}

- (void)POIDragInfoView:(CXPOIDragInfoView *)infoView didConfirmWithPOIModel:(CXMapPOIModel *)POIModel{
    if([self.delegate respondsToSelector:@selector(POIDragViewController:didSelectedPOIModel:)]){
        [self.delegate POIDragViewController:self didSelectedPOIModel:POIModel];
    }
}

@end
