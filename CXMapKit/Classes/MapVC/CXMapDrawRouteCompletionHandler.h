//
//  CXMapDrawRouteCompletionHandler.h
//  Pods
//
//  Created by wshaolin on 2017/11/22.
//

#ifndef CXMapDrawRouteCompletionHandler_h
#define CXMapDrawRouteCompletionHandler_h

#import <Foundation/Foundation.h>

@class CXRouteViewController;
@class AMapRoute;
@class AMapNaviRoute;

typedef void(^CXMapDrawRouteCompletionHandler)(CXRouteViewController *viewController,
                                               AMapRoute *mapRoute,
                                               NSError *error);

typedef void(^CXMapDrawNaviRouteCompletionHandler)(CXRouteViewController *viewController,
                                                   NSArray<AMapNaviRoute *> *naviRoutes,
                                                   NSError *error);

#endif /* CXMapDrawRouteCompletionHandler_h */
