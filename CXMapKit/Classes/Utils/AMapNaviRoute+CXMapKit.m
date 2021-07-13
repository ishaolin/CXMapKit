//
//  AMapNaviRoute+CXMapKit.m
//  Pods
//
//  Created by lcc on 2018/5/17.
//

#import "AMapNaviRoute+CXMapKit.h"
#import <objc/runtime.h>

@implementation AMapNaviRoute (CXMapKit)

- (void)setRequestOption:(CXMapRouteRequestOption *)requestOption{
    objc_setAssociatedObject(self, @selector(requestOption), requestOption, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CXMapRouteRequestOption *)requestOption{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setRouteId:(NSNumber *)routeId{
    objc_setAssociatedObject(self, @selector(routeId), routeId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)routeId{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setSelected:(BOOL)selected{
    objc_setAssociatedObject(self, @selector(isSelected), @(selected), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isSelected{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

@end
