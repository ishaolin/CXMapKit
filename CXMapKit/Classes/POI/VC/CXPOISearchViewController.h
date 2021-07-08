//
//  CXPOISearchViewController.h
//  Pods
//
//  Created by wshaolin on 2019/4/14.
//

#import "CXPOISearchBar.h"
#import "CXMapSearcher.h"

@class CXPOISearchViewController;

typedef void(^CXPOISearchVCCompletionBlock)(CXPOISearchViewController *VC, CXMapPOIModel *POIModel, NSInteger POIType);

@interface CXPOISearchViewController : CXBaseViewController <CXPOISearchBarDelegate>

@property (nonatomic, strong, readonly) CXPOISearchBar *searchBar;
@property (nonatomic, assign, readonly) CXPOISearchBarRightStyle searchBarStyle;
@property (nonatomic, assign, readonly) NSInteger POIType;

- (instancetype)initWithSearchBarStyle:(CXPOISearchBarRightStyle)searchBarStyle
                               POIType:(NSInteger)POIType
                            completion:(CXPOISearchVCCompletionBlock)completion;

- (void)searchPOIWithKeywords:(NSString *)keywords
                      POIType:(NSInteger)POIType
            completionHandler:(CXSearchPOICompletionHandler)completionHandler;

- (void)invokeCompletionBlock:(CXMapPOIModel *)POIModel POIType:(NSInteger)POIType;

- (void)setHeaderForTableView:(UITableView *)tableView;

- (void)reloadDataHistoryWithCompletion:(void(^)(NSArray<CXMapPOIModel *> *POIModels))completion;

- (void)quitSearchViewController; // 返回到之前的页面

@end
