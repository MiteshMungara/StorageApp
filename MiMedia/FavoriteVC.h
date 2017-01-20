//
//  FavoriteVC.h
//  Flippy Cloud
//
//  Created by iSquare5 on 13/08/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import "ALAssetsLibrary+CustomPhotoAlbum.h"

#import "RecipeViewCell.h"
#import "RecipeCollectionHeaderView.h"


@interface FavoriteVC : UIViewController
{
    AppDelegate *app;
    CGRect screenBoundss;
    IBOutlet UIView *bccView,*introView;
    IBOutlet UICollectionView *photosCollectionVii;
    NSArray *recipeImagess;
}

@property (nonatomic, strong) IBOutlet UIView *emptyView;
@property (nonatomic, strong) IBOutlet UIImageView *photoImageVii;
@property (nonatomic,strong) IBOutlet UIButton *openMenu;
@property (nonatomic, retain)  UIView* contentView;
@property (nonatomic,strong) IBOutlet UIImageView *liked;


@end
