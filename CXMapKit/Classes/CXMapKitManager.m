//
//  CXMapKitManager.m
//  Pods
//
//  Created by wshaolin on 2017/5/10.
//
//

#import "CXMapKitManager.h"
#import <AMapFoundationKit/AMapServices.h>

@implementation CXMapKitManager

+ (void)registerServiceWithKey:(NSString *)key{
    [AMapServices sharedServices].apiKey = key;
}

@end
