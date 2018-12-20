//
//  AlbumsVC.m
//  Stunes
//
//  Created by Cocoalabs India on 22/10/16.
//  Copyright © 2016 Cocoalabs India. All rights reserved.
//

#import "AlbumsVC.h"
#import "NetworkHandler.h"
#import "UIImageView+WebCache.h"
#import "TracksVC.h"
#import "STKAudioPlayer.h"
#import "playerSingleton.h"
#import "PlayerVC.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "Reachability.h"


@interface AlbumsVC ()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    NSArray *Devotional;
    NSArray *Others;
    NSIndexPath *selectedIndexpath;
    UIActivityIndicatorView*  spinner;
    NSTimer *timer;
    PlayerVC *playerVc;
    BOOL FromLocal;
    Reachability *networkReachability;
    NetworkStatus networkStatus;

    
}
@end

@implementation AlbumsVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [spinner setCenter:self.view.center]; // I do this because I'm in landscape mode
    [self.view addSubview:spinner]; // s
    [spinner setColor:[UIColor colorWithRed:0.133 green:0.302 blue:0.604 alpha:1.00]];
    
    
    networkReachability = [Reachability reachabilityForInternetConnection];
    networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable)
    {
       // NSLog(@"There IS NO internet connection");
        FromLocal=YES;
        if ([[NSUserDefaults standardUserDefaults] valueForKey:@"Version_No"])
        {
            NSData *data1 = [[NSUserDefaults standardUserDefaults] objectForKey:@"AlbumImages"];
            NSArray *savedArray1 = [NSKeyedUnarchiver unarchiveObjectWithData:data1];
            
            Devotional=savedArray1;
            
            NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"OtherAlbumImages"];
            NSArray *savedArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            
            Others=savedArray;
        }
