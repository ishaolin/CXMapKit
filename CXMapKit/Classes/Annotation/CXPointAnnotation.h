//
//  CXPointAnnotation.h
//  Pods
//
//  Created by wshaolin on 2017/5/12.
//
//

#import <AMapNaviKit/MAAnimatedAnnotation.h>

@class MACustomCalloutView;

@interface CXPointAnnotation : MAAnimatedAnnotation

@property (nonatomic, strong) MACustomCalloutView *customCalloutView;

@property (nonatomic, copy) NSString *identifier; // annotation的唯一标识符

@property (nonatomic, assign) NSInteger zIndex;

@property (nonatomic, strong, readonly) UIImage *image; // annotation的图片
@property (nonatomic, strong) UIImage *selectedImage; // annotation选中状态的图片

@property (nonatomic, assign, getter = isEnabled) BOOL enabled; // 如果customCalloutView有值，始终返回YES

@property (nonatomic, assign, getter = isSelected) BOOL selected;

@property (nonatomic, assign) CGPoint centerOffset;
@property (nonatomic, assign) CGPoint calloutOffset;

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate image:(UIImage *)image;

@end
