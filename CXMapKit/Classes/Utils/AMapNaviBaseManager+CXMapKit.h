//
//  AMapNaviBaseManager+CXMapKit.h
//  Pods
//
//  Created by lcc on 2018/6/20.
//

#import <AMapNaviKit/AMapNaviKit.h>
#import "CXMapDrawRouteCompletionHandler.h"

@class CXMapRouteRequestOption;

@interface AMapNaviBaseManager (CXMapKit)

@property (nonatomic, strong) CXMapRouteRequestOption *routeOption;
@property (nonatomic, copy) CXMapDrawNaviRouteCompletionHandler completionHandler;
@property (nonatomic, assign) UIEdgeInsets edgePadding;

- (void)invokeHandler:(CXRouteViewController *)viewController
           naviRoutes:(NSDictionary<NSNumber *, AMapNaviRoute *> *)naviRoutes
                error:(NSError *)error;

@end
