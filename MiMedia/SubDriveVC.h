//
//  SubDriveVC.h
//  Flippy Cloud
//
//  Created by isquare3 on 11/23/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTSMessagingCell.h"
#import <Photos/Photos.h>
#import "HPGrowingTextView.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/UTCoreTypes.h>


@interface SubDriveVC : UIViewController<HPGrowingTextViewDelegate>
{
    HPGrowingTextView *messageTf;
    IBOutlet UICollectionView *photosCollectionCV;
    IBOutlet UIView *PhotoCollectionView,*MainCommentView,*SettingView;
    CGRect screenBounds;
    IBOutlet UIView *commentView;
    IBOutlet UIImageView *photoImageIV,*MemberImgView,*SettingImage;
    IBOutlet UIButton *sendCommBtn,*DeleteDriveBtn,*LeaveDriveBtn;
    IBOutlet UITextField *DriveNameTXT;
    IBOutlet UILabel *DriveNameLbl;
    IBOutlet UIButton *DriveNameEditBtn;

}
@property (strong) PHFetchResult *assetsFetchResults;
@property (strong) PHCachingImageManager* imageManager;
@property (strong,nonatomic) IBOutlet MPMoviePlayerController *moviePlayerController;

@property (nonatomic) UITapGestureRecognizer *tapRecognizer;
@property(strong,nonatomic)  IBOutlet UITableView *chatTableV;
@property (nonatomic,weak) IBOutlet UISegmentedControl *segment;
@property (nonatomic,strong) IBOutlet UIButton *AddMemberBtn;
@property (strong,nonatomic) IBOutlet UIButton *DeleteVideosBtn,*SettingPageBtn,*AddBtn,*InviteBtn;


@property (nonatomic,weak) IBOutlet UITableView *EmailTableView;

-(IBAction)DeleteAVideosBtnPressed:(id)sender;

//-(IBAction)DriveEditBtnPressed:(id)sender;

@end
