//
//  CXSpeechSynthesizer+CXMapExtensions.m
//  Pods
//
//  Created by wshaolin on 2018/12/7.
//

#import "CXSpeechSynthesizer+CXMapExtensions.h"

@implementation CXSpeechSynthesizer (CXMapExtensions)

- (BOOL)driveManagerIsNaviSoundPlaying:(AMapNaviDriveManager *)driveManager{
    return [self isSpeaking];
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager playNaviSoundString:(NSString *)soundString soundStringType:(AMapNaviSoundType)soundStringType{
    [self speakWord:soundString];
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager didStartNavi:(AMapNaviMode)naviMode{
    [self setAudioSessionSupportSpeaker];
}

@end
