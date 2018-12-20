//
//  TracksVC.m
//  Stunes
//
//  Created by Cocoalabs India on 25/10/16.
//  Copyright © 2016 Cocoalabs India. All rights reserved.
//

#import "TracksVC.h"
#import "NetworkHandler.h"
#import "UIImageView+WebCache.h"
#import "TracksTVC.h"
#import "STKAudioPlayer.h"
#import "PlayerVC.h"
#import "playerSingleton.h"
#import "AppDelegate.h"
#import "WDActivityIndicator.h"
#import "MBCircularProgressBarView.h"
#import "Reachability.h"

@interface TracksVC ()<UITableViewDataSource,UITableViewDelegate,STKAudioPlayerDelegate>
{
    NSString *albumID;
    NSArray *TrackList;
    NSArray *AlbumDetails;
     UIActivityIndicatorView *spinner;
    UIActivityIndicatorView *spinner1;

    Reachability *networkReachability;
    NetworkStatus networkStatus;
    
    STKAudioPlayer *player;
    NSString *selected;
    NSIndexPath *CurrentSelected;
    NSTimer* timer;
    PlayerVC *playerVc;
    TracksVC *tracksvc;
    NSString *Track_name;
    NSMutableArray *DownloadedTracks;
    AppDelegate *app;
    NSMutableArray *Songs;
    BOOL isFound;
    NSArray *tracks;
    NSString *LyricsBy;
    NSData *coverImgData;
    NSString *Track_id;
    NSString *Fr;

}
@end
@implementation TracksVC

@synthesize delegate;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    app=(AppDelegate *)[UIApplication sharedApplication].delegate;

    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [spinner setCenter:self.view.center]; // I do this because I'm in landscape mode
    [self.view addSubview:spinner]; // s
    [spinner setColor:[UIColor colorWithRed:0.133 green:0.302 blue:0.604 alpha:1.00]];
    
    spinner1 = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [spinner1 setCenter:self.view.center]; // I do this because I'm in landscape mode
    [self.view addSubview:spinner1]; // s
    [spinner1 setColor:[UIColor darkGrayColor]];
    
    isFound=NO;
    [self DownloadedFiles];
    _progressView.hidden=YES;
    _backGroundView.hidden=YES;
    _progressView.maxValue=100.f;
    NSURL *url=[NSURL URLWithString:[_Tracks valueForKey:@"cover_image"]];
    [self.imgCover sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    
    if (_imgCover)
    {
       coverImgData =UIImageJPEGRepresentation(_imgCover.image, 1);

    }
    
    albumID=[_Tracks valueForKey:@"album_id"];
    selected=@"";
    Track_name=@"";
    
    [self setupTimer];
    
    networkReachability = [Reachability reachabilityForInternetConnection];
    networkStatus = [networkReachability currentReachabilityStatus];
    
    [self gettingTracksList];
    

    // Do any additional setup after loading the view.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return TrackList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    TracksTVC *cell=[tableView dequeueReusableCellWithIdentifier:@"MyCell" forIndexPath:indexPath];
    
    cell.lblSongName.text=[[TrackList  valueForKey:@"track_desc"] objectAtIndex:indexPath.row];
    cell.lblDetails.text=[[AlbumDetails valueForKey:@"album_name"] objectAtIndex:0];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.imgP.tag=indexPath.row;
    
    
    

   // [cell.btnPlay addTarget:self action:@selector(yourButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TracksTVC *cell=[tableView cellForRowAtIndexPath:indexPath];
    cell.imgPlay.hidden=NO;
    [[NSUserDefaults standardUserDefaults]setValue:@"stream" forKey:@"resource"];
    Fr=@"tracks";
    [playerSingleton sharedInstance].albumname= cell.lblDetails.text;
    [playerSingleton sharedInstance].songName=cell.lblSongName.text;
    [playerSingleton sharedInstance].lyricsBy=[[TrackList  valueForKey:@"track_author"] objectAtIndex:indexPath.row];
    [playerSingleton sharedInstance].imgCover=[_Tracks valueForKey:@"cover_image"];
    [playerSingleton sharedInstance].track_id=[[TrackList valueForKey:@"track_id"]objectAtIndex:indexPath.row];

    if (indexPath!=CurrentSelected)
    {
        if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"NowPlaying"]isEqualToString:@"Playing"])
        {
            //[[playerSingleton sharedInstance]SongStop];

            [[playerSingleton sharedInstance]SongStop:[[TrackList valueForKey:@"track_file"] objectAtIndex:indexPath.row]];
        }
        else if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"NowPlaying"]isEqualToString:@"Paused"])
        {
            //[[playerSingleton sharedInstance]SongStop];

            [[playerSingleton sharedInstance]SongStop:[[TrackList valueForKey:@"track_file"] objectAtIndex:indexPath.row]];
        }
        else
            [[playerSingleton sharedInstance]SongStop:[[TrackList valueForKey:@"track_file"] objectAtIndex:indexPath.row]];


        CurrentSelected=indexPath;
        [playerSingleton sharedInstance].SongSpot=(int)indexPath.row;
        
        [self performSegueWithIdentifier:@"TrackSegue" sender:self];
        //[playerVc PlayingAnyWhere:[[TrackList valueForKey:@"track_file"] objectAtIndex:indexPath.row]];
        
        //[self.delegate addItemViewController:self didFinishSelectingTrack:[[TrackList valueForKey:@"track_file"] objectAtIndex:indexPath.row]];

    }
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TracksTVC *cell=[tableView cellForRowAtIndexPath:indexPath];
    cell.imgPlay.hidden=YES;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)ToStop
{
   // [[playerSingleton sharedInstance]SongStop];

}
-(void) setAudioPlayer:(STKAudioPlayer*)value
{
//    if (player)
//    {
//        player.delegate = nil;
//    }
//    
//    player = value;
//    player.delegate = self;
//    
//    [self updateControls];
}

