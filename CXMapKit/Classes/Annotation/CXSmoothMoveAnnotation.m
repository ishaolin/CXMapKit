//
//  CXSmoothMoveAnnotation.m
//  Pods
//
//  Created by wshaolin on 2017/5/30.
//
//

#import "CXSmoothMoveAnnotation.h"
#import "CXLocationManager.h"
#import <CXFoundation/CXFoundation.h>

@interface CXSmoothMoveAnnotation(){
    NSMutableArray<NSValue *> *_mutableCoordinates;
}

@property (nonatomic, assign, getter = isMoving) BOOL moving;

@end

@implementation CXSmoothMoveAnnotation

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate image:(UIImage *)image{
    if(self = [super initWithCoordinate:coordinate image:image]){
        _enableSmoothMove = YES;
        self.zIndex = 1000;
    }
    
    return self;
}

- (void)addSmoothMoveCoordinate:(CLLocationCoordinate2D)coordinate{
    if(!CXLocationCoordinate2DIsValid(coordinate)){
        return;
    }
    
    if(!self.isEnableSmoothMove){
        self.coordinate = coordinate;
        return;
    }
    
    if(!_mutableCoordinates){
        _mutableCoordinates = [NSMutableArray array];
    }
    
    [_mutableCoordinates addObject:[NSValue valueWithMACoordinate:coordinate]];
    
    [self _smoothMove];
}

- (void)_smoothMove{
    if([self _shouldSmoothMovePosition]){
        _moving = YES;
        
        NSArray<NSValue *> *_coordinates = [_mutableCoordinates copy];
        [_mutableCoordinates removeAllObjects];
        
        NSUInteger count = _coordinates.count;
        CLLocationCoordinate2D *coordinates = (CLLocationCoordinate2D *)malloc(count * sizeof(CLLocationCoordinate2D));
        [_coordinates enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            coordinates[idx] = obj.MACoordinateValue;
        }];
        
        @weakify(self)
        [self addMoveAnimationWithKeyCoordinates:coordinates count:count withDuration:count * 0.25 withName:nil completeCallback:^(BOOL isFinished) {
            @strongify(self)
            if(isFinished){
                self.moving = NO;
                [self _smoothMove];
            }
        }];
        
        free(coordinates);
        coordinates = NULL;
    }
}

- (BOOL)_shouldSmoothMovePosition{
    return (self.isEnableSmoothMove
            && !CXArrayIsEmpty(_mutableCoordinates)
            && !self.isMoving);
}

- (void)removeAllSmoothMoveCoordinates{
    if(!self.isEnableSmoothMove){
        return;
    }
    
    _moving = NO;
    [_mutableCoordinates removeAllObjects];
}

@end
