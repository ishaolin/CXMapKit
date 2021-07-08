//
//  CXMapRoutePreferenceView.h
//  Pods
//
//  Created by wshaolin on 2019/4/14.
//

#import <CXUIKit/CXUIKit.h>

@class CXMapRoutePreferenceView, CXMapRoutePreference;

@protocol CXMapRoutePreferenceViewDelegate <NSObject>

@optional

- (void)routePreferenceView:(CXMapRoutePreferenceView *)preferenceView didChangePreference:(CXMapRoutePreference *)preference;

@end

@interface CXMapRoutePreferenceView : UIControl

@property (nonatomic, weak) id<CXMapRoutePreferenceViewDelegate> delegate;
@property (nonatomic, strong) CXMapRoutePreference *preference;

@end

@interface CXMapRoutePreferencePanel : CXBaseActionPanel

@property (nonatomic, strong, readonly) CXMapRoutePreference *preference;

- (void)showWithPreferenceView:(CXMapRoutePreferenceView *)preferenceView;

@end
