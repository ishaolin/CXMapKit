//
//  AMapDrivingRouteSearchRequest+CXMapKit.h
//  Pods
//
//  Created by wshaolin on 2017/11/22.
//

#import <AMapSearchKit/AMapSearchKit.h>
#import "CXMapDrawRouteCompletionHandler.h"

@class CXMapRouteRequestOption;

@interface AMapDrivingRouteSearchRequest (CXMapKit)

- (instancetype)initWithStartCoordinate:(CLLocationCoordinate2D)startCoordinate
                          endCoordinate:(CLLocationCoordinate2D)endCoordinate;

@end

@interface AMapRouteSearchBaseRequest (CXMapKit)

@property (nonatomic, copy) CXMapDrawRouteCompletionHandler completionHandler;
@property (nonatomic, strong) CXMapRouteRequestOption *routeOption;
@property (nonatomic, assign) UIEdgeInsets edgePadding;

- (void)invokeHandler:(CXRouteViewController *)viewController
             mapRoute:(AMapRoute *)mapRoute
                error:(NSError *)error;
@end
