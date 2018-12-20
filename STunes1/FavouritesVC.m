//
//  FavouritesVC.m
//  Stunes
//
//  Created by Cocoalabs India on 24/10/16.
//  Copyright © 2016 Cocoalabs India. All rights reserved.
//

#import "FavouritesVC.h"
#import "FavouriteTVC.h"
#import "STKAudioPlayer.h"
#import "playerSingleton.h"
#import "AppDelegate.h"
#import "TracksTVC.h"

@interface FavouritesVC ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *FavList;
    NSMutableArray *Songs;
    NSTimer *timer;
    AppDelegate *app;
}

@end

@implementation FavouritesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    app=(AppDelegate *)[UIApplication sharedApplication].delegate;
    FavList=[[ NSMutableArray alloc]init];
    
    
    
    // Do any additional setup after loading the view.
}

-(void) setupTimer
{
    
    timer = [NSTimer timerWithTimeInterval:0.001 target:self selector:@selector(tick) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}
-(void)tick
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
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [timer invalidate];
}
-(void)viewDidAppear:(BOOL)animated
{
    [self setupTimer];
    [FavList removeAllObjects];
    
    NSFetchRequest* fetchRequest=[[NSFetchRequest alloc]initWithEntityName:@"SongDetails"];
    Songs=[[app.managedObjectContext executeFetchRequest:fetchRequest error:nil]mutableCopy];
    
    
    for (int i=0; i<Songs.count; i++)
    {
        
        NSManagedObject *Tracks=[Songs objectAtIndex:i];
        
        if ([[Tracks valueForKey:@"isFavourite"]isEqual:[NSNumber numberWithInt:1]])
        {
            [FavList addObject:Tracks];
            
        }
        
        
    }
    if (FavList.count!=0)
    {
        [playerSingleton sharedInstance].favourites=FavList;

    }
    
    if (FavList.count==0) {
        _NoResultsView.hidden=NO;
    }
    else
        _NoResultsView.hidden=YES;
    [_tblFavs reloadData];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

{
    return FavList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    FavouriteTVC *cell=[tableView dequeueReusableCellWithIdentifier:@"MyCell" forIndexPath:indexPath];
    cell.lblSongName.text=[[FavList valueForKey:@"songName"] objectAtIndex:indexPath.row];
    cell.lblDetails.text=[[FavList valueForKey:@"albumName"] objectAtIndex:indexPath.row];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [playerSingleton sharedInstance].SongSpot=(int)indexPath.row;
    [playerSingleton sharedInstance].count=0;
    [[NSUserDefaults standardUserDefaults]setValue:@"storage" forKey:@"resource"];
    [playerSingleton sharedInstance].fromStatus=@"favourites";
    //////////
    [[NSUserDefaults standardUserDefaults]setValue:[[FavList valueForKey:@"songID"] objectAtIndex:indexPath.row] forKey:@"SongID"];
    //////////
    [self SongPlayeLocal:[[FavList valueForKey:@"songName"] objectAtIndex:indexPath.row]];
    
    if ([playerSingleton sharedInstance].favourites.count>[playerSingleton sharedInstance].SongSpot)
    {
        [self performSegueWithIdentifier:@"FavSegue" sender:self];

    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)SongPlayeLocal:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *testpath = [documentsDirectory stringByAppendingPathComponent:fileName];
    //NSLog(@"%@",testpath);
    NSURL* url = [NSURL fileURLWithPath:testpath];
    [[playerSingleton sharedInstance]SongLocal:url];
    
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
