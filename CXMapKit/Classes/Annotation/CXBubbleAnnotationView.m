//
//  CXBubbleAnnotationView.m
//  Pods
//
//  Created by wshaolin on 2018/7/6.
//

#import "CXBubbleAnnotationView.h"
#import <CXUIKit/CXUIKit.h>

static inline NSURL *CXAnnotationIconCacheURL(NSURL *actualURL, NSString *URLCacheKey){
    if(!actualURL){
        return nil;
    }
    
    static NSMutableDictionary<NSString *, NSURL *> *URLCachePool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        URLCachePool = [NSMutableDictionary dictionary];
    });
    
    NSURL *URL = URLCachePool[[CXUCryptor MD5:actualURL.absoluteString]];
    if(URL){
        return URL;
    }
    
    NSString *path = nil;
    if(CXStringIsEmpty(URLCacheKey)){
        path = [NSString stringWithFormat:@"/cache/%@@%.fx.png", [CXUCryptor MD5:actualURL.absoluteString], [UIScreen mainScreen].scale];
    }else{
        path = [NSString stringWithFormat:@"/cache/%@/%@@%.fx.png", URLCacheKey, [CXUCryptor MD5:actualURL.absoluteString], [UIScreen mainScreen].scale];
    }
    
    URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://map.%@%@", actualURL.scheme, actualURL.host, path]];
    URLCachePool[[CXUCryptor MD5:actualURL.absoluteString]] = URL;
    
    return URL;
}

@implementation CXBubbleAnnotationView

- (void)setBubbleView:(UIView *)bubbleView{
    if(_bubbleView == bubbleView){
        return;
    }
    
    [self removeBubbleViewObserves:_bubbleView];
    [_bubbleView removeFromSuperview];
    _bubbleView = bubbleView;
    
    if(_bubbleView){
        [self addSubview:_bubbleView];
    }
    
    [self addBubbleViewObserves:_bubbleView];
    [self setUpdateBounds];
}

- (void)addBubbleViewObserves:(UIView *)bubbleView{
    if(!bubbleView){
        return;
    }
    
    [bubbleView addObserver:self
                 forKeyPath:@"frame"
                    options:NSKeyValueObservingOptionNew
                    context:nil];
    [bubbleView addObserver:self
                 forKeyPath:@"hidden"
                    options:NSKeyValueObservingOptionNew
                    context:nil];
    [bubbleView addObserver:self
                 forKeyPath:@"alpha"
                    options:NSKeyValueObservingOptionNew
                    context:nil];
}

- (void)removeBubbleViewObserves:(UIView *)bubbleView{
    if(!bubbleView){
        return;
    }
    
    [bubbleView removeObserver:self forKeyPath:@"frame"];
    [bubbleView removeObserver:self forKeyPath:@"hidden"];
    [bubbleView removeObserver:self forKeyPath:@"alpha"];
}

- (void)setImage:(UIImage *)image{
    [super setImage:image];
    
    [self setUpdateBounds];
}

-  (void)setUpdateBounds{
    CGSize infoViewSize = CGSizeZero;
    if(_bubbleView && !_bubbleView.isHidden && _bubbleView.alpha > 0.01){
        infoViewSize = _bubbleView.bounds.size;
        
        if(!CGPointEqualToPoint(_bubbleView.frame.origin, CGPointZero)){
            _bubbleView.frame = (CGRect){CGPointZero, infoViewSize};
        }
    }
    
    CGSize imageSize = CGSizeZero;
    if(self.image){
        imageSize = self.image.size;
    }
    
    CGFloat width = MAX(infoViewSize.width, imageSize.width);
    CGFloat height = infoViewSize.height + imageSize.height + (infoViewSize.height > 0 ? self.calloutOffset.y : 0);
    if(infoViewSize.height > 0){
        self.centerOffset = CGPointMake(_coorOffset.x, _coorOffset.y - height * 0.5);
    }else{
        self.centerOffset = _coorOffset;
    }
    
    self.bounds = (CGRect){CGPointZero, width, height};
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    [self setUpdateBounds];
}

- (void)setImageWithURL:(NSString *)url completion:(UIImage * _Nonnull (^)(CXBubbleAnnotationView * _Nonnull, UIImage * _Nonnull))completion{
    NSURL *URL = [NSURL URLWithString:url];
    if(!URL || !completion){
        return;
    }
    
    // 检查是否存在已处理过的图片
    NSURL *cacheURL = CXAnnotationIconCacheURL(URL, self.URLCacheKey);
    [CXWebImage imageForURL:cacheURL completion:^(UIImage *image, NSData *data) {
        if(image){
            [self setWebImage:image];
            return;
        }
        
        [CXWebImage downloadImageWithURL:URL completion:^(UIImage *_image, NSData *_data) {
            if(_image){
                [self setImage:completion(self, _image) forURL:cacheURL];
            }else{
                [self setImage:nil];
            }
        }];
    }];
}

- (void)setImage:(UIImage *)image forURL:(NSURL *)URL{
    if(image){
        [self setWebImage:image];
        [CXWebImage storeImage:image forURL:URL];
    }
}

- (void)setWebImage:(UIImage *)webImage{
    [self setImage:webImage];
}

- (void)setCoorOffset:(CGPoint)coorOffset{
    if(CGPointEqualToPoint(_coorOffset, coorOffset)){
        return;
    }
    
    _coorOffset = coorOffset;
    if(self.image.size.height < CGRectGetHeight(self.bounds)){
        self.centerOffset = CGPointMake(_coorOffset.x, _coorOffset.y - CGRectGetHeight(self.bounds) * 0.5);
    }else{
        self.centerOffset = _coorOffset;
    }
}

- (void)setCenterOffset:(CGPoint)centerOffset{
    [super setCenterOffset:centerOffset];
}

- (void)dealloc{
    [self removeBubbleViewObserves:_bubbleView];
}

@end
