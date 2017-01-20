//
//  ManuallyPhotosVC.h
//  Flippy Cloud
//
//  Created by iSquare5 on 30/08/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import "ViewController.h"
#import "M13ProgressViewRing.h"
#import <Photos/Photos.h>

@interface ManuallyPhotosVC : ViewController
{
    IBOutlet UIView *procvessView;
    IBOutlet UILabel *processtextLabel;
    IBOutlet UIView *AnimationView;
    IBOutlet UIView *LeftButtonAnimationView;
    IBOutlet UIView *RightButtonAnimationView;
   // IBOutlet UIImage *AnimationImageV;
    // IBOutlet UICollectionView *photosCollectionVi;
}
@property (nonatomic, retain) IBOutlet M13ProgressViewRing *MainprogressView;
@property (nonatomic, retain) IBOutlet UISlider *progressSlider;
@property (nonatomic, retain) IBOutlet UIButton *animateButton;
@property (nonatomic, retain) IBOutlet UISegmentedControl *iconControl;
@property (nonatomic, retain) IBOutlet UISwitch *indeterminateSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *showPercentageSwitch;

@property (nonatomic,strong)IBOutlet UITableView *tableview;
@property (nonatomic,strong)IBOutlet UIButton *ProgreessBtn;
@property (nonatomic,strong)IBOutlet UIView *TableView,*ShowTableView;
-(IBAction)ProgressBtnPressed:(id)sender;

@property(nonatomic ,strong)IBOutlet UICollectionView *photosCollectionVi;
@property(nonatomic ,strong) IBOutlet UIView *introView,*StatusView;
@property(nonatomic,strong)IBOutlet UILabel *status;
@property (nonatomic, strong) UIImageView *customImageView;

@property (nonatomic, assign, getter = isActive) BOOL active;
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSURL *userPhotoURL;
-(IBAction)CameraBtnPressed:(id)sender;



@property (strong) PHFetchResult *assetsFetchResults;
@property (strong) PHCachingImageManager* imageManager;

@end
