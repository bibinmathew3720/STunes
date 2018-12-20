//
//  PlayerVC.m
//  Stunes
//
//  Created by Cocoalabs India on 19/10/16.
//  Copyright © 2016 Cocoalabs India. All rights reserved.
//

#import "PlayerVC.h"
#import "STKAudioPlayer.h"
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "TracksVC.h"
#import "playerSingleton.h"
#import "UIImageView+WebCache.h"
#import "SYFavoriteButton.h"

@interface PlayerVC ()<STKAudioPlayerDelegate>

{
    //STKAudioPlayer *player;
    NSTimer *timer;
    AppDelegate *app;
    UIActivityIndicatorView *spinner;
    NSManagedObject *Ddata;
    bool isfav;
    //int i;
}

@end

@implementation PlayerVC
- (NSManagedObjectContext *)managedObjectContext
{
    
    NSManagedObjectContext *context = nil;
    id delegat = [[UIApplication sharedApplication] delegate];
    if ([delegat performSelector:@selector(managedObjectContext)])
    {
        context = [delegat managedObjectContext];
    }
    return context;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    app=(AppDelegate *)[UIApplication sharedApplication].delegate;

    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [spinner setCenter:self.view.center]; // I do this because I'm in landscape mode
    [self.view addSubview:spinner]; // s
    [spinner setColor:[UIColor colorWithRed:0.133 green:0.302 blue:0.604 alpha:1.00]]; // s
    
    
    
    
    //[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];

    UIImage *thumbImageNormal = [UIImage imageNamed:@"dot"];
    [self.slider setThumbImage:thumbImageNormal forState:UIControlStateNormal];
    _favButton.hidden=YES;
    
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"NowPlaying"]isEqualToString:@"Playing"])
    {
        [_btnPlayOrPause setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];

    }
    if ([_from isEqualToString:@"tracks"])
    {
        _btnNext.enabled=NO;
        _btnPrev.enabled=NO;
    }
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"resource"]isEqualToString:@"storage"])
    {
        _btnNext.enabled=NO;
        _btnPrev.enabled=NO;
        [self updateInfo];
    }
    else
    {
        _btnNext.enabled=YES;
        if ([playerSingleton sharedInstance].SongSpot==0)
        {
            _btnPrev.enabled=NO;
        }
        else
            _btnPrev.enabled=YES;
         [_ImgCover sd_setImageWithURL:[playerSingleton sharedInstance].imgCover placeholderImage:[UIImage imageNamed:@"placeholder.png"]];

    }
    
    
   // _lblSongName.text=_albumName;
    [self setupTimer];

    

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setupTimer
{
    
    timer = [NSTimer timerWithTimeInterval:0.001 target:self selector:@selector(tick) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}
-(NSString*) formatTimeFromSeconds:(int)totalSeconds
{
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    //int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

-(void) tick
{
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"resource"]isEqualToString:@"storage"])
    {
        
    }
    else
    {
        if ([playerSingleton sharedInstance].SongSpot==0)
        {
            _btnPrev.enabled=NO;
        }
        else
            _btnPrev.enabled=YES;
    }
    
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"resource"]isEqualToString:@"storage"])
    {
        if ([playerSingleton sharedInstance].songOver==NO)
        {
            [self updateInfo];
        }
        
        
    }
    else
    {
        _lblSongName.text=[playerSingleton sharedInstance].songName;
        _lblAlbumName.text=[playerSingleton sharedInstance].albumname;
        _lblLyrics.text=[playerSingleton sharedInstance].lyricsBy;
        _lblSinger.text=[playerSingleton sharedInstance].singer;
        _trackID=[playerSingleton sharedInstance].track_id;
        if ([playerSingleton sharedInstance].urls.count-1==[playerSingleton sharedInstance].count)
        {
            _btnNext.enabled=NO;
        }
        else
            _btnNext.enabled=YES;
        
        if ([_from isEqualToString:@"tracks"])
        {
            _btnNext.enabled=NO;
            _btnPrev.enabled=NO;
        }
    }
    if ([[playerSingleton sharedInstance]returningDurationValue] != 0)
    {
        _slider.minimumValue = 0;
        _slider.maximumValue = [[playerSingleton sharedInstance]returningDurationValue];
        _slider.value =     [[playerSingleton sharedInstance]returningProgressValue];;

        _illapsingTime.text = [NSString stringWithFormat:@"%@", [self formatTimeFromSeconds:[[playerSingleton sharedInstance]returningProgressValue]]];
        _lblDuration.text=[NSString stringWithFormat:@"%@", [self formatTimeFromSeconds:[[playerSingleton sharedInstance]returningDurationValue]]];
        
        
        
            //_ProgressBar.progress = (player.progress/player.duration);
        [_ProgressBar setProgress:(float)(_player.progress/_player.duration)];
        
    }
    else
    {
        _slider.value = 0;
        _slider.minimumValue = 0;
        _slider.maximumValue = 0;
        
        _illapsingTime.text =  [NSString stringWithFormat:@"%@", [self formatTimeFromSeconds:_player.progress]];
    }
    if ([[playerSingleton sharedInstance].statusLabel isEqual:@"buffering"]) {
        [spinner startAnimating];
    }
    else
        [spinner stopAnimating];
    
    
    
}

