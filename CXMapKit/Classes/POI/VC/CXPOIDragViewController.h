//
//  CXPOIDragViewController.h
//  Pods
//
//  Created by wshaolin on 2019/4/15.
//

#import "CXMapViewController.h"

@class CXPOIDragViewController;

@protocol CXPOIDragViewControllerDelegate <NSObject>

@optional

- (void)POIDragViewControllerWillMoveMapByUser:(CXPOIDragViewController *)viewController;

- (void)POIDragViewController:(CXPOIDragViewController *)viewController
            didUpdatePOIModel:(CXMapPOIModel *)POIModel;

- (void)POIDragViewController:(CXPOIDragViewController *)viewController
          didSelectedPOIModel:(CXMapPOIModel *)POIModel;

@end

@interface CXPOIDragViewController : CXMapViewController

@property (nonatomic, weak) id<CXPOIDragViewControllerDelegate> delegate;

- (void)POIInfoWillUpdate;
- (void)POIInfoDidUpdate:(CXMapPOIModel *)POIModel;

@end
