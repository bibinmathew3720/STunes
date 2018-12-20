//
//  DownloadsVC.h
//  STunes1
//
//  Created by Cocoalabs India on 31/10/16.
//  Copyright © 2016 Cocoalabs India. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadsVC : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tblDownloads;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *NavPlayer;
@property (weak, nonatomic) IBOutlet UIView *NoResultsView;

@end
