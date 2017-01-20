//
//  PhotosVC.m
//  MiMedia
//
//  Created by iSquare5 on 10/08/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import "PhotosVC.h"
#import "SidebarViewController.h"
#import "ImageViewVC.h"
#import "Base64.h"
#import "UIImagePickerController+HiddenAPIs.h"
#import "AlbumContentsViewController.h"
#import "AssetsDataIsInaccessibleViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ImageCollectionViewCell.h"
#import "BIZGrid4plus1CollectionViewLayout.h"




@interface PhotosVC ()<UIImagePickerControllerHiddenAPIDelegate, UINavigationControllerDelegate>
@property (nonatomic, retain) SidebarViewController* sidebarVC;
@end

BOOL downViews = NO;
BOOL tableClickedd = YES;
int countIndexx=0;

@implementation PhotosVC
@synthesize assetsLibraryy,groupss,assetss,assetsGroupp;

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.sidebarVC = [[SidebarViewController alloc] init];
    [self.sidebarVC setBgRGB:0x000000];
    self.sidebarVC.view.frame  = self.view.bounds;
    [self.view addSubview:self.sidebarVC.view];
    [self.sidebarVC showHideSidebar];
//  AppDelegate *app;
    app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    screenBounds = [[UIScreen mainScreen] bounds];
    NSData * cpdata =[[NSUserDefaults standardUserDefaults]valueForKey:@"cameraImageKey"];
    photoImageVi.image = [UIImage imageWithData:cpdata];
    downViews = NO;
    countIndexx=0;
    photoViews.frame=CGRectMake(0, 0, screenBounds.size.width, screenBounds.size.height-100);
    acView.frame=CGRectMake(-screenBounds.size.width, photoViews.frame.size.height, screenBounds.size.width, screenBounds.size.height-photoViews.frame.size.height);
    bcView.frame=CGRectMake(0, 60, screenBounds.size.width, screenBounds.size.height-photoViews.frame.size.height);
    
    if (assetsLibraryy == nil)
    {
        assetsLibraryy = [[ALAssetsLibrary alloc] init];
    }
    if (groupss == nil)
    {
        groupss = [[NSMutableArray alloc] init];
    }
    else
    {
        [groupss removeAllObjects];
    }
    
    // setup our failure view controller in case enumerateGroupsWithTypes fails
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
        ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
        [group setAssetsFilter:onlyPhotosFilter];
        if ([group numberOfAssets] > 0)
        {
            [groupss insertObject:group atIndex:0];
            //call photosCollectionV
            tableClickedd = YES;
            if (groupss.count > 0)
            {
                self.assetsGroupp = groupss[0];
                if (!assetss)
                {
                    assetss = [[NSMutableArray alloc] init];
                }
                else
                {
                    [assetss removeAllObjects];
                }
                ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop)
                {
                    if (result)
                    {
                        [assetss insertObject:result atIndex:0];
                    }
                };
                ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
                [assetsGroupp setAssetsFilter:onlyPhotosFilter];
                [assetsGroupp enumerateAssetsUsingBlock:assetsEnumerationBlock];
                [photosCollectionVi reloadData];
            }
        }
        else
        {
            [albumTableVi performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
    };
    // enumerate only photos
    NSUInteger groupTypes = ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces | ALAssetsGroupSavedPhotos;
    [self.assetsLibraryy enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock failureBlock:failureBlock];
}
//UICollectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return assetss.count;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionHeader)
    {
        RecipeCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        headerView.title.text = [self.assetsGroupp valueForProperty:ALAssetsGroupPropertyName];
        [headerView.backToAlbumBtn addTarget:self action:@selector(backToAlbumBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        reusableview = headerView;
    }
    return reusableview;
}
-(void)backToAlbumBtnTapped:(id)sender
{
    tableClickedd = NO;
    if (downViews == NO)
    {
        [UIView animateWithDuration:0.3
                         animations:^{
                             acView.frame=CGRectMake(0, photoViews.frame.size.height, screenBounds.size.width, screenBounds.size.height-photoViews.frame.size.height);
                             bcView.frame=CGRectMake(screenBounds.size.width,60, screenBounds.size.width, screenBounds.size.height-photoViews.frame.size.height);
                         }
                         completion:^(BOOL finished){;}];
    }
    else
    {
        [UIView animateWithDuration:0.3
                         animations:^{
                             acView.frame=CGRectMake(0, photoViews.frame.size.height-180, screenBounds.size.width, screenBounds.size.height-photoViews.frame.size.height+180);
                             bcView.frame=CGRectMake(screenBounds.size.width,60, screenBounds.size.width, screenBounds.size.height-photoViews.frame.size.height+180);
                         }
                         completion:^(BOOL finished){;}];
    }
}
- (ImageCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[ImageCollectionViewCell reuseIdentifier] forIndexPath:indexPath];
    ALAsset *asset = self.assetss[indexPath.row];
    CGImageRef thumbnailImageRef =
    [asset thumbnail];
    UIImage *thumbnail = [UIImage imageWithCGImage:thumbnailImageRef];
    UIImageView *recipeImageView = (UIImageView *)[cell viewWithTag:100];
    recipeImageView.image = thumbnail;
    cell.contentView.backgroundColor = [UIColor clearColor];
    if (indexPath.row == countIndexx)
    {
        photoImageVi.image =thumbnail;
    }
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    countIndexx = -1;
    int i=(int)indexPath.row;
    app.SelImgId=[NSString stringWithFormat:@"%i",i];
    [photosCollectionVi reloadItemsAtIndexPaths:[photosCollectionVi indexPathsForVisibleItems]];
    ALAsset *asset = self.assetss[indexPath.row];
    CGImageRef thumbnailImageRef = [asset thumbnail];
    UIImage *thumbnail = [UIImage imageWithCGImage:thumbnailImageRef];
    photoImageVi.image = thumbnail;
    app.imagepath=[NSString stringWithFormat:@"%@",asset];
    app.view=@"photo";
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor clearColor];
}
//stop


//******************************* Upload Image
-(IBAction)UploadBtnPressed:(id)sender
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    [imagePickerController setAllowsMultipleSelection:YES];
    [self presentViewController:imagePickerController animated:YES completion:nil];
}
//*****************************************************************************/
#pragma mark - UIImagePickerControllerHiddenAPIDelegate Methods
//*****************************************************************************/
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfoArray:(NSArray *)infoArray
{
    for (NSDictionary *infoDictionary in infoArray)
    {
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"Cancelled");
}
//***************************** stop
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
