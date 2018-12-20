//
//  DownloadsVC.m
//  STunes1
//
//  Created by Cocoalabs India on 31/10/16.
//  Copyright © 2016 Cocoalabs India. All rights reserved.
//

#import "DownloadsVC.h"
#import "STKAudioPlayer.h"
#import "AppDelegate.h"
#import "playerSingleton.h"
#import "TracksTVC.h"
#import <AVFoundation/AVFoundation.h>


@interface DownloadsVC ()<UITableViewDataSource,UITableViewDelegate>
{
    STKAudioPlayer *player;
    AppDelegate *app;
    NSMutableArray *Songs;
    NSMutableArray *DownloadedTracks;
    NSTimer *timer;
}

@end

@implementation DownloadsVC
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

    [self GettingDownloads];
    
    if (DownloadedTracks.count==0)
    {
        //NSLog(@"No Downloads Yet....");
    }
    else
    {
        
    }
    
    player=[[STKAudioPlayer alloc]init];
    

   
    
    
    // Do any additional setup after loading the view.
}
-(void) setupTimer
{
    
    timer = [NSTimer timerWithTimeInterval:0.001 target:self selector:@selector(tick) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}
-(void)tick
{
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"resource"]isEqualToString:@"storage"])
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
    
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [self setupTimer];
    if (DownloadedTracks.count!=0)
    {
        _NoResultsView.hidden=YES;
    }
    else
        _NoResultsView.hidden=NO;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return DownloadedTracks.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    TracksTVC *Cell=[tableView dequeueReusableCellWithIdentifier:@"MyCell" forIndexPath:indexPath];
    Cell.lblSongName.text=[[DownloadedTracks valueForKey:@"songName"] objectAtIndex:indexPath.row];
    Cell.lblDetails.text=[[DownloadedTracks valueForKey:@"albumName"] objectAtIndex:indexPath.row];
    Cell.selectionStyle=UITableViewCellSelectionStyleNone;

    
    return Cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [playerSingleton sharedInstance].SongSpot=(int)indexPath.row;
    [playerSingleton sharedInstance].currentSpot=(int)indexPath.row;
    [playerSingleton sharedInstance].count=0;
    [[NSUserDefaults standardUserDefaults]setValue:@"storage" forKey:@"resource"];
    [playerSingleton sharedInstance].fromStatus=@"downloads";
    //////////
    [[NSUserDefaults standardUserDefaults]setValue:[[DownloadedTracks valueForKey:@"songID"] objectAtIndex:indexPath.row] forKey:@"SongID"];
    //////////
    [self SongPlayeLocal:[[DownloadedTracks valueForKey:@"songName"] objectAtIndex:indexPath.row]];
    [self performSegueWithIdentifier:@"DownloadSegue" sender:self];
}
-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                          {
                                              if ([playerSingleton sharedInstance].currentSpot!=indexPath.row)
                                              {
                                                  UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Do you want to permanently delete this song?" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
                                                  
                                                  [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                                                  {
                                                      
                                                  }]];
                                                  [actionSheet addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action)
                                                  {
                                                      [self DeleteFile:[[DownloadedTracks valueForKey:@"songName"] objectAtIndex:indexPath.row]];
                                                      NSManagedObjectContext *context=[self managedObjectContext];
                                                      NSManagedObject *Deleteingredient=[DownloadedTracks objectAtIndex:indexPath.row];
                                                      [context deleteObject:Deleteingredient];
                                                      [DownloadedTracks removeObjectAtIndex:indexPath.row];
                                                      [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
                                                      
                                                      
                                                      NSError *error = nil;
                                                      // Save the object to persistent store
                                                      if (![context save:&error]) {
                                                          //NSLog(@"Can't delete ! %@ %@", error, [error localizedDescription]);
                                                      }
                                                  }]];
                                                  
                                                  [self presentViewController:actionSheet animated:YES completion:nil];

                                                  

                                              }
                                              else
                                              {
                                                  UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sorry" message:@"You can't delete currently playing file" preferredStyle:UIAlertControllerStyleAlert];
                                                  UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                                      
                                                  }];
                                                  [alert addAction:action];
                                                  [self presentViewController:alert animated:YES completion:nil];
                                              }
                                              
                                          }];
    
    
    deleteAction.backgroundColor = [UIColor redColor];
    return @[deleteAction];
}
-(void)GettingDownloads
{
    DownloadedTracks=[[ NSMutableArray alloc]init];
    
    NSFetchRequest* fetchRequest=[[NSFetchRequest alloc]initWithEntityName:@"SongDetails"];
    Songs=[[app.managedObjectContext executeFetchRequest:fetchRequest error:nil]mutableCopy];
    
    for (int i=0; i<Songs.count; i++)
    {
        
        NSManagedObject *Tracks=[Songs objectAtIndex:i];
        
        if ([Tracks valueForKey:@"songName"]!=nil)
        {
            [DownloadedTracks addObject:Tracks];
        
            
        }

        
    }
    [_tblDownloads reloadData];
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
- (void)DeleteFile:(NSString *)filename
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:filename];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (success)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success" message:@"This song has been removed permanently." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
        {
            [self viewDidAppear:NO];
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        //NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
