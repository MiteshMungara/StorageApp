//
//  HomeVC.m
//  MiMedia
//
//  Created by iSquare5 on 09/08/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import "HomeVC.h"
#import "ImageViewVC.h"
#import "SidebarViewController.h"
#import "AlbumContentsViewController.h"
#import "AssetsDataIsInaccessibleViewController.h"
#import "ImageCollectionViewCell.h"
#import "BIZGrid4plus1CollectionViewLayout.h"



@interface HomeVC ()
{
   
    UIButton *Homebtn;
}
@property (nonatomic, retain) SidebarViewController* sidebarVC;

@end

BOOL downView = NO;
BOOL tableClicked = YES;
int countIndex=0;

@implementation HomeVC
@synthesize assetsLibrary,groups,assets,assetsGroup;

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    
    
    
    app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    screenBounds = [[UIScreen mainScreen] bounds];
    NSData * cpdata =[[NSUserDefaults standardUserDefaults]valueForKey:@"cameraImageKey"];
    photoImageV.image = [UIImage imageWithData:cpdata];
    downView = NO;
    countIndex=0;
    
    photoView.frame=CGRectMake(0, 0, screenBounds.size.width, screenBounds.size.height-100);
    aView.frame=CGRectMake(-screenBounds.size.width, photoView.frame.size.height, screenBounds.size.width, screenBounds.size.height-photoView.frame.size.height);
    bView.frame=CGRectMake(0, 60, screenBounds.size.width, screenBounds.size.height-photoView.frame.size.height);
    
//    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(slideToUpWithGestureRecognizer:)];
//    swipeRight.direction = UISwipeGestureRecognizerDirectionUp;
//    [self.view addGestureRecognizer:swipeRight];
    
//   UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(slideToDownWithGestureRecognizer:)];

//   swipeLeft.direction = UISwipeGestureRecognizerDirectionDown;
//  [self.view addGestureRecognizer:swipeLeft];

    if (assetsLibrary == nil)
    {
        assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    if (groups == nil)
    {
        groups = [[NSMutableArray alloc] init];
    }
    else
    {
        [groups removeAllObjects];
    }
//  setup our failure view controller in case enumerateGroupsWithTypes fails
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error)
    {
        AssetsDataIsInaccessibleViewController *assetsDataInaccessibleViewController =
        [self.storyboard instantiateViewControllerWithIdentifier:@"inaccessibleViewController"];
        NSString *errorMessage = nil;
        switch ([error code])
        {
            case ALAssetsLibraryAccessUserDeniedError:
            case ALAssetsLibraryAccessGloballyDeniedError:
                errorMessage = @"The user has declined access to it.";
                break;
            default:
                errorMessage = @"Reason unknown.";
                break;
        }
        assetsDataInaccessibleViewController.explanation = errorMessage;
        [self presentViewController:assetsDataInaccessibleViewController animated:NO completion:nil];
    };
    // emumerate through our groups and only add groups that contain photos
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop)
    {
        
        ALAssetsFilter *onlyPhotosFilter =
        [ALAssetsFilter allPhotos];
        ALAssetsFilter *onlyPhotosFilter2 = [ALAssetsFilter allVideos];
        [group setAssetsFilter:onlyPhotosFilter];
        if ([group numberOfAssets] > 0)
        {
            [groups insertObject:group atIndex:0];
            tableClicked = YES;
            if (groups.count > 0)
            {
                self.assetsGroup = groups[0];
                if (!assets)
                {
                    assets = [[NSMutableArray alloc] init];
                }
                else
                {
                    [assets removeAllObjects];
                }
                ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    
                    if (result) {
                        [assets insertObject:result atIndex:0];
                    }
                };
                ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
                [assetsGroup setAssetsFilter:onlyPhotosFilter];
                [assetsGroup enumerateAssetsUsingBlock:assetsEnumerationBlock];
                [photosCollectionV reloadData];
            }
        }
        else
        {
            [albumTableV performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
    };
    // enumerate only photos
    NSUInteger groupTypes = ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces | ALAssetsGroupSavedPhotos ;
    [self.assetsLibrary enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock failureBlock:failureBlock];
    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panDetected:)];
    [panGesture delaysTouchesBegan];
    [self.view addGestureRecognizer:panGesture];
    self.sidebarVC = [[SidebarViewController alloc] init];
    [self.sidebarVC setBgRGB:0x000000];
    self.sidebarVC.view.frame  = self.view.bounds;
    [self.view addSubview:self.sidebarVC.view];
    [self.sidebarVC showHideSidebar];
}

//UICollectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return assets.count;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionHeader)
    {
        RecipeCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        headerView.title.text = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
        [headerView.backToAlbumBtn addTarget:self action:@selector(backToAlbumBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        reusableview = headerView;
    }
    return reusableview;
}
-(void)backToAlbumBtnTapped:(id)sender
{
    tableClicked = NO;
    if (downView == NO)
    {
        [UIView animateWithDuration:0.3
                         animations:^{
                             aView.frame=CGRectMake(0, photoView.frame.size.height, screenBounds.size.width, screenBounds.size.height-photoView.frame.size.height);
                             bView.frame=CGRectMake(screenBounds.size.width,60, screenBounds.size.width, screenBounds.size.height-photoView.frame.size.height);
                         }
                         completion:^(BOOL finished){;}];
    }
    else
    {
        [UIView animateWithDuration:0.3
                         animations:^{
                             aView.frame=CGRectMake(0, photoView.frame.size.height-180, screenBounds.size.width, screenBounds.size.height-photoView.frame.size.height+180);
                             bView.frame=CGRectMake(screenBounds.size.width,60, screenBounds.size.width, screenBounds.size.height-photoView.frame.size.height+180);
                         }
                         completion:^(BOOL finished){;}];
    }
}
- (ImageCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[ImageCollectionViewCell reuseIdentifier] forIndexPath:indexPath];
    ALAsset *asset = self.assets[indexPath.row];
    CGImageRef thumbnailImageRef = [asset thumbnail];
    UIImage *thumbnail = [UIImage imageWithCGImage:thumbnailImageRef];
    UIImageView *recipeImageView = (UIImageView *)[cell viewWithTag:100];
    recipeImageView.image = thumbnail;
    cell.contentView.backgroundColor = [UIColor clearColor];
    if (indexPath.row == countIndex)
    {
        photoImageV.image =thumbnail;
    }
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    countIndex = -1;
    int i=(int)indexPath.row;
    app.SelImgId=[NSString stringWithFormat:@"%i",i];
    [photosCollectionV reloadItemsAtIndexPaths:[photosCollectionV indexPathsForVisibleItems]];
    ALAsset *asset = self.assets[indexPath.row];
    CGImageRef thumbnailImageRef=[asset thumbnail];
    UIImage *thumbnail = [UIImage imageWithCGImage:thumbnailImageRef];
    photoImageV.image = thumbnail;
    app.imagepath=[NSString stringWithFormat:@"%@",asset];
    app.view=@"home";
    //navigation
    UINavigationController *navigationController = (UINavigationController *)app.window.rootViewController;
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    ImageViewVC *MainPage = (ImageViewVC*)[mainStoryboard instantiateViewControllerWithIdentifier: @"ImageViewVC"];
    [navigationController pushViewController:MainPage animated:YES];
    //---- stop
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor clearColor];
}

//stop

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (IBAction)show:(id)sender
{
    [self.sidebarVC showHideSidebar];
}
- (void)panDetected:(UIPanGestureRecognizer*)recoginzer
{
    [self.sidebarVC panDetected:recoginzer];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