-(void) updateControls
{
    TracksTVC *cell;
    if (player == nil)
    {
        [cell.btnPlay setTitle:@"" forState:UIControlStateNormal];
    }
    else if (player.state == STKAudioPlayerStatePaused)
    {
        [cell.btnPlay setImage:[UIImage imageNamed:@"play"]forState:UIControlStateNormal];
    }
    else if (player.state & STKAudioPlayerStatePlaying)
    {
        [cell.btnPlay setImage:[UIImage imageNamed:@"pause"]forState:UIControlStateNormal];
    }
    else
    {
        [cell.btnPlay setTitle:@"" forState:UIControlStateNormal];
    }
    
    //[self tick];
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

-(void)gettingTracksList
{
    networkStatus = [networkReachability currentReachabilityStatus];
    
    if (networkStatus == NotReachable)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Network Error" message:@"There is a problem connecting to the network. Please make sure that you have an active internet connection" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                 {
                                     
                                 }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        NSString *UrlString=@"http://drsamkadammanitta.com/mobileapp/index.php/app/get_album_details?album_id=";
        UrlString=[UrlString stringByAppendingString:albumID];
        
        [[NetworkHandler sharedHandler] requestWithRequestUrl:[NSURL URLWithString:UrlString] withBody:nil withMethodType:HTTPMethodGET withAccessToken:nil];
        [spinner startAnimating];
        [[NetworkHandler sharedHandler] startServieRequestWithSucessBlockSuccessBlock:^(id responseObject)
         {
             [spinner stopAnimating];
             AlbumDetails=responseObject;
             selected=[[AlbumDetails valueForKey:@"album_name"] objectAtIndex:0];
             
             TrackList=[[responseObject valueForKey:@"track_details"] objectAtIndex:0];
             
             [_tblTracks reloadData];
             
         }
                                                                         FailureBlock:^(NSString *errorDescription, id errorResponse)
         {
             [spinner stopAnimating];
             
             // NSLog(@"Error Response:%@",errorResponse);
             NSString *errorMessage;
             errorMessage=[errorResponse valueForKey:@"message"];
             if (errorResponse==nil)
             {
                 UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sorry" message:@"No internet access,check your connection" preferredStyle:UIAlertControllerStyleAlert];
                 UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                     
                 }];
                 [alert addAction:action];
                 [self presentViewController:alert animated:YES completion:nil];
             }
             else
             {
                 UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sorry" message:[[errorResponse objectAtIndex:0] valueForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
                 UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                     
                 }];
                 [alert addAction:action];
                 [self presentViewController:alert animated:YES completion:nil];
             }
             // NSLog(@"Error :%@",errorResponse);
             
             
         }];
    }
    
}
-(void)yourButtonClicked:(UIButton *)sender
{
    UIButton *senderButton = (UIButton *)sender;

    NSIndexPath *path=[NSIndexPath indexPathForRow:senderButton.tag inSection:0];
    
    TracksTVC *cell;
    [_tblTracks cellForRowAtIndexPath:path];
    
    if (!player)
    {
        return;
    }
    
    if (player.state == STKAudioPlayerStatePaused)
    {
        [player resume];
        [cell.btnPlay setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        
    }
    else
    {
        [player pause];
        [cell.btnPlay setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];

    }
}
- (IBAction)Play:(id)sender
{
   // UIButton *button = (UIButton *)sender;
    //UIView *contentView = button.superview;
    //TracksTVC *cell = (TracksTVC *)contentView.superview;
    
   // NSIndexPath *indexPath = [self.tblTracks indexPathForCell:cell];
    
    TracksTVC *cell;
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tblTracks];
    NSIndexPath *indexPath = [self.tblTracks indexPathForRowAtPoint:buttonPosition];
    cell=[_tblTracks cellForRowAtIndexPath:indexPath];
    
    if (cell.btnPlay.tag==indexPath.row)
    {
       // [cell.btnPlay setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
       // [self PlaySong:indexPath];
        
                if (player == nil)
                {
                    [cell.btnPlay setTitle:@"" forState:UIControlStateNormal];
                }
                else if (player.state == STKAudioPlayerStatePaused)
                {
                    [cell.btnPlay setImage:[UIImage imageNamed:@"pause"]forState:UIControlStateNormal];
                    [player resume];
                }
                else if (player.state & STKAudioPlayerStatePlaying)
                {
                    [cell.btnPlay setImage:[UIImage imageNamed:@"play"]forState:UIControlStateNormal];
                    [player pause];
                }
                else
                        {
                            [cell.btnPlay setImage:[UIImage imageNamed:@"pause"]forState:UIControlStateNormal];
                            [self PlaySong:indexPath];
                    
                        }
        
    }
    
    
    for(int i = 0; i < [TrackList count]; i++)
    {
        cell = [_tblTracks cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        
        if(cell.btnPlay.tag!=indexPath.row)
        {
            
            [cell.btnPlay setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        }
    }
    
    
//    if (player == nil)
//    {
//        [button setTitle:@"" forState:UIControlStateNormal];
//    }
//    else if (player.state == STKAudioPlayerStatePaused)
//    {
//        [button setImage:[UIImage imageNamed:@"play"]forState:UIControlStateNormal];
//       // [player resume];
//    }
//    else if (player.state & STKAudioPlayerStatePlaying)
//    {
//        [button setImage:[UIImage imageNamed:@"pause"]forState:UIControlStateNormal];
//       // [player pause];
//    }
//    else
//    {
//        [button setImage:[UIImage imageNamed:@"pause"]forState:UIControlStateNormal];
//       // [self PlaySong:indexPath];
//
//    }
//    
   // [_tblTracks reloadData];
    
}
-(void)PlaySong:(NSIndexPath *)index
{
    TracksTVC *cell=[_tblTracks cellForRowAtIndexPath:index];
    
    if (player.state==STKAudioPlayerStatePlaying)
    {
        if (cell.imgP.image!=[UIImage imageNamed:@"pause"])
        {
            [player play:[[TrackList valueForKey:@"track_file"] objectAtIndex:index.row]];
            [cell.imgP setImage:[UIImage imageNamed:@"pause"]];
        }
        
    }
    else
    {
        [player play:[[TrackList valueForKey:@"track_file"] objectAtIndex:index.row]];
        [cell.imgP setImage:[UIImage imageNamed:@"pause"]];

    }

   
    for(int i = 0; i < [TrackList count]; i++)
    {
        cell = [_tblTracks cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        
        if(cell.imgP.tag!=index.row)
        {
            
            [cell.imgP setImage:[UIImage imageNamed:@"play"]];
        }
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    [self setupTimer];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [timer invalidate];
}
-(void) setupTimer
{
    timer = [NSTimer timerWithTimeInterval:0.001 target:self selector:@selector(tick) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void) tick
{
    
    if ([playerSingleton sharedInstance].Splayer.state== STKAudioPlayerStatePlaying)
    {
        _NavPlayer.enabled=YES;
    }
    else if ([playerSingleton sharedInstance].Splayer.state== STKAudioPlayerStatePaused)
    {
        _NavPlayer.enabled=YES;
    }
    else
        _NavPlayer.enabled=NO;
    
    if ([[playerSingleton sharedInstance].statusLabel isEqualToString:@"buffering"]) {
        [spinner startAnimating];
    }
    else
        [spinner stopAnimating];

}
- (IBAction)Download:(id)sender
{
    [self DownloadedFiles];
    
    TracksTVC *cell;
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tblTracks];
    NSIndexPath *indexPath = [self.tblTracks indexPathForRowAtPoint:buttonPosition];
    cell=[_tblTracks cellForRowAtIndexPath:indexPath];
    Track_name=[[TrackList  valueForKey:@"track_desc"] objectAtIndex:indexPath.row];
    Track_id=[[TrackList valueForKey:@"track_id"] objectAtIndex:indexPath.row];
    LyricsBy=[[TrackList  valueForKey:@"track_author"] objectAtIndex:indexPath.row];
    
    
    if (DownloadedTracks.count!=0)
    {
        [self CheckingFiles];
        
        if (isFound==NO)
        {
            [self DownloadMp3file:[[TrackList valueForKey:@"track_file"] objectAtIndex:indexPath.row]];
            
        }
        else
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning" message:@"This file is already existed,Kindly check the downloads." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                     {
                                         isFound=NO;
                                         
                                     }];
            
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    else if (DownloadedTracks.count==0)
    {
        [self DownloadMp3file:[[TrackList valueForKey:@"track_file"] objectAtIndex:indexPath.row]];
        
        

    }

    

    
}
-(void)DownloadMp3file:(NSString *)Url
{
    
    if (isFound==NO)
    {
        //[spinner1 startAnimating];
        
        
        
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:Url]];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request] ;
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:Track_name];
        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
        [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)
        {
            if (_progressView.hidden==YES)
            {
                _progressView.hidden=NO;
                _backGroundView.hidden=NO;
                [[self navigationController] setNavigationBarHidden:YES animated:YES];
                [UIView animateWithDuration:15 animations:^{
                    self.progressView.value = 95.f - self.progressView.value;
                }];
            }
           // _progressView.value=(float) totalBytesRead/totalBytesExpectedToRead;
//            
//            if (totalBytesExpectedToRead > 0 && totalBytesRead <= totalBytesExpectedToRead)
//                _progressView.value = (CGFloat) totalBytesRead / totalBytesExpectedToRead;
////            else
////                _progressView.value = (totalBytesRead % 1000000l) / 1000000.0f;
           // NSLog(@"progress=====%f",(float) totalBytesRead/totalBytesExpectedToRead);
            
            if (totalBytesExpectedToRead > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.progressView.alpha = 1;
                    self.progressView.value = (CGFloat)totalBytesRead / totalBytesExpectedToRead;
                    NSString *label = [NSString stringWithFormat:@"Downloaded %lld of %lld bytes",
                                       totalBytesRead,
                                       totalBytesExpectedToRead];
                    //self.progressLabel.text = label;
                   // NSLog(@"progress=====%@",label);
                    

                });
            }


        }];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             //[spinner1 stopAnimating];
             _progressView.hidden=YES;
             _backGroundView.hidden=YES;
             [[self navigationController] setNavigationBarHidden:NO animated:YES];
             //NSLog(@"Successfully downloaded file to %@", path);
             
             UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success" message:@"Successfully downloaded." preferredStyle:UIAlertControllerStyleAlert];
             UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                 
             }];
             
             [alert addAction:action];
             [self presentViewController:alert animated:YES completion:nil];
             
             
             NSManagedObjectContext *context = [self managedObjectContext];
             
             // Create a new managed object
             NSManagedObject *SongDetails = [NSEntityDescription insertNewObjectForEntityForName:@"SongDetails" inManagedObjectContext:context];
             [SongDetails setValue:[[AlbumDetails valueForKey:@"album_name"] objectAtIndex:0] forKey:@"albumName"];
             [SongDetails setValue:Track_name forKey:@"songName"];
             [SongDetails setValue:LyricsBy forKey:@"lyrics"];
             [SongDetails setValue:coverImgData forKey:@"coverImg"];
             [SongDetails setValue:[NSNumber numberWithInteger:0] forKey:@"isFavourite"];
             [SongDetails setValue:[NSNumber numberWithInteger:[Track_id intValue]] forKey:@"songID"];
             
             NSError *error = nil;
             // Save the object to persistent store
             [self DownloadedFiles];
             if (![context save:&error]) {
                 //NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
             }
             NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
             NSEntityDescription *entity = [NSEntityDescription entityForName:@"SongDetails" inManagedObjectContext:context];
             [fetchRequest setEntity:entity];
             NSArray *fetched=[context executeFetchRequest:fetchRequest error:&error];
            // NSLog(@"%@",fetched);
             
             
         }
         
         
         
                                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            // NSLog(@"Error: %@", error);
                                             
                                         }];
        
        [operation start];
    }
    
}
-(void)DownloadedFiles
{
    DownloadedTracks=[[ NSMutableArray alloc]init];
    
    NSFetchRequest* fetchRequest=[[NSFetchRequest alloc]initWithEntityName:@"SongDetails"];
    Songs=[[app.managedObjectContext executeFetchRequest:fetchRequest error:nil]mutableCopy];
    
    for (int i=0; i<Songs.count; i++)
    {
        
        NSManagedObject *Tracks=[Songs objectAtIndex:i];
        
        if ([Tracks valueForKey:@"songName"]!=nil)
        {
            //DownloadedTracks[i]=[Tracks valueForKey:@"songName"];
            [DownloadedTracks addObject:Tracks];
            
            
        }
    }
    [playerSingleton sharedInstance].downloadedFiles=DownloadedTracks;
}
-(void)CheckingFiles
{
    for (int i=0; i<DownloadedTracks.count; i++)
    {
        if ([[[DownloadedTracks objectAtIndex:i] valueForKey:@"albumName"]isEqualToString:selected]&&[[[DownloadedTracks objectAtIndex:i] valueForKey:@"songName"] isEqualToString:Track_name])
        {
            isFound=YES;
            break;
            
        }
        
        
        
    }

}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"TrackSegue"]){
        
        UINavigationController *navController = [segue destinationViewController];
        playerVc = (PlayerVC *)([navController viewControllers][0]);
        playerVc.SongDetails= TrackList;
        playerVc.albumName=[[AlbumDetails valueForKey:@"album_name"] objectAtIndex:0];
        playerVc.CoverImage=[[AlbumDetails valueForKey:@"cover_image"] objectAtIndex:0];
        
        if (Fr)
        {
            playerVc.from=Fr;
            Fr=@"";
        }
    }
}


