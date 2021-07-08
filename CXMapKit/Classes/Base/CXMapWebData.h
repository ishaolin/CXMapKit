//
//  CXMapWebData.h
//  Pods
//
//  Created by wshaolin on 2018/4/7.
//

#import <Foundation/Foundation.h>

@interface CXMapWebData : NSObject

+ (NSData *)mapStyleWebData:(NSString *)name;

+ (NSData *)mapStyleWebData:(NSString *)name
                   inBundle:(NSString *)bundleName
               forFramework:(NSString *)frameworkName;

+ (NSString *)filePathWithName:(NSString *)name;

+ (NSString *)filePathWithName:(NSString *)name
                      inBundle:(NSString *)bundleName
                  forFramework:(NSString *)frameworkName;

@end
