//
//  PlayerVC.h
//  Stunes
//
//  Created by Cocoalabs India on 19/10/16.
//  Copyright © 2016 Cocoalabs India. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STKAudioPlayer.h"

@interface PlayerVC : UIViewController

@property (weak, nonatomic) IBOutlet UIProgressView *ProgressBar;
@property (strong, nonatomic) IBOutlet UILabel *illapsingTime;
@property (weak, nonatomic) IBOutlet UILabel *lblDuration;
@property (strong, nonatomic) IBOutlet UILabel *lblSongName;
@property (weak, nonatomic) IBOutlet UIButton *btnPlayOrPause;
- (IBAction)playAndpause:(id)sender;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (readwrite, retain) STKAudioPlayer* player;
@property (nonatomic,retain) NSArray* SongDetails;
@property (weak, nonatomic) IBOutlet UIButton *favButton;
- (IBAction)Favourite:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
- (IBAction)Next:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnPrev;
@property (nonatomic,retain) NSString *albumName;
@property (nonatomic,retain) NSURL*CoverImage;
@property (nonatomic,retain) NSString *trackID;
@property (nonatomic,retain) NSString *from;

- (IBAction)Previous:(id)sender;
- (IBAction)Share:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblAlbumName;
@property (weak, nonatomic) IBOutlet UILabel *lblLyrics;
@property (weak, nonatomic) IBOutlet UILabel *lblSinger;
@property (weak, nonatomic) IBOutlet UIImageView *ImgCover;
- (IBAction)SYdoFav:(id)sender;

- (IBAction)Info:(id)sender;


@end
