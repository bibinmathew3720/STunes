//
//  SecondViewController.m
//  Stunes
//
//  Created by Cocoalabs India on 17/10/16.
//  Copyright © 2016 Cocoalabs India. All rights reserved.
//

#import "SecondViewController.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "Reachability.h"

@interface SecondViewController ()
{
    Reachability *networkReachability;
    NetworkStatus networkStatus;
    UIActivityIndicatorView *  spinner;
}
@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [spinner setCenter:self.view.center]; // I do this because I'm in landscape mode
    [self.view addSubview:spinner]; // s
    [spinner setColor:[UIColor colorWithRed:0.133 green:0.302 blue:0.604 alpha:1.00]]; // s
    
    networkReachability = [Reachability reachabilityForInternetConnection];
    networkStatus = [networkReachability currentReachabilityStatus];
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
    NSString *urlString = @"http://cocoa-labs.co.uk/apis/stunes/index.php/about";
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [_WebView loadRequest:urlRequest];
    }
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)webViewDidStartLoad:(UIWebView *)webView
{
    //SHOW HUD
    [spinner startAnimating];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    //KILL HUD
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    
    if(!webView.loading)
    {
        //KILL HUD
        [spinner stopAnimating];        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
