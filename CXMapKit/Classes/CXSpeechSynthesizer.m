//
//  CXSpeechSynthesizer.m
//  Pods
//
//  Created by wshaolin on 2018/12/6.
//

#import "CXSpeechSynthesizer.h"
#import <objc/runtime.h>

@interface CXSpeechSynthesizer () <AVSpeechSynthesizerDelegate> {
    AVSpeechSynthesizer *_synthesizer;
    AVSpeechSynthesisVoice *_synthesisVoice;
    BOOL _forceSpeak;
}

@end

@implementation CXSpeechSynthesizer

+ (CXSpeechSynthesizer *)sharedSynthesizer{
    static CXSpeechSynthesizer *speechSynthesizer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        speechSynthesizer = [[CXSpeechSynthesizer alloc] init];
        speechSynthesizer->_synthesizer = [[AVSpeechSynthesizer alloc] init];
        speechSynthesizer->_synthesizer.delegate = speechSynthesizer;
        speechSynthesizer->_synthesisVoice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh_CN"];
        speechSynthesizer->_speechRate = AVSpeechUtteranceDefaultSpeechRate;
        speechSynthesizer->_volume = 1.0;
        speechSynthesizer->_enableSpeak = YES;
        speechSynthesizer->_state = CXSpeechSynthesizerStateStop;
        
        [speechSynthesizer setAudioSessionSupportSpeaker];
    });
    
    return speechSynthesizer;
}

- (void)setEnableSpeak:(BOOL)enableSpeak{
    _enableSpeak = enableSpeak;
    
    if(!_enableSpeak){
        [self stop];
    }
}

- (BOOL)isSpeaking{
    return (_state != CXSpeechSynthesizerStateStop);
}

- (BOOL)stop{
    if(_state == CXSpeechSynthesizerStateSpeaking ||
       _state == CXSpeechSynthesizerStatePause){
        return [_synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    }
    
    return NO;
}

- (BOOL)pause{
    if(_state == CXSpeechSynthesizerStateSpeaking){
        return [_synthesizer pauseSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    }
    
    return NO;
}

- (BOOL)resume{
    if(_state == CXSpeechSynthesizerStatePause){
        return [_synthesizer continueSpeaking];
    }
    
    return NO;
}

- (BOOL)setAudioSessionSupportSpeaker{
    AVAudioSessionCategoryOptions options = AVAudioSessionCategoryOptionMixWithOthers | AVAudioSessionCategoryOptionDuckOthers | AVAudioSessionCategoryOptionAllowBluetooth | AVAudioSessionCategoryOptionDefaultToSpeaker;
    // AVAudioSessionCategoryMultiRoute | AVAudioSessionCategoryPlayAndRecord | AVAudioSessionCategoryPlayback
    return [self setCategory:AVAudioSessionCategoryPlayback options:options error:nil];
}

- (BOOL)setCategory:(AVAudioSessionCategory)category
            options:(AVAudioSessionCategoryOptions)options
              error:(NSError **)error{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:category withOptions:options error:error];
    return [audioSession setActive:YES error:error];
}

- (void)speakWord:(NSString *)word{
    if(!word || word.length == 0){
        return;
    }
    
    if(self.isEnableSpeak && _state == CXSpeechSynthesizerStateStop){
        _forceSpeak = NO;
        
        AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:word];
        utterance.rate = self.speechRate;
        utterance.volume = self.volume;
        utterance.cx_force = _forceSpeak;
        [_synthesizer speakUtterance:utterance];
    }
}

- (void)forceSpeakWord:(NSString *)word{
    if(!word || word.length == 0){
        return;
    }
    
    [self stop];
    
    _forceSpeak = YES;
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:word];
    utterance.rate = self.speechRate;
    utterance.volume = self.volume;
    utterance.cx_force = _forceSpeak;
    [_synthesizer speakUtterance:utterance];
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didStartSpeechUtterance:(AVSpeechUtterance *)utterance{
    _state = CXSpeechSynthesizerStateSpeaking;
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance{
    if(_forceSpeak && !utterance.cx_force){
        return;
    }
    
    _state = CXSpeechSynthesizerStateStop;
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didPauseSpeechUtterance:(AVSpeechUtterance *)utterance{
    _state = CXSpeechSynthesizerStatePause;
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didContinueSpeechUtterance:(AVSpeechUtterance *)utterance{
    _state = CXSpeechSynthesizerStateSpeaking;
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance *)utterance{
    _state = CXSpeechSynthesizerStateStop;
}

@end

@implementation AVSpeechUtterance (CXMapKit)

- (void)setCx_force:(BOOL)cx_force{
    objc_setAssociatedObject(self, @selector(cx_force), @(cx_force), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)cx_force{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

@end
