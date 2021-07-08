//
//  CXMapNaviAnnotationDelegate.h
//  Pods
//
//  Created by wshaolin on 2019/4/12.
//

#import <Foundation/Foundation.h>

@class MAAnnotationView, MAMapView;
@protocol MAAnnotation;

@protocol CXMapNaviAnnotationDelegate <NSObject>

@optional

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation;

- (BOOL)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view;

@end
