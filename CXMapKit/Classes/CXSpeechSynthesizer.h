//
//  CXSpeechSynthesizer.h
//  Pods
//
//  Created by wshaolin on 2018/12/6.
//

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSUInteger, CXSpeechSynthesizerState){
    CXSpeechSynthesizerStateStop     = 0,
    CXSpeechSynthesizerStateSpeaking = 1,
    CXSpeechSynthesizerStatePause    = 2
};

@interface CXSpeechSynthesizer : NSObject

@property (nonatomic, assign) float speechRate; // 语速 [0, 1.0];
@property (nonatomic, assign) float volume; // 音量 [0, 1.0];
@property (nonatomic, assign, getter = isEnableSpeak) BOOL enableSpeak; // 默认YES
@property (nonatomic, assign, readonly) CXSpeechSynthesizerState state;
@property (nonatomic, assign, readonly) BOOL isSpeaking;

+ (CXSpeechSynthesizer *)sharedSynthesizer;

- (BOOL)setAudioSessionSupportSpeaker;

- (BOOL)setCategory:(AVAudioSessionCategory)category
            options:(AVAudioSessionCategoryOptions)options
              error:(NSError **)error;

- (void)speakWord:(NSString *)word;
- (void)forceSpeakWord:(NSString *)word;

- (BOOL)stop;
- (BOOL)pause;
- (BOOL)resume;

@end

@interface AVSpeechUtterance (CXMapKit)

@property (nonatomic, assign) BOOL cx_force;

@end
