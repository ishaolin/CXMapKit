//
//  CXRotatedAnnotationView.h
//  Pods
//
//  Created by wshaolin on 2018/4/19.
//

#import <AMapNaviKit/MAAnnotationView.h>

@interface CXRotatedAnnotationView : MAAnnotationView

@property (nonatomic, strong, readonly) UIView *marker;

@property (nonatomic, assign, getter = isRrotateEnabled) BOOL rotateEnabled; // defaults YES

@property (nonatomic, assign) CGFloat rotationDegree;

- (void)setRotationDegree:(CGFloat)rotationDegree animated:(BOOL)animated;

- (void)setRotationDegree:(CGFloat)rotationDegree duration:(NSTimeInterval)duration animated:(BOOL)animated;

@end
