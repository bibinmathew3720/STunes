//
//  playerSingleton.h
//  STunes1
//
//  Created by Cocoalabs India on 29/10/16.
//  Copyright © 2016 Cocoalabs India. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STKAudioPlayer.h"

@interface playerSingleton : NSObject
@property (nonatomic,strong) STKAudioPlayer* Splayer;
@property (nonatomic,readwrite) NSMutableArray *downloadedFiles;
@property (nonatomic,readwrite) NSMutableArray *favourites;
@property (nonatomic,retain) NSString* statusLabel;
@property (nonatomic) int currentSpot;
@property (nonatomic) int SongSpot;
@property (nonatomic) int count;
@property (nonatomic,readwrite) NSString* fromStatus;
@property (nonatomic,readwrite) NSURL *imgCover;
@property (nonatomic,readwrite) NSString *lyricsBy;
@property (nonatomic,readwrite) NSString *songName;
@property (nonatomic,readwrite) NSString *albumname;
@property (nonatomic,readwrite) NSString *singer;
@property (nonatomic,readwrite) NSString *track_id;
@property (nonatomic,readwrite) NSArray *urls;
@property (nonatomic,readwrite) bool songOver;
-(void)SongPlay:(NSString *)songName;
-(void)SongLocal:(NSURL *)url;
-(void)SongResume;
-(void)SongPause;
-(void)SongStop:(NSString*)songName;
-(void)SeekingSong:(float)Value;
-(void)SongMute;
-(double)returningProgressValue;
-(double)returningDurationValue;
-(void)PlayAllS:(NSArray *)UrlList;
-(void)PreviouseSong;
-(void)NextSong;

+(playerSingleton *)sharedInstance;

@end
