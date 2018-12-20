//
//  MoreVC.m
//  Stunes
//
//  Created by Cocoalabs India on 24/10/16.
//  Copyright © 2016 Cocoalabs India. All rights reserved.
//

#import "MoreVC.h"
#import "AppDelegate.h"
#import "MoreTVC.h"
#import <MessageUI/MessageUI.h>

@interface MoreVC ()<UITableViewDataSource,UITableViewDelegate,MFMailComposeViewControllerDelegate>
{
    NSArray *MenuItems;
    AppDelegate *app;
}
@end

@implementation MoreVC

- (void)viewDidLoad {
    [super viewDidLoad];
   /// MenuItems=@[@"downloads",@"updates",@"contact"];
    MenuItems=@[@"updates",@"contact"];

    // Do any additional setup after loading the view.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return MenuItems.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    MoreTVC *cell=[tableView dequeueReusableCellWithIdentifier:[MenuItems objectAtIndex:indexPath.row] forIndexPath:indexPath];
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.row==1)
    {
        [self ComposeMail];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)ComposeMail
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
        [composeViewController setMailComposeDelegate:self];
        [composeViewController setToRecipients:@[@"samkadammanitta@gmail.com"]];
        [composeViewController setSubject:@"Enquiry form for STunes"];
        [self presentViewController:composeViewController animated:YES completion:nil];
    }
    else
    {
        //NSLog(@"Mail services are not available.");
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sorry" message:@"You should sing in with your mail service." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    //Add an alert in case of failure
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

@end
