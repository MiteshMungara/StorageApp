//
//  PhotosVC.h
//  MiMedia
//
//  Created by iSquare5 on 10/08/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"


#import <AssetsLibrary/AssetsLibrary.h>
#import "ALAssetsLibrary+CustomPhotoAlbum.h"

#import "RecipeViewCell.h"
#import "RecipeCollectionHeaderView.h"



@interface PhotosVC : UIViewController

{
    AppDelegate *app;
    CGRect screenBounds;
    IBOutlet UIImageView *photoImageVi;
    IBOutlet UIImageView *lineImageVi;

    IBOutlet UIView *photoViews;
    IBOutlet UIView *acView;
    IBOutlet UIView *bcView;
    IBOutlet UITableView *albumTableVi;
    IBOutlet UICollectionView *photosCollectionVi;
    NSArray *recipeImages;
//
}




@property (nonatomic, strong) ALAssetsLibrary *assetsLibraryy;
@property (nonatomic, strong) NSMutableArray *groupss;
@property (nonatomic, strong) NSMutableArray *assetss;
@property (nonatomic, strong) ALAssetsGroup *assetsGroupp;


@property (nonatomic,strong) IBOutlet UIButton *openMenu;
@property (nonatomic, retain) UIView* contentView;

-(IBAction)UploadBtnPressed:(id)sender;

@end
