//
//  VideosVC.m
//  MiMedia
//
//  Created by iSquare5 on 10/08/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import "VideosVC.h"
#import "SidebarViewController.h"
#import "AlbumContentsViewController.h"
#import "AssetsDataIsInaccessibleViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ImageCollectionViewCell.h"
#import "BIZGrid4plus1CollectionViewLayout.h"
#import <Photos/Photos.h>

@interface VideosVC ()
{
    NSMutableArray *allVideosArr;
    NSMutableDictionary *dic;
}
@property (nonatomic, retain) SidebarViewController* sidebarVC;

@end

BOOL downViewss = NO;
BOOL tableClickedss = YES;
int countIndexss=0;

@implementation VideosVC
@synthesize assetsLibraryys,groupsss,assetsss,assetsGroupps;


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.sidebarVC = [[SidebarViewController alloc] init];
    [self.sidebarVC setBgRGB:0x000000];
    self.sidebarVC.view.frame  = self.view.bounds;
    [self.view addSubview:self.sidebarVC.view];
    [self.sidebarVC showHideSidebar];
    app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    screenBounds = [[UIScreen mainScreen] bounds];
    NSData * cpdata =[[NSUserDefaults standardUserDefaults]valueForKey:@"cameraImageKey"];
    photoImageVis.image = [UIImage imageWithData:cpdata];
    downViewss = NO;
    countIndexss=0;
    photoViewss.frame=CGRectMake(0, 0, screenBounds.size.width, screenBounds.size.height-100);
    acViews.frame=CGRectMake(-screenBounds.size.width, photoViewss.frame.size.height, screenBounds.size.width, screenBounds.size.height-photoViewss.frame.size.height);
    bcViews.frame=CGRectMake(0, 60, screenBounds.size.width, screenBounds.size.height-photoViewss.frame.size.height);
    if (assetsLibraryys == nil)
    {
        assetsLibraryys = [[ALAssetsLibrary alloc] init];
    }
    if (groupsss == nil)
    {
        groupsss = [[NSMutableArray alloc] init];
    }
    else
    {
        [groupsss removeAllObjects];
    }
    
    // setup our failure view controller in case enumerateGroupsWithTypes fails
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
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
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        ALAssetsFilter *onlyPhotosFilter2 = [ALAssetsFilter allVideos];
        [group setAssetsFilter:onlyPhotosFilter2];
        if ([group numberOfAssets] > 0)
        {
            [groupsss insertObject:group atIndex:0];
            tableClickedss = YES;
            if (groupsss.count > 0)
            {
                self.assetsGroupps = groupsss[0];
                if (!assetsss)
                {
                    assetsss = [[NSMutableArray alloc] init];
                }
                else
                {
                    [assetsss removeAllObjects];
                }
                ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop)
                {
                    if (result)
                    {
                        [assetsss insertObject:result atIndex:0];
                    }
                };
                ALAssetsFilter *onlyPhotosFilter2 = [ALAssetsFilter allVideos];
                [assetsGroupps setAssetsFilter:onlyPhotosFilter2];
                [assetsGroupps enumerateAssetsUsingBlock:assetsEnumerationBlock];
                [photosCollectionVis reloadData];
            }
        }
        else
        {
            [albumTableVis performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
    };
    NSUInteger groupTypes = ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces | ALAssetsGroupSavedPhotos ;
    [self.assetsLibraryys enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock failureBlock:failureBlock];
}
//UICollectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return assetsss.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader)
    {
        RecipeCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        headerView.title.text = [self.assetsGroupps valueForProperty:ALAssetsGroupPropertyName];
        [headerView.backToAlbumBtn addTarget:self action:@selector(backToAlbumBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        reusableview = headerView;
    }
    return reusableview;
}
-(void)backToAlbumBtnTapped:(id)sender
{
    tableClickedss = NO;
    if (downViewss == NO)
    {
        [UIView animateWithDuration:0.3
                         animations:^{
                             acViews.frame=CGRectMake(0, photoViewss.frame.size.height, screenBounds.size.width, screenBounds.size.height-photoViewss.frame.size.height);
                             bcViews.frame=CGRectMake(screenBounds.size.width,60, screenBounds.size.width, screenBounds.size.height-photoViewss.frame.size.height);
                         }
                         completion:^(BOOL finished){;}];
    }
    else
    {
        [UIView animateWithDuration:0.3
                         animations:^{
                             acViews.frame=CGRectMake(0, photoViewss.frame.size.height-180, screenBounds.size.width, screenBounds.size.height-photoViewss.frame.size.height+180);
                             bcViews.frame=CGRectMake(screenBounds.size.width,60, screenBounds.size.width, screenBounds.size.height-photoViewss.frame.size.height+180);
                         }
                         completion:^(BOOL finished){;}];
    }
}
- (ImageCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[ImageCollectionViewCell reuseIdentifier] forIndexPath:indexPath];
    ALAsset *asset = self.assetsss[indexPath.row];
    CGImageRef thumbnailImageRef = [asset thumbnail];
    UIImage *thumbnail = [UIImage imageWithCGImage:thumbnailImageRef];
    UIImageView *recipeImageView = (UIImageView *)[cell viewWithTag:100];
    recipeImageView.image = thumbnail;
    cell.contentView.backgroundColor = [UIColor clearColor];
    if (indexPath.row == countIndexss)
    {
        photoImageVis.image =thumbnail;
    }
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    countIndexss = -1;
    [photosCollectionVis reloadItemsAtIndexPaths:[photosCollectionVis indexPathsForVisibleItems]];
    ALAsset *asset = self.assetsss[indexPath.row];
    CGImageRef thumbnailImageRef = [asset thumbnail];
    UIImage *thumbnail = [UIImage imageWithCGImage:thumbnailImageRef];
    photoImageVis.image = thumbnail;
    app.imagepath=[NSString stringWithFormat:@"%@",asset];
    app.view=@"home";
    NSString *videoURL =[NSString stringWithFormat:@"%@",asset.defaultRepresentation.url];
    NSURL *videos=[NSURL URLWithString:videoURL];
    self.moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:videos];
    [self.moviePlayerController.view setFrame:CGRectMake(0,100,375,250)];
    [video setFrame:CGRectMake(0, 100, 375, 250)];
    self.moviePlayerController.backgroundView.backgroundColor  = [UIColor lightGrayColor] ;
    [video addSubview:self.moviePlayerController.view];
    self.moviePlayerController.fullscreen = YES;
    [self.moviePlayerController play];
    [self viewDidAppear:YES];
}
-(void)viewDidAppear:(BOOL)animated
{
    [self.moviePlayerController stop];
}
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
