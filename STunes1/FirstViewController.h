//
//  FirstViewController.h
//  Stunes
//
//  Created by Cocoalabs India on 17/10/16.
//  Copyright © 2016 Cocoalabs India. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface FirstViewController : UIViewController
@property (weak, nonatomic) IBOutlet UICollectionView *featuredAlbumsCollection;
@property (weak, nonatomic) IBOutlet UIButton *btnplayNpause;
- (IBAction)PlayNdPause:(id)sender;
@property (weak, nonatomic) IBOutlet UIPageControl *slider;

//for image slider
@property (nonatomic, strong) NSArray *imagesArray;
@property (nonatomic, assign) int selecetdIndex;
@property (weak, nonatomic) IBOutlet UIImageView *ImgImages;
@property (weak, nonatomic) IBOutlet UIView *NowPlayingView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *PlayingViewHT;
@property (weak, nonatomic) IBOutlet UIImageView *imgProfile;
@property (weak, nonatomic) IBOutlet UITableView *tblUpdates;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *TblHT;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *NavPlayer;



@end

