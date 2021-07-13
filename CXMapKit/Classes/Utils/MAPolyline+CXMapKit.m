//
//  MAPolyline+CXMapKit.m
//  Pods
//
//  Created by wshaolin on 2017/6/13.
//
//

#import "MAPolyline+CXMapKit.h"
#import <objc/runtime.h>

@implementation MAPolyline (CXMapKit)

- (void)setLineDashType:(MALineDashType)lineDashType{
    objc_setAssociatedObject(self, @selector(lineDashType), @(lineDashType), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MALineDashType)lineDashType{
    return (MALineDashType)[objc_getAssociatedObject(self, _cmd) unsignedIntegerValue];
}

@end
