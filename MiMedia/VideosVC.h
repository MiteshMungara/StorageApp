//
//  VideosVC.h
//  MiMedia
//
//  Created by iSquare5 on 10/08/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import <MediaPlayer/MediaPlayer.h>
#import "RecipeViewCell.h"
#import "RecipeCollectionHeaderView.h"

@interface VideosVC : UIViewController
{
    AppDelegate *app;
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




@property (nonatomic, strong) ALAssetsLibrary *assetsLibraryys;
@property (nonatomic, strong) NSMutableArray *groupsss;
@property (nonatomic, strong) NSMutableArray *assetsss;
@property (nonatomic, strong) ALAssetsGroup *assetsGroupps;

@property (strong,nonatomic) IBOutlet MPMoviePlayerController *moviePlayerController;



@property (nonatomic,strong) IBOutlet UIButton *openMenu;
@property (nonatomic, retain) UIView* contentView;



@end
