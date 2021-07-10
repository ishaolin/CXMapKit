//
//  CXPOISearchViewController.m
//  Pods
//
//  Created by wshaolin on 2019/4/14.
//

#import "CXPOISearchViewController.h"
#import "CXPOITableViewCell.h"
#import "CXPOISearchBar.h"
#import "CXPOILoadingUtils.h"
#import "CXPOICacheUtils.h"
#import "CXLocationManager.h"

@interface CXPOISearchViewController() <UITableViewDataSource, UITableViewDelegate> {
    CXPOISearchBar *_searchBar;
    CXTableView *_tableView;
    CXShadowView *_contentView;
    NSArray<CXMapPOIModel *> *_POIs;
}

@property (nonatomic, copy) CXPOISearchVCCompletionBlock completionBlock;

@end

@implementation CXPOISearchViewController

- (NSString *)viewAppearOrDisappearRecordDataKey{
    return @"30000034";
}

- (instancetype)initWithSearchBarStyle:(CXPOISearchBarRightStyle)searchBarStyle
                               POIType:(NSInteger)POIType
                            completion:(CXPOISearchVCCompletionBlock)completion{
    if(self = [super init]){
        _searchBarStyle = searchBarStyle;
        _POIType = POIType;
        self.completionBlock = completion;
        
        _searchBar = [[CXPOISearchBar alloc] initWithRightStyle:_searchBarStyle];
        _searchBar.returnKeyType = (searchBarStyle == CXPOISearchBarRightStyleSearch) ? UIReturnKeySearch : UIReturnKeyDefault;
        _searchBar.delegate = self;
        _searchBar.placeholder = @"搜地点、找路线";
        
        _tableView = [[CXTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 60.0;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.hitTestBlock = ^UIView *(CXTableView *tableView, UIView *hitTestView, CGPoint point, UIEvent *event) {
            [[tableView cx_viewController].view endEditing:YES];
            return hitTestView;
        };
    }
    
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.view.backgroundColor = CXHexIColor(0xF0F1F4);
    self.navigationBar.hidden = YES;
    
    CGFloat searchBar_X = 0;
    CGFloat searchBar_Y = 0;
    CGFloat searchBar_W = CGRectGetWidth(self.view.frame);
    CGFloat searchBar_H = 75.0 + [UIScreen mainScreen].cx_safeAreaInsets.top;
    _searchBar.frame = (CGRect){searchBar_X, searchBar_Y, searchBar_W, searchBar_H};
    [_searchBar cx_addShadowByOption:CXShadowBottom];
    [self.view addSubview:_searchBar];
    
    _contentView = [[CXShadowView alloc] initWithShadowOptions:CXShadowAll
                                              roundedByCorners:UIRectCornerTopRight | UIRectCornerTopRight cornerRadii:2.0];
    [self.view addSubview:_contentView];
    [_contentView addSubview:_tableView];
    [self setHeaderForTableView:_tableView];
    
    [_searchBar becomeFirstResponder];
    [self reloadDataHistoryWithCompletion:^(NSArray<CXMapPOIModel *> *POIModels) {
        self->_POIs = POIModels;
        [self reloadData];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    if(touch.view == self.view){
        [self.view endEditing:YES];
    }
    
    [super touchesBegan:touches withEvent:event];
}

- (void)reloadDataHistoryWithCompletion:(void (^)(NSArray<CXMapPOIModel *> *))completion{
    if(completion){
        completion([CXPOICacheUtils POIModelsForType:_POIType]);
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _POIs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CXPOITableViewCell *cell = [CXPOITableViewCell cellWithTableView:tableView];
    cell.POIModel = _POIs[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CXMapPOIModel *POIModel = _POIs[indexPath.row];
    if(POIModel.cache){
        CXDataRecord(@"30000121");
    }else{
        CXDataRecord(@"30000123");
    }
    
    [self invokeCompletionBlock:POIModel POIType:_POIType];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}

- (void)reloadPOIData{
    [self searchPOIWithKeywords:_searchBar.searchText];
}

- (void)searchPOIWithKeywords:(NSString *)keywords{
    if(CXStringIsEmpty(keywords)){
        [CXPOILoadingUtils setNeedsDismissForView:_tableView];
        [self reloadDataHistoryWithCompletion:^(NSArray<CXMapPOIModel *> *POIModels) {
            self->_POIs = POIModels;
            [self reloadData];
        }];
    }else{
        _POIs = nil;
        [self reloadData];
        
        CGFloat y = 10.0 + CGRectGetHeight(_tableView.tableHeaderView.bounds);
        [CXPOILoadingUtils setNeedsLoadingForView:_tableView msg:@"正在搜索..." origin:CGPointMake(10.0, y)];
        CXSearchPOICompletionHandler completionHandler = ^(NSArray<CXMapPOIModel *> *POIs, NSError *error){
            if(CXArrayIsEmpty(POIs)){
                [CXPOILoadingUtils setNeedsFailedForView:self->_tableView
                                                     msg:@"搜索无结果！"
                                             retryTarget:nil
                                                  action:nil];
            }else if(error){
                [CXPOILoadingUtils setNeedsFailedForView:self->_tableView
                                                     msg:[error localizedDescription]
                                             retryTarget:self
                                                  action:@selector(reloadPOIData)];
            }else{
                self->_POIs = POIs;
                [self reloadData];
                [CXPOILoadingUtils setNeedsDismissForView:self->_tableView];
            }
        };
        
        [self searchPOIWithKeywords:keywords POIType:self.POIType completionHandler:completionHandler];
    }
}

- (void)searchPOIWithKeywords:(NSString *)keywords
                      POIType:(NSInteger)POIType
            completionHandler:(CXSearchPOICompletionHandler)completionHandler{
    CXMapInputTipsSearchOption *option = [[CXMapInputTipsSearchOption alloc] init];
    option.keywords = keywords;
    option.city = [CXLocationManager sharedManager].reverseGeoCodeResult.city;
    option.count = 12;
    [CXMapSearcher inputTipsSearch:option completionHandler:completionHandler];
}

#pragma mark - CXPOISearchBarDelegate

- (BOOL)searchBarShouldReturn:(CXPOISearchBar *)searchBar{
    if(_searchBarStyle == CXPOISearchBarRightStyleSearch){
        CXDataRecord(@"30000124");
        [self searchBarSearch:searchBar.searchText];
    }
    
    return YES;
}

- (void)searchBar:(CXPOISearchBar *)searchBar didChangeContent:(NSString *)content{
    [self searchPOIWithKeywords:content];
}

- (void)searchBarDidGoback:(CXPOISearchBar *)searchBar{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)searchBarDidCancel:(CXPOISearchBar *)searchBar{
    [self quitSearchViewController];
}

- (void)quitSearchViewController{
    __block NSUInteger index = 0;
    [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(obj == self){
            index = idx;
            *stop = YES;
        }
    }];
    
    if(index > 0){
        [self.navigationController popToViewController:self.navigationController.viewControllers[index - 1] animated:YES];
    }
}

- (void)searchBarDidSearch:(CXPOISearchBar *)searchBar{
    CXDataRecord(@"30000122");
    [self searchBarSearch:searchBar.searchText];
}

- (void)searchBarSearch:(NSString *)string{
    
}

- (void)invokeCompletionBlock:(CXMapPOIModel *)POIModel POIType:(NSInteger)POIType{
    [self.view endEditing:YES];
    
    if(POIModel){
        [CXPOICacheUtils setPOIModel:POIModel forType:POIType];
    }
    
    if(self.completionBlock){
        self.completionBlock(self, POIModel, POIType);
    }
}

- (void)setHeaderForTableView:(UITableView *)tableView{
    
}

- (void)reloadData{
    CGFloat contentView_X = 15.0;
    CGFloat contentView_Y = CGRectGetHeight(_searchBar.frame) + contentView_X;
    CGFloat contentView_W = CGRectGetWidth(self.view.bounds) - contentView_X * 2;
    CGFloat contentView_H = 0;
    if (_POIs.count * _tableView.rowHeight + CGRectGetHeight(_tableView.tableHeaderView.bounds) > CGRectGetHeight(self.view.frame) - contentView_Y) {
        contentView_H = CGRectGetHeight(self.view.frame) - contentView_Y;
        _tableView.bounces = YES;
        _tableView.contentInset = [UIScreen mainScreen].cx_scrollViewSafeAreaInset;
    }else{
        contentView_H = _POIs.count * _tableView.rowHeight + CGRectGetHeight(_tableView.tableHeaderView.bounds);
        if(CXArrayIsEmpty(_POIs)){
            contentView_H = CGRectGetHeight(self.view.frame) - contentView_Y;
        }
        _tableView.bounces = NO;
    }
    _contentView.frame = (CGRect){contentView_X, contentView_Y, contentView_W, contentView_H};
    
    CGFloat tableView_X = 0;
    CGFloat tableView_Y = 0;
    CGFloat tableView_W = contentView_W;
    CGFloat tableView_H = contentView_H;
    _tableView.frame = (CGRect){tableView_X, tableView_Y, tableView_W, tableView_H};
    
    [_tableView reloadData];
}

@end
