//
//  CXMapViewController.h
//  Pods
//
//  Created by wshaolin on 2017/11/22.
//

#import <CXUIKit/CXUIKit.h>
#import <AMapNaviKit/AMapNaviKit.h>

#define CXMapViewDefaultZoomLevel 15.0

@class CXPointAnnotation;
@class CXMapPOIModel;
@class CXUserLocationView;

@interface CXMapViewController : CXBaseViewController

@property (nonatomic, strong, readonly) NSArray<CXPointAnnotation *> *annotations;
@property (nonatomic, strong, readonly) MAMapView *mapView;

@property (nonatomic, strong, readonly) MAUserLocation *userLocation;
@property (nonatomic, strong, readonly) CXUserLocationView *userLocationView;

@property (nonatomic, assign, getter = isShowsUserLocation) BOOL showsUserLocation;

@property (nonatomic, assign) UIEdgeInsets mainContentInset;

@property (nonatomic, assign, getter = isEnableDefaultsAnimation) BOOL enableDefaultsAnimation; // 默认YES

- (instancetype)initWithContainsMapView:(BOOL)containsMapView;

@property (nonatomic, assign) CGFloat zoomLevel;
@property (nonatomic, assign) CGFloat minZoomLevel;
@property (nonatomic, assign) CGFloat maxZoomLevel;

- (void)setZoomLevel:(CGFloat)zoomLevel animated:(BOOL)animated;

@property (nonatomic, assign, getter = isShowTraffic) BOOL showTraffic;
@property (nonatomic, assign, getter = isShowsLabels) BOOL showsLabels;
@property (nonatomic, assign) MAUserTrackingMode userTrackingMode;
@property (nonatomic, strong) NSDictionary<NSNumber *, UIColor *> *trafficColor;
@property (nonatomic, assign) CGPoint screenAnchor;

- (void)setUserLocationInMapViewCenterAnimated:(BOOL)animated;

@property (nonatomic, assign) CLLocationCoordinate2D centerCoordinate;
- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate animated:(BOOL)animated;
- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate zoomLevel:(CGFloat)zoomLevel animated:(BOOL)animated;
- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate zoomLevel:(CGFloat)zoomLevel screenAnchor:(CGPoint)screenAnchor animated:(BOOL)animated;

- (void)addAnnotation:(CXPointAnnotation *)annotation;
- (void)addAnnotations:(NSArray<CXPointAnnotation *> *)annotations;
- (void)removeAnnotation:(CXPointAnnotation *)annotation;
- (void)removeAnnotations:(NSArray<CXPointAnnotation *> *)annotations;
- (void)selectAnnotation:(CXPointAnnotation *)annotation animated:(BOOL)animated;
- (void)deselectAnnotation:(CXPointAnnotation *)annotation animated:(BOOL)animated;
- (void)showAnnotations:(NSArray<CXPointAnnotation *> *)annotations animated:(BOOL)animated;
- (void)showAnnotations:(NSArray<CXPointAnnotation *> *)annotations edgePadding:(UIEdgeInsets)insets animated:(BOOL)animated;

// 包括自己的位置，如果showsUserLocation = YES
- (void)showAllAnnotationsWithEdgePadding:(UIEdgeInsets)insets animated:(BOOL)animated;
- (void)showAllAnnotationsAnimated:(BOOL)animated;

- (void)setAnnotation:(CXPointAnnotation *)annotation coordinate:(CLLocationCoordinate2D)coordinate;

- (double)metersPerPointForCurrentZoomLevel;

- (void)setCustomMapStyleOptions:(MAMapCustomStyleOptions *)options;

- (void)setVisibleMapRectForCoordinates:(NSArray<NSValue *> *)coordinates;

- (void)setVisibleMapRectForCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count;

- (void)takeSnapshotInRect:(CGRect)rect completion:(void (^)(UIImage *image, NSInteger state))completion;

#pragma mark - 处理回调, 供子类使用

- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view;
- (void)mapView:(MAMapView *)mapView didDeselectAnnotationView:(MAAnnotationView *)view;

- (void)mapView:(MAMapView *)mapView didAddAnnotationViews:(NSArray *)views;
- (void)mapView:(MAMapView *)mapView didSingleTappedAtCoordinate:(CLLocationCoordinate2D)coordinate;

- (void)didSelectedAnnotation:(CXPointAnnotation *)annotation;
- (void)didUpdateUserLocation:(MAUserLocation *)userLocation;

- (void)mapViewWillMoveByUser:(BOOL)wasUserAction;
- (void)mapViewDidMoveByUser:(BOOL)wasUserAction;

- (void)mapViewWillZoomByUser:(BOOL)wasUserAction;
- (void)mapViewDidZoomByUser:(BOOL)wasUserAction;

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForPointAnnotation:(CXPointAnnotation *)annotation;
- (CXUserLocationView *)mapView:(MAMapView *)mapView viewForUserLocation:(MAUserLocation *)userLocation;

- (MAUserLocationRepresentation *)userLocationRepresentation;

@end
