//
//  FavoriteVC.m
//  Flippy Cloud
//
//  Created by iSquare5 on 13/08/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import "FavoriteVC.h"
#import "SidebarViewController.h"
#import "AlbumContentsViewController.h"
#import "AssetsDataIsInaccessibleViewController.h"
#import "AsyncImageView.h"
#import "ImageCollectionViewCell.h"
#import "ImageViewVC.h"
#import "BIZGrid4plus1CollectionViewLayout.h"
#import "Reachability.h"

@interface FavoriteVC ()
{
    NSArray *imageArr,*copyImageArr,*copyIdArr,*imagepath,*thumbArr;
    NSDictionary *image;
    UIActivityIndicatorView *indicator;
    NSMutableArray *FavImgLikedArr;
    UIRefreshControl *refreshControl;
    
}
@property (nonatomic, retain) SidebarViewController* sidebarVC;
@end

@implementation FavoriteVC

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    [self initPB];
      
    self.sidebarVC = [[SidebarViewController alloc] init];
    [self.sidebarVC setBgRGB:0x000000];
    self.sidebarVC.view.frame  = self.view.bounds;
    [self.view addSubview:self.sidebarVC.view];
    [self.sidebarVC showHideSidebar];
    screenBoundss = [[UIScreen mainScreen] bounds];
    [self viewWillAppear:YES];
    refreshControl = [[UIRefreshControl alloc]init];
    [photosCollectionVii addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
}
- (void)refreshTable
{
    
    NSLog(@"refreshing");
    [refreshControl endRefreshing];
    [photosCollectionVii reloadData];
}
-(void)viewWillAppear:(BOOL)animated
{
    [indicator startAnimating];
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(FavoriteAll) userInfo:nil repeats:NO];
}
-(void)FavoriteAll
{
    if([[Reachability sharedReachability] internetConnectionStatus] == NotReachable)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Check Internet Connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [indicator stopAnimating];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
        [av show];
    }
    else
    {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *email=[prefs valueForKey:@"email"];
        NSString *urlString = [[NSString alloc]initWithFormat:@"%@all_favorite.php",app.Service ];
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSString *myRequestString =[NSString stringWithFormat:@"{\"email\":\"%@\"}",email];
        NSData *requestData = [NSData dataWithBytes:[myRequestString UTF8String] length:[myRequestString length]];
        [request setHTTPMethod: @"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody: requestData];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (!data)
            {
                NSLog(@"%s: sendAynchronousRequest error: %@", __FUNCTION__, connectionError);
                return;
            }
            else if ([response isKindOfClass:[NSHTTPURLResponse class]])
            {
                NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
                if (statusCode != 200)
                {
                    NSLog(@"%s: sendAsynchronousRequest status code != 200: response = %@", __FUNCTION__, response);
                    return;
                }
            }
            NSError *parseError = nil;
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            
                       NSLog(@"all_favorite.php  ::::  %@",dictionary);
            
            
            if (!dictionary)
            {
                NSLog(@"%s: JSONObjectWithData error: %@; data = %@", __FUNCTION__, parseError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                return ;
            }
            else
            {
//                NSLog(@"%@",dictionary);

                if([[dictionary valueForKey:@"success"] isEqualToString:@"1"])
                {
                    [indicator stopAnimating];
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
                    introView.hidden=YES;
                    copyImageArr =[[dictionary valueForKey:@"posts"]valueForKey:@"picture_name"];
                    copyIdArr =[[dictionary valueForKey:@"posts"]valueForKey:@"Fav_id"];
                    thumbArr =[[dictionary valueForKey:@"posts"]valueForKey:@"thumbnail"];
                    FavImgLikedArr=[[dictionary valueForKey:@"posts"]valueForKey:@"like"];
                    app.FavAllBackArr = [[NSMutableArray alloc]init];
                    app.FavAllIdArr = [[NSMutableArray alloc]init];
                    app.FavAllThumbBackArr = [[NSMutableArray alloc]init];
                    app.FavAllBackLikedArr=[[NSMutableArray alloc]init];
                    app.FavAllBackLikedArr = [FavImgLikedArr mutableCopy];
                    app.FavAllBackArr = [copyImageArr mutableCopy];
                    app.FavAllIdArr = [copyIdArr mutableCopy];
                    app.FavAllThumbBackArr = [thumbArr mutableCopy];
                    [photosCollectionVii reloadData];
                }
                else
                {
                    [indicator stopAnimating];
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
                    photosCollectionVii.hidden=YES;
                    introView.hidden=NO;
                }
            }
        }];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//****************** UICollectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return copyImageArr.count;
}

- (ImageCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[ImageCollectionViewCell reuseIdentifier] forIndexPath:indexPath];
    UIImageView *recipeImageView = (UIImageView *)[cell viewWithTag:100];
    UILabel  *ProcessLabel = (UILabel *)[cell viewWithTag:200];
    UIImageView *BGProcessImg = (UIImageView *)[cell viewWithTag:201];
    BGProcessImg.image=[UIImage imageNamed:@"process-1.png"];
    ProcessLabel.hidden=YES;
    BGProcessImg.hidden=YES;
    NSString *imageStr=[thumbArr objectAtIndex:indexPath.row];
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:[NSURL URLWithString:imageStr]
                          options:0
                         progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                 float prog = (float)receivedSize/expectedSize;
                                 ProcessLabel.hidden=NO;
                                 BGProcessImg.hidden=NO;
                                 int process = (int)(100.0*prog);
                                 ProcessLabel.text=[NSString stringWithFormat:@"%d",process];
                         }
                        completed:^(UIImage *image1, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL){
                            if (image1) {
                                recipeImageView.image = image1;
                                ProcessLabel.hidden = YES;
                                BGProcessImg.hidden=YES;
                                ProcessLabel.text=[NSString stringWithFormat:@"0"];
                            }
                        }];
    NSString *imsage=[thumbArr objectAtIndex:indexPath.row];
    recipeImageView.imageURL =[NSURL URLWithString:imsage];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
   [photosCollectionVii reloadItemsAtIndexPaths:[photosCollectionVii indexPathsForVisibleItems]];
    self.photoImageVii.imageURL = [[app.json valueForKey:@"posts"]valueForKey:@"picture_name"];
    app.FavSelImageStr = [copyImageArr objectAtIndex:indexPath.row];
    app.setThumbFavStr = [thumbArr objectAtIndex:indexPath.row];
    app.favSelId = [copyIdArr objectAtIndex:indexPath.row];
    app.view = @"fav";
    [collectionView reloadData];
    app.FavIndexPathStr = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    [self performSegueWithIdentifier:@"ImageViewVC" sender:self];
}
//****************** stop

-(IBAction)show:(id)sender
{
   [self.sidebarVC showHideSidebar];
}
- (void)panDetected:(UIPanGestureRecognizer*)recoginzer
{
   [self.sidebarVC panDetected:recoginzer];
}
-(void) initPB
{
    indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width)/2, ([UIScreen mainScreen].bounds.size.height)/2 , 70.0, 70.0);
    indicator.layer.cornerRadius = 17;
    indicator.backgroundColor = [UIColor whiteColor];
    indicator.center = self.view.center;
    [self.view addSubview:indicator];
    [indicator bringSubviewToFront:self.view];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
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
