//
//  ImageViewVC.h
//  Flippy Cloud
//
//  Created by iSquare5 on 11/08/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "SDWebImage/UIImageView+WebCache.h"
@interface ImageViewVC : UIViewController
{
    AppDelegate *app;
}

@property (nonatomic,weak) IBOutlet UIImageView *likebuttonImageV;

@property (nonatomic,weak) IBOutlet UIImageView *BGImageView,*foreImageView,*infoImageView;
@property (nonatomic,strong) IBOutlet UIButton *favBtn,*infoBtn,*infoCancel,*backBtn,*editBtn,*ShareBtn,*menuBtn,*popAddFavBtn,*popInfoBtn,*popShareBtn,*popDeleteBtn,*popAddCollectionBtn,*popAddDriveBtn;
@property (nonatomic,strong) IBOutlet UIView *infoView,*view1,*view2,*view3,*view4,*view5,*view6 ,*CollectionSView;;
@property (nonatomic,strong) IBOutlet UILabel *line1L,*line2L,*line3L,*fileSizeL,*TakebL,*DimensionL,*TagsL,*removeFavL;
@property (nonatomic,strong) IBOutlet UITextField *picNameTxt;
@property (nonatomic) UITapGestureRecognizer *tapRecognizer;

//Collection View
@property (nonatomic,weak) IBOutlet UICollectionView *ColleCtionColl,*DriveColl;
@property (nonatomic,weak) IBOutlet UILabel *collTitleL;
//Stop


//zooming with scrollview 
@property (nonatomic,weak) IBOutlet UIScrollView *scrollView;
//

-(IBAction)backBtnPressed:(id)sender;
-(IBAction)favoriteBtnPressed:(id)sender;
-(IBAction)infoBtnPressed:(id)sender;
-(IBAction)infoCancelBtnPressed:(id)sender;
-(IBAction)editBtnPressed:(id)sender;
-(IBAction)shareBtnpressed:(id)sender;
-(IBAction)menuBtnPressed:(id)sender;

-(IBAction)popShareBtnPressed:(id)sender;
-(IBAction)popAddDriveBtnPressed:(id)sender;
-(IBAction)popAddCollectionBtnPressed:(id)sender;
-(IBAction)popDeleteBtnPressed:(id)sender;
-(IBAction)popAddFavBtnPressed:(id)sender;
-(IBAction)popInfoBtnPressed:(id)sender;
-(IBAction)CancelBtnPressed:(id)sender;

@end
