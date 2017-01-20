//
//  MusicVC.h
//  Flippy Cloud
//
//  Created by iSquare5 on 13/08/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MusicVC : UIViewController


@property (nonatomic,strong) IBOutlet UIButton *openMenu,*MediaControlBtn;
@property (nonatomic, retain) IBOutlet UIView* contentView,*introView,*nowPlayeing;
@property (nonatomic ,strong) IBOutlet UIImageView *artworkImageView;
@property (nonatomic,strong) IBOutlet UILabel *musicName,*status,*PlayerTitleSongName;
@property (nonatomic,strong)IBOutlet UILabel *TotalTime,*DurationTime;
//collectionView
@property (nonatomic,weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic,weak) IBOutlet UIImageView *ArtistPicView;
@property (nonatomic,strong) IBOutlet UIProgressView *myProgressView;
@property (nonatomic,strong) IBOutlet UISlider *myProgress;
//--stop


- (IBAction)showMediaPicker:(id)sender;

@end
