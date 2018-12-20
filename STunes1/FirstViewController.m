//
//  FirstViewController.m
//  Stunes
//
//  Created by Cocoalabs India on 17/10/16.
//  Copyright © 2016 Cocoalabs India. All rights reserved.
//

#import "FirstViewController.h"
#import "STKAudioPlayer.h"
#import "NetworkHandler.h"
#import "UIImageView+WebCache.h"
#import "playerSingleton.h"
#import "UpdateTVC.h"
#import "TracksVC.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "Reachability.h"

@interface FirstViewController ()<UICollectionViewDataSource,UITableViewDataSource,UITableViewDelegate,UICollectionViewDelegate>
{
    STKAudioPlayer *player;
    UIActivityIndicatorView *  spinner;
    NSArray *featuredAlbums;
    NSArray *Updates;
    NSTimer *timer;
    NSIndexPath *selectedIndexpath;
    NSString *Version;
    NSMutableArray *downloadedImages;
    NSArray *fAlbumImags;
    BOOL FromLocal;
    NSString *Dwd;

    Reachability *networkReachability;
    NetworkStatus networkStatus;
    
}
@property (nonatomic, assign) int currentSelectedIndex;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //player=[[STKAudioPlayer alloc]init];

    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [spinner setCenter:self.view.center]; // I do this because I'm in landscape mode
    [self.view addSubview:spinner]; // s
    [spinner setColor:[UIColor colorWithRed:0.133 green:0.302 blue:0.604 alpha:1.00]]; // s
    _PlayingViewHT.constant=0;
    Dwd=@"";
    
    networkReachability = [Reachability reachabilityForInternetConnection];
    networkStatus = [networkReachability currentReachabilityStatus];
    
    if (networkStatus == NotReachable)
    {
        //NSLog(@"There IS NO internet connection");
        FromLocal=YES;
        if ([[NSUserDefaults standardUserDefaults] valueForKey:@"Version_No"])
        {
            [self RefreshData];

//            if ([[NSUserDefaults standardUserDefaults] valueForKey:@"Version_No"])
//            {
//                [self RefreshData];
//            }
        }
        //        else
        //        {
        //            [self GettingDevotionalAlbums];
        //            [self GettingOtherAlbums];
        //        }
        
    }
    else
    {
       // NSLog(@"There IS internet connection");
        
        [self CheckVersion];

    }
    
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(LeftSwipe)];
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(RightSwipe)];
    
    // Setting the swipe direction.
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    downloadedImages=[[NSMutableArray alloc]init];
    
    [_ImgImages addGestureRecognizer:swipeLeft];
    [_ImgImages addGestureRecognizer:swipeRight];
    //FromLocal=YES;

    //_imgProfile.layer.borderColor=[[UIColor whiteColor]CGColor];
   
    
    [[NSUserDefaults standardUserDefaults]setValue:@"" forKey:@"resource"];

    
    
    
    [[NSUserDefaults standardUserDefaults]setValue:@"" forKey:@"NowPlaying"];
    
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)RefreshData
{
    if (Version)
    {
        if (FromLocal==NO)
        {
            [self GetHomDetails];
            [self GettingFeaturedAlbums];
            [self GettingUpdates];
            
        }
        else
        {
            NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"SliderImages"];
            NSArray *savedArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            _imagesArray=savedArray;
            
            _slider.numberOfPages=_imagesArray.count;
            NSData *imageData = UIImagePNGRepresentation(_imagesArray[0]);
            
            [_ImgImages setImage:[UIImage imageWithData:imageData]];
            
            
//            NSData *data1 = [[NSUserDefaults standardUserDefaults] objectForKey:@"AlbumImages"];
//            NSArray *savedArray1 = [NSKeyedUnarchiver unarchiveObjectWithData:data1];
            [self GettingFeaturedAlbums];
            
//            fAlbumImags=savedArray1;
            Updates=[[NSUserDefaults standardUserDefaults] valueForKey:@"Updates"];
           // NSLog(@"%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"Version_No"]);

            //[_featuredAlbumsCollection reloadData];
            [_tblUpdates reloadData];
        }
        
    }
    else
    {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"SliderImages"];
        NSArray *savedArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        _imagesArray=savedArray;

        _slider.numberOfPages=_imagesArray.count;
        NSData *imageData = UIImagePNGRepresentation(_imagesArray[0]);

        [_ImgImages setImage:[UIImage imageWithData:imageData]];
        
        
        NSData *data1 = [[NSUserDefaults standardUserDefaults] objectForKey:@"AlbumImages"];
        NSArray *savedArray1 = [NSKeyedUnarchiver unarchiveObjectWithData:data1];
        
        fAlbumImags=savedArray1;
        Updates=[[NSUserDefaults standardUserDefaults] valueForKey:@"Updates"];
        [_featuredAlbumsCollection reloadData];
        [_tblUpdates reloadData];
    }
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
-(void)LeftSwipe
{
    CATransition *transition = nil;
    if(self.currentSelectedIndex+1<self.imagesArray.count)
    {
        self.currentSelectedIndex++;
        transition = [CATransition animation];
        transition.duration = .3;//kAnimationDuration
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromRight;
        
        //self.ImgImages.image=[UIImage imageNamed:_currentImagesArray[_currentSelectedIndex]];
        if (FromLocal==YES)
        {
            NSData *imageData = UIImagePNGRepresentation([_imagesArray objectAtIndex:_currentSelectedIndex]);

            [_ImgImages setImage:[UIImage imageWithData:imageData]];
            
        }
        else
        {
            NSURL *url=[NSURL URLWithString:[_imagesArray objectAtIndex:_currentSelectedIndex]];
            [_ImgImages sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        }
        
        
        [self.ImgImages.layer addAnimation:transition forKey:nil];
        _slider.currentPage=_currentSelectedIndex;
    }
}
-(void)RightSwipe
{
    if(self.currentSelectedIndex>0)
    {
        self.currentSelectedIndex --;
        CATransition *transition = nil;
        transition = [CATransition animation];
        transition.duration = .3;//kAnimationDuration
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromLeft;
        
        if (FromLocal==YES)
        {
            NSData *imageData = UIImagePNGRepresentation([_imagesArray objectAtIndex:_currentSelectedIndex]);
            
            [_ImgImages setImage:[UIImage imageWithData:imageData]];
        }
        else
        {
            NSURL *url=[NSURL URLWithString:[_imagesArray objectAtIndex:_currentSelectedIndex]];
            [_ImgImages sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        }
        
        //self.imgImage.image=[UIImage imageNamed:_currentImagesArray[_currentSelectedIndex]];
        
        [self.ImgImages.layer addAnimation:transition forKey:nil];
        _slider.currentPage=_currentSelectedIndex;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;

{
    
        return 5;
    
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"MyCell" forIndexPath:indexPath];
    
    UIImageView *imgImage=[cell viewWithTag:10];
    
    
    if (fAlbumImags)
    {
       
        NSData *imageData = UIImagePNGRepresentation([fAlbumImags objectAtIndex:indexPath.row]);

        [imgImage setImage:[UIImage imageWithData:imageData]];
    }
    else
    {
        NSURL *url=[NSURL URLWithString:[[featuredAlbums valueForKey:@"cover_image"]objectAtIndex:indexPath.row]];
        [imgImage sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    }
    
    return cell;
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
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}
-(void)viewDidLayoutSubviews
{
    if (_TblHT.constant<_tblUpdates.contentSize.height)
    {
        _TblHT.constant=_tblUpdates.contentSize.height;
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

{
    if (Updates.count!=0)
    {
        if (Updates.count<3)
        {
            return Updates.count;
        }
        return 3;
    }
    
    
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

{
    UpdateTVC *cell=[tableView dequeueReusableCellWithIdentifier:@"MyCell" forIndexPath:indexPath];
    
    cell.lblUpdates.text=[[Updates objectAtIndex:indexPath.row] valueForKey:@"update_text"];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[Updates objectAtIndex:indexPath.row] valueForKey:@"update_url"]!=[NSNull null])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[Updates objectAtIndex:indexPath.row] valueForKey:@"update_url"]]];
    }
}
- (IBAction)PlayNdPause:(id)sender
{
    //[player play:@"http://cocoalabs.in/apis/musician/assets/uploads/60_album/226_track_file.mp3"];
}
-(void)DownloadImages:(NSArray *)UrlS
{
    
}
-(void)GetHomDetails
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
        //NSString *UrlString=@"http://cocoalabs.in/apis/musician/index.php/app/get_front_images";
        NSString *UrlString=@"http://drsamkadammanitta.com/mobileapp/index.php/app/get_front_images";
        [[NetworkHandler sharedHandler] requestWithRequestUrl:[NSURL URLWithString:UrlString] withBody:nil withMethodType:HTTPMethodGET withAccessToken:nil];
        [spinner startAnimating];
        [[NetworkHandler sharedHandler] startServieRequestWithSucessBlockSuccessBlock:^(id responseObject)
         {
             _imagesArray=[responseObject valueForKey:@"image_url"];
             _slider.numberOfPages=_imagesArray.count;
             
             NSURL *url=[NSURL URLWithString:[_imagesArray objectAtIndex:0]];
             [_ImgImages sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
             
             if (![Dwd isEqual:@""])
             {
                 NSMutableArray* images = [NSMutableArray arrayWithCapacity:_imagesArray.count];
                 for(int i = 0; i < _imagesArray.count; i++)
                     [images addObject:[NSNull null]];
                 for(int i = 0; i < _imagesArray.count; i++)
                 {
                     [spinner startAnimating];
                     NSURL* url = [NSURL URLWithString:_imagesArray[i]];
                     NSURLRequest* request = [NSURLRequest requestWithURL:url];
                     AFHTTPRequestOperation* op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                     op.responseSerializer = [AFImageResponseSerializer serializer];
                     [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation* operation, id responseObject)
                      {
                          
                          
                          UIImage* image = responseObject;
                          // NSLog(@"%@",responseObject);
                          [images replaceObjectAtIndex:i withObject:image];
                          //[[NSUserDefaults standardUserDefaults] setObject:images forKey:@"SliderImages"];
                          
                          NSData *dataSave = [NSKeyedArchiver archivedDataWithRootObject:images];
                          [[NSUserDefaults standardUserDefaults] setObject:dataSave forKey:@"SliderImages"];
                          
                          
                      } failure:^(AFHTTPRequestOperation* operation, NSError* error) {}];
                     
                     [op start];
                 }
             }
             
             
         }
                                                                         FailureBlock:^(NSString *errorDescription, id errorResponse)
         {
             [spinner stopAnimating];
             
             //NSLog(@"Error Response:%@",errorResponse);
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
-(void)CheckVersion
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
        //NSString *UrlString=@"http://cocoalabs.in/apis/musician/index.php/app/get_version_no";
        
        NSString *UrlString=@"http://drsamkadammanitta.com/mobileapp/index.php/app/get_version_no";
        
        [[NetworkHandler sharedHandler] requestWithRequestUrl:[NSURL URLWithString:UrlString] withBody:nil withMethodType:HTTPMethodGET withAccessToken:nil];
        [spinner startAnimating];
        [[NetworkHandler sharedHandler] startServieRequestWithSucessBlockSuccessBlock:^(id responseObject)
         {
             [spinner stopAnimating];
             Version=[responseObject valueForKey:@"version_no"];
             
             if ([[NSUserDefaults standardUserDefaults] valueForKey:@"Version_No"])
             {
                 if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"Version_No"]isEqual:[responseObject valueForKey:@"version_no"]])
                 {
                     FromLocal=YES;
                 }
                 else
                 {
                     [[NSUserDefaults standardUserDefaults] setValue:[responseObject valueForKey:@"version_no"] forKey:@"Version_No"];
                     FromLocal=NO;
                     Dwd=@"changed";
                 }
                 
             }
             else
             {
                 [[NSUserDefaults standardUserDefaults] setValue:[responseObject valueForKey:@"version_no"] forKey:@"Version_No"];
                 FromLocal=NO;
                 Dwd=@"changed";
             }
             [self RefreshData];
             
         }
                                                                         FailureBlock:^(NSString *errorDescription, id errorResponse)
         {
             [spinner stopAnimating];
             
             //NSLog(@"Error Response:%@",errorResponse);
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
-(void)GettingFeaturedAlbums
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
        [spinner startAnimating];
        
        //NSString *UrlString=@"http://cocoalabs.in/apis/musician/index.php/app/get_albums?offset=0&limit=10";
        
        NSString *UrlString=@"http://drsamkadammanitta.com/mobileapp/index.php/app/get_albums?offset=0&limit=10";
        [[NetworkHandler sharedHandler] requestWithRequestUrl:[NSURL URLWithString:UrlString] withBody:nil withMethodType:HTTPMethodGET withAccessToken:nil];
        [[NetworkHandler sharedHandler] startServieRequestWithSucessBlockSuccessBlock:^(id responseObject)
         {
             featuredAlbums=responseObject;
             
             NSData *dataSave = [NSKeyedArchiver archivedDataWithRootObject:featuredAlbums];
             [[NSUserDefaults standardUserDefaults] setObject:dataSave forKey:@"FAlbums"];
             
             if (![Dwd isEqual:@""])
             {
                 NSMutableArray* images = [NSMutableArray arrayWithCapacity:featuredAlbums.count];
                 for(int i = 0; i < featuredAlbums.count; i++)
                     [images addObject:[NSNull null]];
                 for(int i = 0; i < featuredAlbums.count; i++)
                 {
                     
                     NSURL* url = [NSURL URLWithString:[featuredAlbums[i] valueForKey:@"cover_image"]];
                     NSURLRequest* request = [NSURLRequest requestWithURL:url];
                     AFHTTPRequestOperation* op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                     op.responseSerializer = [AFImageResponseSerializer serializer];
                     [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation* operation, id responseObject)
                      {
                          if (i==featuredAlbums.count-1)
                          {
                              [_featuredAlbumsCollection reloadData];
                              
                          }
                          
                          
                          UIImage* image = responseObject;
                          //NSLog(@"%@",responseObject);
                          [images replaceObjectAtIndex:i withObject:image];
                          //[[NSUserDefaults standardUserDefaults] setObject:images forKey:@"SliderImages"];
                          
                          NSData *dataSave = [NSKeyedArchiver archivedDataWithRootObject:images];
                          [[NSUserDefaults standardUserDefaults] setObject:dataSave forKey:@"AlbumImages"];
                          
                          
                      } failure:^(AFHTTPRequestOperation* operation, NSError* error) {}];
                     
                     [op start];
                     
                     
                     
                 }
             }
             
             
             [spinner stopAnimating];
             
             
         }
                                                                         FailureBlock:^(NSString *errorDescription, id errorResponse)
         {
             [spinner stopAnimating];
             
             //NSLog(@"Error Response:%@",errorResponse);
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

-(void)GettingUpdates
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
        //NSString *UrlString=@"http://cocoalabs.in/apis/musician/index.php/app/get_updates";
        
        NSString *UrlString=@"http://drsamkadammanitta.com/mobileapp/index.php/app/get_updates";
        
        [[NetworkHandler sharedHandler] requestWithRequestUrl:[NSURL URLWithString:UrlString] withBody:nil withMethodType:HTTPMethodGET withAccessToken:nil];
        [spinner startAnimating];
        [[NetworkHandler sharedHandler] startServieRequestWithSucessBlockSuccessBlock:^(id responseObject)
         {
             [spinner stopAnimating];
             Updates=responseObject;
             
             //         NSMutableArray *updates=[[NSMutableArray alloc]init];
             //         for (int i=0;i<3;i++)
             //         {
             //             [updates addObject:[Updates objectAtIndex:i]];
             //         }
             [[NSUserDefaults standardUserDefaults]setObject:Updates forKey:@"Updates"];
             [_tblUpdates reloadData];
             
         }
                                                                         FailureBlock:^(NSString *errorDescription, id errorResponse)
         {
             [spinner stopAnimating];
             
             //NSLog(@"Error Response:%@",errorResponse);
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
- (IBAction)website:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://samkadammanitta.com/"]];
}
- (IBAction)Youtube:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.youtube.com/c/SamKadammanitta"]];

}
- (IBAction)Facebook:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.facebook.com/dr.sam.kadammanitta/"]];

}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"trackSegue"])
    {
        TracksVC *tr=(TracksVC *)segue.destinationViewController;
        
        if (featuredAlbums!=nil)
        {
            tr.Tracks=[featuredAlbums objectAtIndex:selectedIndexpath.row];

        }
    }
}
@end
