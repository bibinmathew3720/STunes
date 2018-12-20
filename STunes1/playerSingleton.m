//
//  playerSingleton.m
//  STunes1
//
//  Created by Cocoalabs India on 29/10/16.
//  Copyright © 2016 Cocoalabs India. All rights reserved.
//

#import "playerSingleton.h"
#import "STKAudioPlayer.h"
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>

@implementation playerSingleton


static playerSingleton *_sharedInstance = nil;
NSTimer *timer;
NSTimer *timer1;
bool songStop;
NSString *PlayerAction;
AppDelegate *app;

+ (playerSingleton *)sharedInstance {
    if (_sharedInstance == nil) {
        _sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        _Splayer=[[STKAudioPlayer alloc]init];
        app=(AppDelegate *)[UIApplication sharedApplication].delegate;
        _downloadedFiles=[[NSMutableArray alloc]init];
        _favourites=[[NSMutableArray alloc]init];
        [self FetchingDownloads];
        _count=0;
        _songOver=NO;
        songStop=NO;
        _currentSpot=-1;
        [self setupTimer];
        
        // Work your initialising here as you normally would
    }
    
    return self;
}
-(void) setupTimer
{
    
    timer = [NSTimer timerWithTimeInterval:0.001 target:self selector:@selector(tick) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}
-(void)tick
{
    if (_Splayer.duration!=0)
    {
        _songOver=YES;
    }
    else
    {
        if (_songOver==YES&&songStop==NO)
        {
            _songOver=NO;
            
            if ([_fromStatus isEqualToString:@"favourites"])
            {
                if (_count==_favourites.count)
                    _count=0;
                //_currentSpot=_count;
                _SongSpot=_count;
                [self FindingFile:[[_favourites objectAtIndex:_count] valueForKey:@"songName"]];
                _count++;
            }
            else
            {
                if (_count==_downloadedFiles.count)
                    _count=0;
                _currentSpot=_count;
                _SongSpot=_count;
                [self FindingFile:[[_downloadedFiles objectAtIndex:_count] valueForKey:@"songName"]];
                _count++;
            }
            
            

            //[self SongLocal:@""];
        }
    }
    _statusLabel=_Splayer.state == STKAudioPlayerStateBuffering ? @"buffering" : @"";
}
-(void) setupTimer1
{
    
    timer = [NSTimer timerWithTimeInterval:0.001 target:self selector:@selector(tick1) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}
-(void)tick1
{
    //NSLog(@"===== %f",_Splayer.duration);
    if (_Splayer.duration!=0)
    {
        _songOver=YES;
    }
    else
    {
        if (_songOver==YES)
        {
            _songOver=NO;
            
            if (_count== _urls.count-1) {
                _count=0;
            }
            
            if ([PlayerAction isEqualToString:@"next"])
            {
                _count=_count+1;
                [_Splayer play:[[_urls objectAtIndex:_count] valueForKey:@"track_file"]];
                
                [playerSingleton sharedInstance].songName=[[_urls objectAtIndex:_count] valueForKey:@"track_desc"];
                [playerSingleton sharedInstance].lyricsBy=[[_urls objectAtIndex:_count] valueForKey:@"track_author"];
                [playerSingleton sharedInstance].track_id=[[_urls objectAtIndex:_count] valueForKey:@"track_id"];
                
                _SongSpot=_count;
                PlayerAction=@"";
            }
            else if ([PlayerAction isEqualToString:@"prev"])
            {
                //_count=_count-1;
                [_Splayer play:[[_urls objectAtIndex:_count] valueForKey:@"track_file"]];
                [playerSingleton sharedInstance].songName=[[_urls objectAtIndex:_count] valueForKey:@"track_desc"];
                [playerSingleton sharedInstance].lyricsBy=[[_urls objectAtIndex:_count] valueForKey:@"track_author"];
                [playerSingleton sharedInstance].track_id=[[_urls objectAtIndex:_count] valueForKey:@"track_id"];
                
                _SongSpot=_count;
                PlayerAction=@"";
            }
            else
            {
                _count++;
                [_Splayer play:[[_urls objectAtIndex:_count] valueForKey:@"track_file"]];
                [playerSingleton sharedInstance].songName=[[_urls objectAtIndex:_count] valueForKey:@"track_desc"];
                [playerSingleton sharedInstance].lyricsBy=[[_urls objectAtIndex:_count] valueForKey:@"track_author"];
                [playerSingleton sharedInstance].track_id=[[_urls objectAtIndex:_count] valueForKey:@"track_id"];
                
                _SongSpot=_count;


            }
            
            
        }
        

        
        
    }
    _statusLabel=_Splayer.state == STKAudioPlayerStateBuffering ? @"buffering" : @"";

}

-(void)SongPlay:(NSString *)songName
{
    
    
    
        if (_Splayer.state == STKAudioPlayerStatePlaying)
        {
            [_Splayer pause];
            [[NSUserDefaults standardUserDefaults]setValue:@"Paused" forKey:@"NowPlaying"];
    
        }
        else if (_Splayer.state == STKAudioPlayerStatePaused)
        {
            [_Splayer resume];
            [[NSUserDefaults standardUserDefaults]setValue:@"Playing" forKey:@"NowPlaying"];
            songStop=NO;

        }
   
        else
        {
        
            [_Splayer play:songName];
            [[NSUserDefaults standardUserDefaults]setValue:@"Playing" forKey:@"NowPlaying"];
            songStop=NO;

        }
    
    //[timer1 invalidate];
}

-(void)SongPause
{
    [_Splayer pause];
}
-(void)SongResume
{
    [_Splayer resume];
}
-(void)SongStop:(NSString *)songName
{
    [[NSUserDefaults standardUserDefaults]setValue:@"Playing" forKey:@"NowPlaying"];

    [timer invalidate];
    [_Splayer play:songName];
    
   // [_Splayer stop];
    songStop=YES;
}
-(void)SeekingSong:(float)Value
{
    [_Splayer seekToTime:Value];
}
-(void)SongMute
{
    [_Splayer mute];
}
-(double)returningProgressValue
{
    return _Splayer.progress;
}
-(double)returningDurationValue
{
    return _Splayer.duration;
}
-(void)SongLocal:(NSURL *)url
{
    [timer invalidate];
    songStop=YES;
    STKDataSource* dataSource = [STKAudioPlayer dataSourceFromURL:url];
    dataSource=[STKAudioPlayer dataSourceFromURL:url];
    [_Splayer playDataSource:dataSource];
    [[NSUserDefaults standardUserDefaults]setValue:@"Playing" forKey:@"NowPlaying"];
    if ([_fromStatus isEqualToString:@"favourites"])
    {
        if (_favourites.count>1)
        {
            if (_SongSpot)
            {
                _count=_SongSpot;
                songStop=YES;
            }
            songStop=NO;
            [self setupTimer];
            
            
        }
        else
            [_Splayer playDataSource:dataSource];
    }
    else
    {
        if (_downloadedFiles.count>1)
        {
            if (_SongSpot)
            {
                _count=_SongSpot;
                songStop=YES;
            }
            songStop=NO;
            [self setupTimer];
            
            
        }
        else
            [_Splayer playDataSource:dataSource];
    }
    

    

}
-(void)PlayAllS:(NSArray *)UrlList
{
    [timer invalidate];
    [self setupTimer1];
    _count=0;
    _SongSpot=0;
    if (UrlList.count>1)
    {
        _urls=UrlList;
        [[NSUserDefaults standardUserDefaults]setValue:@"Playing" forKey:@"NowPlaying"];

        [_Splayer play:[[UrlList objectAtIndex:0] valueForKey:@"track_file"]];
        [playerSingleton sharedInstance].songName=[[_urls objectAtIndex:_count] valueForKey:@"track_desc"];
        [playerSingleton sharedInstance].lyricsBy=[[_urls objectAtIndex:_count] valueForKey:@"track_author"];
        [playerSingleton sharedInstance].track_id=[[_urls objectAtIndex:_count] valueForKey:@"track_id"];
        //count=1;
        
    }
//    AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:[[UrlList objectAtIndex:0] valueForKey:@"track_file"]] options:nil];
//    CMTime audioDuration = audioAsset.duration;
//    float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
}
-(void)FetchingDownloads
{
    NSFetchRequest* fetchRequest=[[NSFetchRequest alloc]initWithEntityName:@"SongDetails"];
    NSMutableArray * Songs=[[app.managedObjectContext executeFetchRequest:fetchRequest error:nil]mutableCopy];
    
    for (int i=0; i<Songs.count; i++)
    {
        
        NSManagedObject *Tracks=[Songs objectAtIndex:i];
        
        if ([Tracks valueForKey:@"songName"]!=nil)
        {
            [_downloadedFiles addObject:Tracks];
        }
        if ([[Tracks valueForKey:@"isFavourite"]isEqual:[NSNumber numberWithInt:1]])
        {
            [_favourites addObject:Tracks];
            
        }
         
    }
}
-(void)NextSong
{
    //[timer1 invalidate];
    PlayerAction=@"next";
    if ([_fromStatus isEqualToString:@"tracks"])
    {
        if (_SongSpot==_urls.count)
        {
            _SongSpot=0;
        }
        else
        {
            [_Splayer play:[[_urls objectAtIndex:_count] valueForKey:@"track_file"]];
            //songOver=NO;
            //[self tick1];
            //_SongSpot++;
            //count=_SongSpot;

        }
        
        
    }
    else
    {
        
    }
    
    //[self setupTimer1];

}
-(void)PreviouseSong
{
    PlayerAction=@"prev";
    if ([_fromStatus isEqualToString:@"tracks"])
    {
        if (_SongSpot!=0)
        {
            _count--;
            [_Splayer play:[[_urls objectAtIndex:_count] valueForKey:@"track_file"]];
            //_SongSpot--;

        }

    }
    else
    {
        
    }
}
-(void)FindingFile:(NSString *)filename
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *testpath = [documentsDirectory stringByAppendingPathComponent:filename];
   // NSLog(@"%@",testpath);
    NSURL* url = [NSURL fileURLWithPath:testpath];
    
    [self SongLocal:url];
}
@end