- (IBAction)PlayAll:(id)sender
{
    
    [playerSingleton sharedInstance].albumname=[[AlbumDetails valueForKey:@"album_name"] objectAtIndex:0];
    [playerSingleton sharedInstance].songName=Track_name;
    [playerSingleton sharedInstance].lyricsBy=[[TrackList  valueForKey:@"track_author"] objectAtIndex:0];
    [playerSingleton sharedInstance].imgCover=[_Tracks valueForKey:@"cover_image"];
    
    [[NSUserDefaults standardUserDefaults]setValue:@"stream" forKey:@"resource"];
    [playerSingleton sharedInstance].fromStatus=@"tracks";
    [[playerSingleton sharedInstance]PlayAllS:TrackList];
    
    
}
- (IBAction)DownloadLyrics:(id)sender
{
    if ([[AlbumDetails objectAtIndex:0] valueForKey:@"lyrics"]!=[NSNull null])
    {
        [spinner1 startAnimating];
        
        
        NSString *urlLyrics=[[AlbumDetails objectAtIndex:0] valueForKey:@"lyrics"];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlLyrics]];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request] ;
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:[[AlbumDetails valueForKey:@"album_name"] objectAtIndex:0]];
        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             [spinner1 stopAnimating];
             
             //NSLog(@"Successfully downloaded file to %@", path);
             
             UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success" message:@"Lyrics downloaded." preferredStyle:UIAlertControllerStyleAlert];
             UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                 
             }];
             
             [alert addAction:action];
             [self presentViewController:alert animated:YES completion:nil];
             
             
             
             
         }
         
         
         
                                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            // NSLog(@"Error: %@", error);
                                             
                                         }];
        
        [operation start];
    }
    else
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sorry" message:@"No more lyrics updloaded yet.." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}
@end
