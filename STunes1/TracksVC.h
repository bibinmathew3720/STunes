//
//  TracksVC.h
//  Stunes
//
//  Created by Cocoalabs India on 25/10/16.
//  Copyright © 2016 Cocoalabs India. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TracksVC.h"
#import "MBCircularProgressBarView.h"
@class TracksVC;
@protocol TracksDelegate <NSObject>
- (void)addItemViewController:(TracksVC *)controller didFinishSelectingTrack:(NSString *)item;
@end

@interface TracksVC : UIViewController
@property (nonatomic, weak) id <TracksDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *imgCover;
@property (weak, nonatomic) IBOutlet UITableView *tblTracks;
@property (nonatomic,retain) NSArray *Tracks;
@property (weak, nonatomic) IBOutlet UIImageView *imgP;
@property (weak, nonatomic) IBOutlet UIButton *btnPlayAll;
- (IBAction)PlayAll:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *backGroundView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *NavPlayer;
@property (weak, nonatomic) IBOutlet UILabel *lblstatus;
@property (weak, nonatomic) IBOutlet MBCircularProgressBarView *progressView;
@end
