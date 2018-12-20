//
//  UpdatesVC.m
//  Stunes
//
//  Created by Cocoalabs India on 24/10/16.
//  Copyright © 2016 Cocoalabs India. All rights reserved.
//

#import "UpdatesVC.h"
#import "NetworkHandler.h"
#import "UpdateTVC.h"
#import "AppDelegate.h"
#import "playerSingleton.h"
#import "STKAudioPlayer.h"
#import "Reachability.h"

@interface UpdatesVC ()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray *Updates;
    UIActivityIndicatorView *spinner;
    AppDelegate *app;
    NSTimer *timer;
    Reachability *networkReachability;
    NetworkStatus networkStatus;
    
}
@end

@implementation UpdatesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [spinner setCenter:self.view.center]; // I do this because I'm in landscape mode
    [self.view addSubview:spinner]; // s
    [spinner setColor:[UIColor colorWithRed:0.133 green:0.302 blue:0.604 alpha:1.00]];
    
    networkReachability = [Reachability reachabilityForInternetConnection];
    networkStatus = [networkReachability currentReachabilityStatus];
    
    
    [self GettingUpdates];
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return Updates.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    UpdateTVC *cell=[tableView dequeueReusableCellWithIdentifier:@"MyCell" forIndexPath:indexPath];
    cell.lblUpdates.text=[[Updates objectAtIndex:indexPath.row] valueForKey:@"update_text"];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return  cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[Updates objectAtIndex:indexPath.row] valueForKey:@"update_url"]!=[NSNull null])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[Updates objectAtIndex:indexPath.row] valueForKey:@"update_url"]]];
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)GettingUpdates
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
        NSString *UrlString=@"http://drsamkadammanitta.com/mobileapp/index.php/app/get_updates";
        
        [[NetworkHandler sharedHandler] requestWithRequestUrl:[NSURL URLWithString:UrlString] withBody:nil withMethodType:HTTPMethodGET withAccessToken:nil];
        [spinner startAnimating];
        [[NetworkHandler sharedHandler] startServieRequestWithSucessBlockSuccessBlock:^(id responseObject)
         {
             [spinner stopAnimating];
             Updates=responseObject;
             
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
             // NSLog(@"Error :%@",errorResponse);
             
             
         }];
        
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
