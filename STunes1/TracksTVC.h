//
//  TracksTVC.h
//  Stunes
//
//  Created by Cocoalabs India on 25/10/16.
//  Copyright © 2016 Cocoalabs India. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TracksTVC : UITableViewCell



@property (weak, nonatomic) IBOutlet UIImageView *imgImage;
@property (weak, nonatomic) IBOutlet UILabel *lblSongName;
@property (weak, nonatomic) IBOutlet UILabel *lblDetails;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay;
- (IBAction)Play:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnDownload;
- (IBAction)Download:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imgPlay;
@property (weak, nonatomic) IBOutlet UIImageView *imgP;
@end
