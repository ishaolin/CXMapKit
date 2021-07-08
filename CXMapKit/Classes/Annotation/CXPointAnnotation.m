//
//  CXPointAnnotation.m
//  Pods
//
//  Created by wshaolin on 2017/5/12.
//
//

#import "CXPointAnnotation.h"

@implementation CXPointAnnotation

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate image:(UIImage *)image{
    if(self = [super init]){
        _image = image;
        self.coordinate = coordinate;
        _zIndex = 1;
        
        self.enabled = YES;
    }
    
    return self;
}

- (NSString *)identifier{
    if(!_identifier){
        _identifier = NSStringFromClass(self.class);
    }
    
    return _identifier;
}

- (BOOL)isEnabled{
    if(_customCalloutView){
        return YES;
    }
    
    return _enabled;
}

@end
