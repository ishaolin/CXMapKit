//
//  CXPOILoadingUtils.h
//  Pods
//
//  Created by wshaolin on 2019/4/14.
//

#import <Foundation/Foundation.h>

@interface CXPOILoadingUtils : NSObject

+ (void)setNeedsLoadingForView:(UIView *)view
                           msg:(NSString *)msg
                        origin:(CGPoint)origin;

+ (void)setNeedsFailedForView:(UIView *)view
                          msg:(NSString *)msg
                  retryTarget:(id)target
                       action:(SEL)action;

+ (void)setNeedsDismissForView:(UIView *)view;

@end
