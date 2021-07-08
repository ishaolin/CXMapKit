//
//  CXRouteViewController.h
//  Pods
//
//  Created by wshaolin on 2017/11/22.
//

#import "CXMapViewController.h"
#import "CXMapDrawRouteCompletionHandler.h"
#import "CXMapRouteRequestOption.h"

@class AMapPath;

@interface CXRouteViewController : CXMapViewController

@property (nonatomic, strong) UIColor *routeSolidColor; // 如果赋值了，不显示路况时路径规划显示此颜色
@property (nonatomic, assign, readonly) BOOL hasRoute;

- (void)addRouteWithOption:(CXMapRouteRequestOption *)routeOption;
- (void)addRouteWithOption:(CXMapRouteRequestOption *)routeOption
               edgePadding:(UIEdgeInsets)edgePadding;
- (void)addRouteWithOption:(CXMapRouteRequestOption *)routeOption
               edgePadding:(UIEdgeInsets)edgePadding
         completionHandler:(CXMapDrawRouteCompletionHandler)completionHandler;

- (void)addNaviRouteWithOption:(CXMapRouteRequestOption *)routeOption;
- (void)addNaviRouteWithOption:(CXMapRouteRequestOption *)routeOption
                   edgePadding:(UIEdgeInsets)edgePadding;
- (void)addNaviRouteWithOption:(CXMapRouteRequestOption *)routeOption
                   edgePadding:(UIEdgeInsets)edgePadding
             completionHandler:(CXMapDrawNaviRouteCompletionHandler)completionHandler;

- (void)addRouteWithCoordinates:(NSArray<NSValue *> *)coordinates;
- (void)addRouteWithCoordinates:(NSArray<NSValue *> *)coordinates lineWidth:(CGFloat)lineWidth;

- (void)switchRoutePath:(AMapPath *)mapPath;
- (void)switchRoutePath:(AMapPath *)mapPath edgePadding:(UIEdgeInsets)edgePadding;

- (void)switchNaviRoute:(AMapNaviRoute *)naviRoute;
- (void)switchNaviRoute:(AMapNaviRoute *)naviRoute edgePadding:(UIEdgeInsets)edgePadding;

- (void)removeRoute;

- (void)setVisibleMapRectForRoute;
- (void)setVisibleMapRectForRouteEdgePadding:(UIEdgeInsets)edgePadding;

@end