//        else
//        {
//            [self GettingDevotionalAlbums];
//            [self GettingOtherAlbums];
//        }

    }
    else
    {
      //  NSLog(@"There IS internet connection");
        [self GettingDevotionalAlbums];
        [self GettingOtherAlbums];
    }
    
    _Segment.selectedSegmentIndex=0;
    
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
-(void)viewDidAppear:(BOOL)animated
{
    [self setupTimer];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [timer invalidate];
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;

{
    if (_Segment.selectedSegmentIndex==0)
    {
        return Others.count;
    }
    if (_Segment.selectedSegmentIndex==1)
    {
//        if (networkStatus == NotReachable)
//        {
//            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sorry" message:@"No internet access,check your connection" preferredStyle:UIAlertControllerStyleAlert];
//            UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                
//            }];
//            [alert addAction:action];
//            [self presentViewController:alert animated:YES completion:nil];
//        }
//        else
        return Devotional.count;
    }
    return 0;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"MyCell" forIndexPath:indexPath];
    UIImageView *imgImage=[cell viewWithTag:10];
    UILabel *lblName=[cell viewWithTag:11];
    
    if (_Segment.selectedSegmentIndex==0)
    {
        if (networkStatus == NotReachable)
        {
            NSData *imageData = UIImagePNGRepresentation([Others objectAtIndex:indexPath.row]);
            
            [imgImage setImage:[UIImage imageWithData:imageData]];
        }
        else
        {
        NSURL *url=[NSURL URLWithString:[[Others valueForKey:@"cover_image"]objectAtIndex:indexPath.row]];
        [imgImage sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        lblName.text=[[Others valueForKey:@"album_name"] objectAtIndex:indexPath.row];
        }

    }
    if (_Segment.selectedSegmentIndex==1)
    {
        if (networkStatus == NotReachable)
        {
            NSData *imageData = UIImagePNGRepresentation([Devotional objectAtIndex:indexPath.row]);
            
            [imgImage setImage:[UIImage imageWithData:imageData]];
        }
        else
        {
            NSURL *url=[NSURL URLWithString:[[Devotional valueForKey:@"cover_image"]objectAtIndex:indexPath.row]];
            [imgImage sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
            lblName.text=[[Devotional valueForKey:@"album_name"] objectAtIndex:indexPath.row];
        }
        
    }
    
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];

    CGFloat screenWidth = screenRect.size.width;
    //CGFloat screenHeight = screenRect.size.height;
    
    int cellWidth = (screenWidth - (4 * 8)) / 2;
    return CGSizeMake(cellWidth, cellWidth);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
{
    if (networkStatus == NotReachable)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sorry" message:@"No internet access,check your connection" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        selectedIndexpath=indexPath;
        [self performSegueWithIdentifier:@"trackSegue" sender:self];
    }
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"trackSegue"])
    {
        TracksVC *tr=(TracksVC *)segue.destinationViewController;
        
        
        if (_Segment.selectedSegmentIndex==0)
        {
            tr.Tracks=[Others objectAtIndex:selectedIndexpath.row];
        }
        else
            tr.Tracks=[Devotional objectAtIndex:selectedIndexpath.row];
    }
    if ([segue.identifier isEqualToString:@"playerSegue"])
    {
        
        UINavigationController *navController = [segue destinationViewController];
        playerVc = (PlayerVC *)([navController viewControllers][0]);
        
    }
    
    

    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (IBAction)Segment:(id)sender
{
    switch (_Segment.selectedSegmentIndex)
    {
        case 0:
            [_AlbumsCollection reloadData];
            break;
            case 1:
            [_AlbumsCollection reloadData];
            break;
        default:
            break;
    }
}
-(void)GettingDevotionalAlbums
{
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
        NSString *UrlString=@"http://drsamkadammanitta.com/mobileapp/index.php/app/get_albums?offset=0&limit=1000&type=1";
        
        [[NetworkHandler sharedHandler] requestWithRequestUrl:[NSURL URLWithString:UrlString] withBody:nil withMethodType:HTTPMethodGET withAccessToken:nil];
        [spinner startAnimating];
        [[NetworkHandler sharedHandler] startServieRequestWithSucessBlockSuccessBlock:^(id responseObject)
         {
             [spinner stopAnimating];
             Devotional=responseObject;
             
             [_AlbumsCollection reloadData];
             
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
             //NSLog(@"Error :%@",errorResponse);
             
             
         }];
    }
    
}
-(void)GettingOtherAlbums
{
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
        NSString *UrlString=@"http://drsamkadammanitta.com/mobileapp/index.php/app/get_albums?offset=0&limit=100&type=2";
        
        [[NetworkHandler sharedHandler] requestWithRequestUrl:[NSURL URLWithString:UrlString] withBody:nil withMethodType:HTTPMethodGET withAccessToken:nil];
        [spinner startAnimating];
        [[NetworkHandler sharedHandler] startServieRequestWithSucessBlockSuccessBlock:^(id responseObject)
         {
             [spinner stopAnimating];
             Others=responseObject;
             
             
             NSMutableArray* images = [NSMutableArray arrayWithCapacity:Others.count];
             for(int i = 0; i < Others.count; i++)
                 [images addObject:[NSNull null]];
             for(int i = 0; i < Others.count; i++)
             {
                 
                 NSURL* url = [NSURL URLWithString:[Others[i] valueForKey:@"cover_image"]];
                 NSURLRequest* request = [NSURLRequest requestWithURL:url];
                 AFHTTPRequestOperation* op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                 op.responseSerializer = [AFImageResponseSerializer serializer];
                 [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation* operation, id responseObject)
                  {
                      if (i==Others.count-1)
                      {
                          [_AlbumsCollection reloadData];
                          
                      }
                      
                      
                      UIImage* image = responseObject;
                      // NSLog(@"%@",responseObject);
                      [images replaceObjectAtIndex:i withObject:image];
                      //[[NSUserDefaults standardUserDefaults] setObject:images forKey:@"SliderImages"];
                      
                      NSData *dataSave = [NSKeyedArchiver archivedDataWithRootObject:images];
                      [[NSUserDefaults standardUserDefaults] setObject:dataSave forKey:@"OtherAlbumImages"];
                      
                      
                  } failure:^(AFHTTPRequestOperation* operation, NSError* error) {}];
                 
                 [op start];
                 
                 
                 
             }
             
             
             //  [_AlbumsCollection reloadData];
             
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
             //NSLog(@"Error :%@",errorResponse);
             
             
         }];
    }
    
}
@end
