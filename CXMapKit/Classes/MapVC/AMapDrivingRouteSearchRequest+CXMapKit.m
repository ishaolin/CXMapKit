//
//  AMapDrivingRouteSearchRequest+CXMapKit.m
//  Pods
//
//  Created by wshaolin on 2017/11/22.
//

#import "AMapDrivingRouteSearchRequest+CXMapKit.h"
#import <objc/runtime.h>

@implementation AMapDrivingRouteSearchRequest (CXMapKit)

- (instancetype)initWithStartCoordinate:(CLLocationCoordinate2D)startCoordinate endCoordinate:(CLLocationCoordinate2D)endCoordinate{
    if(self = [super init]){
        self.strategy = 5;
        
        self.origin = [AMapGeoPoint locationWithLatitude:startCoordinate.latitude
                                               longitude:startCoordinate.longitude];
        
        self.destination = [AMapGeoPoint locationWithLatitude:endCoordinate.latitude
                                                    longitude:endCoordinate.longitude];
    }
    
    return self;
}

@end

@implementation AMapRouteSearchBaseRequest (CXMapKit)

- (void)setCompletionHandler:(CXMapDrawRouteCompletionHandler)completionHandler{
    objc_setAssociatedObject(self, @selector(completionHandler), completionHandler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CXMapDrawRouteCompletionHandler)completionHandler{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setRouteOption:(CXMapRouteRequestOption *)routeOption{
    objc_setAssociatedObject(self, @selector(routeOption), routeOption, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CXMapRouteRequestOption *)routeOption{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setEdgePadding:(UIEdgeInsets)edgePadding{
    NSValue *value = [NSValue valueWithUIEdgeInsets:edgePadding];
    objc_setAssociatedObject(self, @selector(edgePadding), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIEdgeInsets)edgePadding{
    NSValue *value = objc_getAssociatedObject(self, _cmd);
    if(!value){
        return UIEdgeInsetsZero;
    }
    
    return value.UIEdgeInsetsValue;
}

- (void)invokeHandler:(CXRouteViewController *)viewController mapRoute:(AMapRoute *)mapRoute error:(NSError *)error{
    if(self.completionHandler){
        self.completionHandler(viewController, mapRoute, error);
        self.completionHandler = NULL;
    }
}

@end
