//
//  AMapNaviBaseManager+CXMapExtensions.m
//  CXMapKit
//
//  Created by lcc on 2018/6/20.
//

#import "AMapNaviBaseManager+CXMapExtensions.h"
#import <objc/runtime.h>

@implementation AMapNaviBaseManager (CXMapExtensions)

- (void)setRouteOption:(CXMapRouteRequestOption *)routeOption{
    objc_setAssociatedObject(self, @selector(routeOption), routeOption, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CXMapRouteRequestOption *)routeOption{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setCompletionHandler:(CXMapDrawNaviRouteCompletionHandler)completionHandler{
    objc_setAssociatedObject(self, @selector(completionHandler), completionHandler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CXMapDrawNaviRouteCompletionHandler)completionHandler{
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

- (void)invokeHandler:(CXRouteViewController *)viewController naviRoutes:(NSArray<AMapNaviRoute *> *)naviRoutes error:(NSError *)error{
    if(self.completionHandler){
        self.completionHandler(viewController, naviRoutes, error);
        self.completionHandler = nil;
    }
}

@end
