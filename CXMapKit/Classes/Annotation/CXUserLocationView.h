//
//  CXUserLocationView.h
//  Pods
//
//  Created by wshaolin on 2018/4/20.
//

#import "CXBubbleAnnotationView.h"

@interface CXUserLocationView : CXBubbleAnnotationView

@property (nonatomic, assign, getter = isEnableCenterOffset) BOOL enableCenterOffset; // defaults NO

+ (void)setCustomUserLocationImage:(UIImage *)userLocationImage;

@end
