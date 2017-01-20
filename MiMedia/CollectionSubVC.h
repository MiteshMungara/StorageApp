//
//  CollectionSubVC.h
//  Flippy Cloud
//
//  Created by iSquare5 on 20/08/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import "ViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "RecipeViewCell.h"
#import <Photos/Photos.h>
#import "RecipeCollectionHeaderView.h"


@interface CollectionSubVC : ViewController
{
    CGFloat animateDistance;

    CGRect screenBoundss;
    IBOutlet UIImageView *photoImageVii;
    IBOutlet UIImageView *lineImageVii;
    IBOutlet UIView *photoViewss;
    IBOutlet UIView *accView;
    IBOutlet UIView *bccView;
    IBOutlet UITableView *albumTableVii;
    IBOutlet UICollectionView *photosCollectionVii;
    NSArray *recipeImagess;
    
}
@property (strong) PHFetchResult *assetsFetchResults;
@property (strong) PHCachingImageManager* imageManager;
@property (nonatomic,strong)IBOutlet UIView *TableView,*ShowTableView;;
@property (nonatomic,strong)IBOutlet UITableView *tableview;
@property (nonatomic) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrarri;
@property (nonatomic, strong) NSMutableArray *groupsers;
@property (nonatomic, strong) NSMutableArray *assetsers;
@property (nonatomic, strong) ALAssetsGroup *assetsGroourp;
@property (nonatomic,strong) IBOutlet UIButton *MenuBtn;
@property (nonatomic,weak) IBOutlet UILabel *CollName;
@property (nonatomic,weak) IBOutlet UIView *collectionView,*EmptyView,*RenameCollView,*DeleteCollView,*ShareCollView,*RenameView;
@property (nonatomic,weak) IBOutlet UITextField *RenameCollTXT;
@property (nonatomic,weak) IBOutlet UIButton *RenameBackBtn,*RenameDoneBtn;

-(IBAction)RenameBackBtnPressed:(id)sender;
-(IBAction)RenameDoneBtnPressed:(id)sender;
-(IBAction)BackBtnPressed:(id)sender;
-(IBAction)MenuBtnPressed:(id)sender;
-(IBAction)DeleteCollBtnPressed:(id)sender;
-(IBAction)RenameCollBtnPressed:(id)sender;
-(IBAction)ShareCollBtnPressed:(id)sender;

@end
