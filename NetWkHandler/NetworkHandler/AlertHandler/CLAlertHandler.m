//
//  CLAlertHandler.m
//  NetworkHandler
//
//  Created by Vaisakh krishnan on 3/11/15.
//  Copyright (c) 2015 CL. All rights reserved.
//

#import "CLAlertHandler.h"

@interface CLAlertHandler ()

@property (nonatomic,strong)UIAlertView *alert;

@end

@implementation CLAlertHandler

+ (CLAlertHandler *)standardAlertHandler {
    static CLAlertHandler *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark - UIAlert

- (void)showAlert:(NSString *)alertMessage title:(NSString *)title {
   self.alert =  [[UIAlertView alloc]initWithTitle:title message:alertMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [self.alert show];
}

- (void)showAlert:(NSString *)alertMessage title:(NSString *)title delegate:(id)delegate{
   self.alert =  [[UIAlertView alloc]initWithTitle:title message:alertMessage delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [self.alert show];
}

- (void)showAlert:(NSString *)alertMessage alertTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelTitle otherButtonTitle:(NSString *)otherTitle delegate:(id)delegate {
   self.alert =  [[UIAlertView alloc]initWithTitle:title message:alertMessage delegate:delegate cancelButtonTitle:cancelTitle otherButtonTitles:otherTitle, nil];
    [self.alert show];
}

- (void)showAlert:(NSString *)alertMessage withTag:(int)alertTag alertTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelTitle otherButtonTitle:(NSString *)otherTitle delegate:(id)delegate {
    self.alert =  [[UIAlertView alloc]initWithTitle:title message:alertMessage delegate:delegate cancelButtonTitle:cancelTitle otherButtonTitles:otherTitle, nil];
    self.alert.tag = alertTag;
    [self.alert show];
}

- (void)showAlert:(NSString *)alertMessage withTag:(int)alertTag title:(NSString *)title delegate:(id)delegate {
    self.alert =  [[UIAlertView alloc]initWithTitle:title message:alertMessage delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:nil];
    self.alert.tag = alertTag;
    [self.alert show];
}

- (void)hideAlert{
    [self.alert dismissWithClickedButtonIndex:0 animated:NO];
}

@end
