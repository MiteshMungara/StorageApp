//
//  ManuallyVideosVC.h
//  Flippy Cloud
//
//  Created by iSquare5 on 01/09/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import "ViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/UTCoreTypes.h>
@interface ManuallyVideosVC : ViewController


@property(nonatomic ,strong) IBOutlet UICollectionView *photosCollectionVi;
@property(nonatomic ,strong) IBOutlet UIView *introView,*video;
@property(nonatomic,strong) IBOutlet UILabel *status;
@property (strong,nonatomic) IBOutlet MPMoviePlayerController *moviePlayerController;
@property (strong,nonatomic) IBOutlet UIImageView *imageView;
@property (strong,nonatomic) IBOutlet UIButton *DeleteVideosBtn;

-(IBAction)DeleteAVideosBtnPressed:(id)sender;

@end
