//
//  CXMapWebData.m
//  Pods
//
//  Created by wshaolin on 2018/4/7.
//

#import "CXMapWebData.h"
#import <CXFoundation/CXFoundation.h>

@implementation CXMapWebData

+ (NSData *)mapStyleWebData:(NSString *)name{
    return [self mapStyleWebData:name inBundle:@"CXMapKit" forFramework:@"CXMapKit"];
}

+ (NSData *)mapStyleWebData:(NSString *)name
                   inBundle:(NSString *)bundleName
               forFramework:(NSString *)frameworkName{
    NSString *filePath = [self filePathWithName:name inBundle:bundleName forFramework:frameworkName];
    if(filePath){
        return [NSData dataWithContentsOfFile:filePath];
    }
    
    return nil;
}

+ (NSString *)filePathWithName:(NSString *)name{
    return [self filePathWithName:name inBundle:@"CXMapKit" forFramework:@"CXMapKit"];
}

+ (NSString *)filePathWithName:(NSString *)name
                      inBundle:(NSString *)bundleName
                  forFramework:(NSString *)frameworkName{
    if(CXStringIsEmpty(name)){
        return nil;
    }
    
    if(bundleName && ![bundleName hasSuffix:CX_BUNDLE_NAME_SUFFIX]){
        bundleName = [bundleName stringByAppendingString:CX_BUNDLE_NAME_SUFFIX];
    }
    
    NSBundle *bundle = [NSBundle mainBundle];
    if(bundleName){
        NSString *bundlePath = [bundle.bundlePath stringByAppendingPathComponent:bundleName];
        bundle = [NSBundle bundleWithPath:bundlePath];
    }
    
    NSString *filePath = [bundle pathForResource:name ofType:nil];
    if(!filePath){
        if(CXStringIsEmpty(frameworkName)){
            return nil;
        }
        
        if(![frameworkName hasSuffix:CX_FRAMEWORK_NAME_SUFFIX]){
            frameworkName = [NSString stringWithFormat:@"%@%@", frameworkName, CX_FRAMEWORK_NAME_SUFFIX];
        }
        
        bundleName = [NSString stringWithFormat:@"Frameworks/%@/%@", frameworkName, bundleName];
        bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle].bundlePath  stringByAppendingPathComponent:bundleName]];
        filePath = [bundle pathForResource:name ofType:nil];
    }
    
    return filePath;
}

@end
