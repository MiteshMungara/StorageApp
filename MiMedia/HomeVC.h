//
//  HomeVC.h
//  MiMedia
//
//  Created by iSquare5 on 09/08/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import "ALAssetsLibrary+CustomPhotoAlbum.h"

#import "RecipeViewCell.h"
#import "RecipeCollectionHeaderView.h"


@interface HomeVC : UIViewController
{
    AppDelegate *app;
    CGRect screenBounds;
    IBOutlet UIImageView *photoImageV;
    IBOutlet UIImageView *lineImageV;
    IBOutlet UIImageView *upDownBtnImageV;
    IBOutlet UIButton *backPGPBtn;
    IBOutlet UIButton *nextPGPBtn;
    IBOutlet UIButton *upDownBtn;
    IBOutlet UIView *photoView;
    IBOutlet UIView *aView;
    IBOutlet UIView *bView;
    IBOutlet UITableView *albumTableV;
    IBOutlet UICollectionView *photosCollectionV;
    NSArray *recipeImages;
    
}




@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *groups;
@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, strong) ALAssetsGroup *assetsGroup;

@property (nonatomic,strong) IBOutlet UIButton *openMenu;
@property (nonatomic, retain) UIView* contentView;
//- (IBAction)openMenu:(id)sender;





@end
