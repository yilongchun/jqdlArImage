//
//  Player.m
//  jqdl
//
//  Created by Stephen Chin on 15/11/27.
//  Copyright © 2015年 Stephen Chin. All rights reserved.
//

#import "Player.h"


static Player *__helper = nil;

@implementation Player

+(instancetype)sharedManager{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __helper = [[super alloc]init];
        __helper.onStateChange = ^(FSAudioStreamState state) {
            __helper.audioState = state;
            
            
            switch (state) {
                case kFsAudioStreamRetrievingURL:
                    NSLog(@"kFsAudioStreamRetrievingURL:%d",state);
                    break;
                case kFsAudioStreamStopped:
                    NSLog(@"kFsAudioStreamStopped:%d",state);
                    break;
                case kFsAudioStreamBuffering:
                    NSLog(@"kFsAudioStreamBuffering:%d",state);
                    break;
                case kFsAudioStreamPlaying:
                    NSLog(@"kFsAudioStreamPlaying:%d",state);
                    break;
                case kFsAudioStreamPaused:
                    NSLog(@"kFsAudioStreamPaused:%d",state);
                    break;
                case kFsAudioStreamSeeking:
                    NSLog(@"kFsAudioStreamSeeking:%d",state);
                    break;
                case kFSAudioStreamEndOfFile:
                    NSLog(@"kFSAudioStreamEndOfFile:%d",state);
                    break;
                case kFsAudioStreamFailed:
                    NSLog(@"kFsAudioStreamFailed:%d",state);
                    break;
                case kFsAudioStreamRetryingStarted:
                    NSLog(@"kFsAudioStreamRetryingStarted:%d",state);
                    break;
                case kFsAudioStreamRetryingSucceeded:
                    NSLog(@"kFsAudioStreamRetryingSucceeded:%d",state);
                    break;
                case kFsAudioStreamRetryingFailed:
                    NSLog(@"kFsAudioStreamRetryingFailed:%d",state);
                    break;
                case kFsAudioStreamPlaybackCompleted:
                    NSLog(@"kFsAudioStreamPlaybackCompleted:%d",state);
                    break;
                case kFsAudioStreamUnknownState:
                    NSLog(@"kFsAudioStreamUnknownState:%d",state);
                    break;
                default:
                    break;
            }
            
            
            
            
        };
        __helper.onFailure=^(FSAudioStreamError error,NSString *description){
            NSLog(@"播放过程中发生错误，错误信息：%@",description);
        };
        __helper.onCompletion=^(){
            NSLog(@"播放完成!");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"playVoiceEnd" object:nil];
        };
    });
    return __helper;
}

@end
