//
//  CLAlertHandler.h
//  NetworkHandler
//
//  Created by Vaisakh krishnan on 3/11/15.
//  Copyright (c) 2015 CL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface CLAlertHandler : NSObject

+ (CLAlertHandler *)standardAlertHandler;

- (void)hideAlert;
- (void)showAlert:(NSString *)alertMessage title:(NSString *)title;
- (void)showAlert:(NSString *)alertMessage title:(NSString *)title delegate:(id)delegate;
- (void)showAlert:(NSString *)alertMessage alertTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelTitle otherButtonTitle:(NSString *)otherTitle delegate:(id)delegate;
- (void)showAlert:(NSString *)alertMessage withTag:(int)alertTag alertTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelTitle otherButtonTitle:(NSString *)otherTitle delegate:(id)delegate;
- (void)showAlert:(NSString *)alertMessage withTag:(int)alertTag title:(NSString *)title delegate:(id)delegate;

@end
