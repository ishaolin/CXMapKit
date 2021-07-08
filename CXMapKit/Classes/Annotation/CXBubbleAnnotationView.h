//
//  CXBubbleAnnotationView.h
//  Pods
//
//  Created by wshaolin on 2018/7/6.
//

#import "CXRotatedAnnotationView.h"

NS_ASSUME_NONNULL_BEGIN

@interface CXBubbleAnnotationView : CXRotatedAnnotationView

@property (nonatomic, strong, nullable) UIView *bubbleView; // 气泡view
@property (nonatomic, assign) CGPoint coorOffset; // 默认view的底部中心点，请勿直接使用centerOffset，内部有转换
@property (nonatomic, copy) NSString *URLCacheKey;

// 设置网络图片，completion只有在下载图片成功之后会调用
- (void)setImageWithURL:(NSString *)url completion:(UIImage * _Nonnull (^)(CXBubbleAnnotationView * _Nonnull annotationView, UIImage * _Nonnull image))completion;

- (void)setWebImage:(UIImage *)webImage;

@end

NS_ASSUME_NONNULL_END
