//
//  BackupSyncVC.h
//  Flippy Cloud
//
//  Created by iSquare5 on 14/09/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import "ViewController.h"
#import <Photos/Photos.h>

#import <AssetsLibrary/AssetsLibrary.h>
#import "ALAssetsLibrary+CustomPhotoAlbum.h"


@import Photos;
@interface BackupSyncVC : ViewController
{

    CGRect screenBounds;
    IBOutlet UIImageView *photoImageVis;
    IBOutlet UIImageView *lineImageVis;
    
    IBOutlet UIView *photoViewss;
    IBOutlet UIView *acViews;
    IBOutlet UIView *bcViews,*video;
    IBOutlet UITableView *albumTableVis;
    IBOutlet UICollectionView *photosCollectionVis;
    NSArray *recipeImages;
    //
}



@property (nonatomic,strong) IBOutlet UIButton *PhotosBtn,*VideosBtn,*MusicBtn,*FilesBtn,*ContactBtn,*SelectallBtn;
@property (nonatomic, strong) ALAssetsLibrary *assLibrary;
@property (nonatomic, strong) NSMutableArray *grPss;
@property (nonatomic, strong) NSMutableArray *assARR;
@property (nonatomic, strong) ALAssetsGroup *assGroupps;


@property (strong) PHFetchResult *assetsFetchResults;
@property (strong) PHCachingImageManager* imageManager;


-(IBAction)backBtnPressed:(id)sender;
-(IBAction)SelectAllBtnPressed:(id)sender;
-(IBAction)PhotosBtnPressed:(id)sender;
-(IBAction)VideosAllBtnPressed:(id)sender;
-(IBAction)MusicAllBtnPressed:(id)sender;
-(IBAction)FilesAllBtnPressed:(id)sender;
-(IBAction)ContactAllBtnPressed:(id)sender;
-(IBAction)BackUpBtnPressed:(id)sender;


@end