-(void) updateControls
{
    if (_player == nil)
    {
        [_btnPlayOrPause setTitle:@"" forState:UIControlStateNormal];
    }
    else if (_player.state == STKAudioPlayerStatePaused)
    {
        [_btnPlayOrPause setTitle:@"Resume" forState:UIControlStateNormal];
    }
    else if (_player.state & STKAudioPlayerStatePlaying)
    {
        [_btnPlayOrPause setTitle:@"Pause" forState:UIControlStateNormal];
    }
    else
    {
        [_btnPlayOrPause setTitle:@"" forState:UIControlStateNormal];
    }
    
    [self tick];
}
-(void) setAudioPlayer:(STKAudioPlayer*)value
{
//    if (_player)
//    {
//        _player.delegate = nil;
//    }
//    
//    _player = value;
//    _player.delegate = self;
    
}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer unexpectedError:(STKAudioPlayerErrorCode)errorCode
{
    [self updateControls];
}
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didStartPlayingQueueItemId:(NSObject*)queueItemId
{
//    SampleQueueId* queueId = (SampleQueueId*)queueItemId;
//    
//    NSLog(@"Started: %@", [queueId.url description]);
    
    [self updateControls];
}

//-(void) audioPlayer:(STKAudioPlayer*)audioPlayer stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState
//{
//    [self updateControls];
//}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject*)queueItemId
{
    [self updateControls];
    
    // This queues on the currently playing track to be buffered and played immediately after (gapless)
    
//    if (repeatSwitch.on)
//    {
//        SampleQueueId* queueId = (SampleQueueId*)queueItemId;
//        
//        NSLog(@"Requeuing: %@", [queueId.url description]);
//        
//        [self->audioPlayer queueDataSource:[STKAudioPlayer dataSourceFromURL:queueId.url] withQueueItemId:[[SampleQueueId alloc] initWithUrl:queueId.url andCount:queueId.count + 1]];
//    }
}
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishPlayingQueueItemId:(NSObject*)queueItemId withReason:(STKAudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration
{
    [self updateControls];
    
//    SampleQueueId* queueId = (SampleQueueId*)queueItemId;
//    
//    NSLog(@"Finished: %@", [queueId.url description]);
}
- (IBAction)close:(id)sender
{
    //[_player stop];
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)SliderChanged:(id)sender
{
    
    
    //NSLog(@"Slider Changed: %f", _slider.value);
    
    [[playerSingleton sharedInstance]SeekingSong:_slider.value];
}

- (IBAction)playAndpause:(id)sender
{
    
    [[playerSingleton sharedInstance]SongPlay:@"http://cocoalabs.in/apis/musician/assets/uploads/60_album/226_track_file.mp3"];



        if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"NowPlaying"]isEqualToString:@"Paused"])
    {
        [_btnPlayOrPause setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];

    }
    else if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"NowPlaying"]isEqualToString:@"Playing"])
    {
        [_btnPlayOrPause setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    }
    else
        [_btnPlayOrPause setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];

    
}
- (IBAction)Favourite:(id)sender
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSError *error = nil;
   
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"SongDetails" inManagedObjectContext:context];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"songID == %@", [NSNumber numberWithInteger:[[[NSUserDefaults standardUserDefaults] valueForKey:@"SongID"] intValue]]];
        [fetchRequest setEntity:entity];
        
        [fetchRequest setPredicate:predicate];
        
        id result=[context executeRequest:fetchRequest error:&error];
        Ddata =[[result finalResult] mutableCopy];
    
    if (isfav==NO)
    {
        [Ddata setValue:[NSNumber numberWithInteger:1] forKey:@"isFavourite"];
        
        if (![context save:&error]) {
           // NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        
        //[_favButton setTintColor:[UIColor redColor]];
        [_favButton setImage:[UIImage imageNamed:@"fav-filled"] forState:UIControlStateNormal];
        //[self buttonAction:favoriteButton];
        isfav=YES;
        //NSLog(@"%@",result);
    }
    else if (isfav==YES)
    {
        [Ddata setValue:[NSNumber numberWithInteger:0] forKey:@"isFavourite"];
        
        if (![context save:&error]) {
            //NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        
//        [_favButton setTintColor:[UIColor blueColor]];
        [_favButton setImage:[UIImage imageNamed:@"favs"] forState:UIControlStateNormal];

        
        
        isfav=NO;
        //NSLog(@"%@",result);
    }
    
}
- (IBAction)Next:(id)sender
{
    [[playerSingleton sharedInstance]NextSong];
}
- (IBAction)Previous:(id)sender
{
    [[playerSingleton sharedInstance]PreviouseSong];
}

- (IBAction)Share:(id)sender
{
    NSString *url=@"http://drsamkadammanitta.com/mobileapp/index.php/app/get_track_url/";
    
    //url=[url stringByAppendingFormat:@"%@",_trackID];
    url=[url stringByAppendingString:[playerSingleton sharedInstance].track_id];
    NSURL *ShareUrl=[NSURL URLWithString:url];
    [self shareText:@"Share this track" andImage:_ImgCover.image andUrl:ShareUrl];
}
- (void)shareText:(NSString *)text andImage:(UIImage *)image andUrl:(NSURL *)url
{
    NSMutableArray *sharingItems = [NSMutableArray new];
    
    if (text) {
        [sharingItems addObject:text];
    }
    if (image) {
        [sharingItems addObject:image];
    }
    if (url) {
        [sharingItems addObject:url];
    }
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
}
-(void)updateInfo
{
    int indx=[playerSingleton sharedInstance].SongSpot;

    
    if ([[playerSingleton sharedInstance].fromStatus isEqualToString:@"favourites"])
    {
//        if ([[playerSingleton sharedInstance].favourites objectAtIndex:indx]!=0)
//        {
//            _lblLyrics.text=[[[playerSingleton sharedInstance].favourites objectAtIndex:indx] valueForKey:@"lyrics"];
//            _lblAlbumName.text=[[[playerSingleton sharedInstance].favourites objectAtIndex:indx] valueForKey:@"albumName"];
//            _lblSongName.text=[[[playerSingleton sharedInstance].favourites objectAtIndex:indx] valueForKey:@"songName"];
//            _ImgCover.image=[UIImage imageWithData:[[[playerSingleton sharedInstance].favourites objectAtIndex:indx] valueForKey:@"coverImg"]];
//            
//            _trackID=[[NSUserDefaults standardUserDefaults] valueForKey:@"SongID"];
//            _favButton.hidden=NO;
//            if ([[[[playerSingleton sharedInstance].favourites objectAtIndex:indx] valueForKey:@"isFavourite"]isEqual:[NSNumber numberWithInt:1]])
//            {
//                isfav=YES;
//                //[_favButton setTintColor:[UIColor redColor]];
//                [_favButton setImage:[UIImage imageNamed:@"fav-filled"] forState:UIControlStateNormal];
//                
//            }
//            else
//            {
//                isfav=NO;
//                //[_favButton setTintColor:[UIColor blueColor]];
//                [_favButton setImage:[UIImage imageNamed:@"favs"] forState:UIControlStateNormal];
//                
//                
//            }
//        }
        
        for (int j=0; j<[playerSingleton sharedInstance].downloadedFiles.count; j++)
        {
            if ([[[[playerSingleton sharedInstance].downloadedFiles objectAtIndex:j] valueForKey:@"songID"]isEqual:[[NSUserDefaults standardUserDefaults] valueForKey:@"SongID"]])
            {
                _lblLyrics.text=[[[playerSingleton sharedInstance].downloadedFiles objectAtIndex:j] valueForKey:@"lyrics"];
                _lblAlbumName.text=[[[playerSingleton sharedInstance].downloadedFiles objectAtIndex:j] valueForKey:@"albumName"];
                _lblSongName.text=[[[playerSingleton sharedInstance].downloadedFiles objectAtIndex:j] valueForKey:@"songName"];
                _ImgCover.image=[UIImage imageWithData:[[[playerSingleton sharedInstance].downloadedFiles objectAtIndex:j] valueForKey:@"coverImg"]];
                
                _trackID=[[NSUserDefaults standardUserDefaults] valueForKey:@"SongID"];
                _favButton.hidden=NO;
                if ([[[[playerSingleton sharedInstance].downloadedFiles objectAtIndex:j] valueForKey:@"isFavourite"]isEqual:[NSNumber numberWithInt:1]])
                {
                    isfav=YES;
                    //[_favButton setTintColor:[UIColor redColor]];
                    [_favButton setImage:[UIImage imageNamed:@"fav-filled"] forState:UIControlStateNormal];
                    
                }
                else
                {
                    isfav=NO;
                    //[_favButton setTintColor:[UIColor blueColor]];
                    [_favButton setImage:[UIImage imageNamed:@"favs"] forState:UIControlStateNormal];
                    
                    
                }
            }
        }
        
        
    }
    else
    {
        _lblLyrics.text=[[[playerSingleton sharedInstance].downloadedFiles objectAtIndex:indx] valueForKey:@"lyrics"];
        _lblAlbumName.text=[[[playerSingleton sharedInstance].downloadedFiles objectAtIndex:indx] valueForKey:@"albumName"];
        _lblSongName.text=[[[playerSingleton sharedInstance].downloadedFiles objectAtIndex:indx] valueForKey:@"songName"];
        _ImgCover.image=[UIImage imageWithData:[[[playerSingleton sharedInstance].downloadedFiles objectAtIndex:indx] valueForKey:@"coverImg"]];
        
        _trackID=[[NSUserDefaults standardUserDefaults] valueForKey:@"SongID"];
        _favButton.hidden=NO;
        if ([[[[playerSingleton sharedInstance].downloadedFiles objectAtIndex:indx] valueForKey:@"isFavourite"]isEqual:[NSNumber numberWithInt:1]])
        {
            isfav=YES;
            //[_favButton setTintColor:[UIColor redColor]];
            [_favButton setImage:[UIImage imageNamed:@"fav-filled"] forState:UIControlStateNormal];
            
        }
        else
        {
            isfav=NO;
            //[_favButton setTintColor:[UIColor blueColor]];
            [_favButton setImage:[UIImage imageNamed:@"favs"] forState:UIControlStateNormal];
            
            
        }
    }
    
    
    
}
- (IBAction)SYdoFav:(SYFavoriteButton *)sender
{
    sender.selected = !sender.selected;

}

- (IBAction)Info:(id)sender
{
    
}
@end
