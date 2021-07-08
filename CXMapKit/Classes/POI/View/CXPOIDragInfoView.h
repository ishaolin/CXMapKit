//
//  CXPOIDragInfoView.h
//  Pods
//
//  Created by wshaolin on 2019/4/15.
//

#import <UIKit/UIKit.h>

@class CXPOIDragInfoView;
@class CXMapPOIModel;

@protocol CXPOIDragInfoViewDelegate <NSObject>

@optional

- (void)POIDragInfoView:(CXPOIDragInfoView *)infoView didConfirmWithPOIModel:(CXMapPOIModel *)POIModel;

@end

@interface CXPOIDragInfoView : UIView

@property (nonatomic, weak) id<CXPOIDragInfoViewDelegate> delegate;

- (void)willUpdateInfo;
- (void)setUpdateInfoWithPOIModel:(CXMapPOIModel *)POIModel;

@end
