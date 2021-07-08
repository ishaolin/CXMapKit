//
//  CXUserLocationView.m
//  Pods
//
//  Created by wshaolin on 2018/4/20.
//

#import "CXUserLocationView.h"
#import "CXMapKitDefines.h"

static UIImage *_userLocationImage = nil;

@implementation CXUserLocationView

- (instancetype)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]){
        self.enableCenterOffset = NO;
        self.enabled = YES;
        
        [super setImage:_userLocationImage ?: CX_MAPKIT_IMAGE(@"map_annotation_self")];
    }
    
    return self;
}

- (void)setImage:(UIImage *)image{
    
}

- (void)setEnableCenterOffset:(BOOL)enableCenterOffset{
    _enableCenterOffset = enableCenterOffset;
}

- (void)setCenterOffset:(CGPoint)centerOffset{
    if(self.isEnableCenterOffset){
        [super setCenterOffset:centerOffset];
    }
}

- (void)setCanShowCallout:(BOOL)canShowCallout{
    [super setCanShowCallout:NO];
}

- (void)setCustomCalloutView:(MACustomCalloutView *)customCalloutView{
    
}

- (void)setDraggable:(BOOL)draggable{
    [super setDraggable:NO];
}

- (void)setWebImage:(UIImage *)webImage{
    [super setImage:webImage];
}

+ (void)setCustomUserLocationImage:(UIImage *)userLocationImage{
    _userLocationImage = userLocationImage;
}

@end
