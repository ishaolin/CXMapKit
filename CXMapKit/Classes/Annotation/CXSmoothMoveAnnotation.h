//
//  CXSmoothMoveAnnotation.h
//  Pods
//
//  Created by wshaolin on 2017/5/30.
//
//

#import "CXBubbleAnnotation.h"

@interface CXSmoothMoveAnnotation : CXBubbleAnnotation

@property (nonatomic, assign, getter = isEnableSmoothMove) BOOL enableSmoothMove; // Default is Yes.

- (void)addSmoothMoveCoordinate:(CLLocationCoordinate2D)coordinate;

- (void)removeAllSmoothMoveCoordinates;

@end
