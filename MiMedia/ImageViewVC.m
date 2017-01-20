//
//  ImageViewVC.m
//  Flippy Cloud
//
//  Created by iSquare5 on 11/08/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import "ImageViewVC.h"
#import "HomeVC.h"
#import "PhotosVC.h"
#import "base64.h"
#import "FavoriteVC.h"
#import "BackupRestoreVc.h"
#import "ManuallyPhotosVC.h"
#import "AsyncImageView.h"
#import "Reachability.h"
#import "CollectionSubVC.h"

#define MINIMUM_SCALE 0.5
#define MAXIMUM_SCALE 6.0

@interface ImageViewVC ()<UIGestureRecognizerDelegate,UIScrollViewDelegate>
{
    NSString *favSel,*SelCollNameStr,*favStatus;
    NSMutableArray *imageArr,*DriveStatusArr;
    NSDictionary *json;
    UIImage *thumbnail;
    NSArray *CollNameCopy,*DriveNameCopy;
    NSString *strEncoded;
    UIActivityIndicatorView *indicator;
    int likedId;
    NSString *Drive;
    UIPinchGestureRecognizer *twoFingerPinch;
}
@property CGPoint translation;
@end

@implementation ImageViewVC
@synthesize likebuttonImageV;
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    [self initPB];

    //////********* zoom in/out image by pinch gesture
    self.scrollView.maximumZoomScale = 4.0;
    self.scrollView.minimumZoomScale = 0.6;
   
    self.scrollView.clipsToBounds = YES;
    self. scrollView.delegate = self;
    [self.scrollView addSubview:self.foreImageView];
    ///////////******************////////////
    if ([app.view isEqualToString:@"liked"])
    {
        NSString *name = app.ManuallySelImageStr;
        NSArray *items = [name componentsSeparatedByString:@"/"];
        NSString *ImageName = [items lastObject];
        self.picNameTxt.text=[NSString stringWithFormat:@"%@",ImageName];
        likebuttonImageV.image = [UIImage imageNamed:@"Fav_Sel143.png"];
        [self.favBtn setSelected:YES];
        app.CheckLikePageString = @"1";
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(ImageLoadFromServer) userInfo:nil repeats:NO];
    }
    //****************when come back from the favorite page it will execute
    else if([app.view isEqualToString:@"fav"])
    {
        favStatus = @"selected";
        likebuttonImageV.image = [UIImage imageNamed:@"Fav_Sel143.png"];
        [self.popAddFavBtn setSelected:YES];
        self.removeFavL.text=@"Remove from Favorite";
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(ImageLoadFromServerFav) userInfo:nil repeats:NO];
    }
    else if ([app.view isEqualToString:@"CollSub"])
    {
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(ImageLoadFromServerCollection) userInfo:nil repeats:NO];
    }
    else if ([app.view isEqualToString:@"DriveSub"])
    {
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(ImageLoadFromServerCollection) userInfo:nil repeats:NO];
    }
    else
    {
        NSString *name = app.ManuallySelImageStr;
        NSArray *items = [name componentsSeparatedByString:@"/"];
        NSString *ImageName = [items lastObject];
        self.picNameTxt.text=[NSString stringWithFormat:@"%@",ImageName];
        likebuttonImageV.image = [UIImage imageNamed:@"Fav_unSel143.png"];
        app.CheckLikePageString = @"0";
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(ImageLoadFromServer) userInfo:nil repeats:NO];
    }
    [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(CollCount) userInfo:nil repeats:NO];

}
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.foreImageView;
}
-(void)ImageLoadFromServer
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",app.ManuallySelImageStr]]
                          options:0
                         progress:^(NSInteger receivedSize, NSInteger expectedSize)
                         {
                             self.BGImageView.imageURL = [NSURL URLWithString:app.ManuallySelImageStr];
                         }
                        completed:^(UIImage *image1, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL)
                            {
                                if (image1)
                                {
                                    self.BGImageView.imageURL = [NSURL URLWithString:app.ManuallySelImageStr];
                                    if (!UIAccessibilityIsReduceTransparencyEnabled())
                                    {
                                        self.view.backgroundColor = [UIColor clearColor];
                                        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
                                        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
                                        blurEffectView.frame = self.view.bounds;
                                        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                                        [self.BGImageView addSubview:blurEffectView];
                                    }
                                    else
                                    {
                                        self.view.backgroundColor = [UIColor clearColor];
                                    }
                                }
                            }];
    [manager downloadImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",app.ManuallySelImageStr]]
                          options:0
                         progress:^(NSInteger receivedSize, NSInteger expectedSize)
                            {
                                self.foreImageView.imageURL = [NSURL URLWithString:app.SetThumbImageV];
                            }
                        completed:^(UIImage *image1, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL)
                            {
                                if (image1)
                                {
                                    self.foreImageView.image = image1;
                                }
                            }];
}
/****************when coming back from favorite page**************************/
-(void)ImageLoadFromServerFav
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",app.FavSelImageStr]]
     options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize)
     {
         self.BGImageView.imageURL = [NSURL URLWithString:app.FavSelImageStr];
     }
                        completed:^(UIImage *image1, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                            if (image1)
                            {
                                self.BGImageView.imageURL = [NSURL URLWithString:app.FavSelImageStr];
                                if (!UIAccessibilityIsReduceTransparencyEnabled())
                                {
                                    self.view.backgroundColor = [UIColor clearColor];
                                    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
                                    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
                                    blurEffectView.frame = self.view.bounds;
                                    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                                    [self.BGImageView addSubview:blurEffectView];
                                }
                                else
                                {
                                   self.view.backgroundColor = [UIColor clearColor];
                                }
                            }
                        }];
    [manager downloadImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",app.FavSelImageStr]]
                          options:0
                         progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                             self.foreImageView.imageURL = [NSURL URLWithString:app.setThumbFavStr];
                         }
                        completed:^(UIImage *image1, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                            if (image1)
                            {
                                self.foreImageView.image = image1;
                            }
                        }];
}
/************** when coming back from favorite page *************************/
-(void)ImageLoadFromServerCollection
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",app.CollImgURL]]
                          options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize)
     {
         self.BGImageView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",                                                         app.CollImgURL]];
         
     }
                        completed:^(UIImage *image1, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                            if (image1)
                            {
                                self.BGImageView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",app.CollImgURL]];
                                if (!UIAccessibilityIsReduceTransparencyEnabled())
                                {
                                    self.view.backgroundColor = [UIColor clearColor];
                                    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
                                    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
                                    blurEffectView.frame = self.view.bounds;
                                    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                                    [self.BGImageView addSubview:blurEffectView];
                                    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
                                }
                                else
                                {
                                  self.view.backgroundColor = [UIColor clearColor];
                                }
                            }
                        }];
    [manager downloadImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",app.CollImgURL]]
                          options:0
                         progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                             self.foreImageView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",app.CollImgURL]];
                             }
                        completed:^(UIImage *image1, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                            if (image1)
                            {
                                self.foreImageView.image = image1;
                            }
                        }];
}
-(IBAction)backBtnPressed:(id)sender
{
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(backtohome) userInfo:nil repeats:NO];
}
-(void)backtohome
{
     if ([app.view isEqualToString:@"fav"])
    {
        app.view=@"imageVC";
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
         [self.navigationController popViewControllerAnimated:YES];
    }
/*    else
//    {
//        UINavigationController *navigationController = (UINavigationController *)app.window.rootViewController;
//        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
//        BackupRestoreVc *MainPage = (BackupRestoreVc*)[mainStoryboard instantiateViewControllerWithIdentifier: @"BackupRestoreVc"];
//        [navigationController pushViewController:MainPage animated:YES];
//        
//    }*/
}
-(IBAction)favoriteBtnPressed:(id)sender
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
        if([app.view isEqualToString:@"fav"])
        {
            if([favStatus isEqualToString:@"selected"])
            {
                likebuttonImageV.image = [UIImage imageNamed:@"Fav_unSel143.png"];
                app.CheckLikePageString = @"0";
                [self.favBtn setSelected:NO];
                [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(removeFav) userInfo:nil repeats:NO];
                app.selImage=[[json valueForKey:@"posts"]valueForKey:@"Image_path"];
            }
            else
            {
                likebuttonImageV.image = [UIImage imageNamed:@"Fav_Sel143.png"];
                app.view = @"liked";
                [self.favBtn setSelected:YES];
                app.CheckLikePageString = @"1";
                [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(addFav) userInfo:nil repeats:NO];
            }
        }
        else
        {
            if ([app.view isEqualToString:@"liked"])
            {
                likebuttonImageV.image = [UIImage imageNamed:@"Fav_unSel143.png"];
                app.view = @"";
                app.CheckLikePageString = @"0";
                [self.favBtn setSelected:NO];
                [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(removeFav) userInfo:nil repeats:NO];
                app.selImage=[[json valueForKey:@"posts"]valueForKey:@"Image_path"];
            }
            else
            {
                likebuttonImageV.image = [UIImage imageNamed:@"Fav_Sel143.png"];
                app.view = @"liked";
                [self.favBtn setSelected:YES];
                app.CheckLikePageString = @"1";
                [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(addFav) userInfo:nil repeats:NO];
            }
        }
    }
}
-(void)addFav
{
     dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
    {
            dispatch_async(dispatch_get_main_queue(), ^(void)
            {
                [self.favBtn setSelected:YES];
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                NSString *email=[prefs valueForKey:@"email"];
                NSString *urlString = [[NSString alloc]initWithFormat:@"%@favorite.php",app.Service];
                NSURL *url = [NSURL URLWithString:urlString];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
                NSString *myRequestString =[NSString stringWithFormat:@"{\"file_name\":\"%@\",\"fav_id\":\"%@\",\"email\":\"%@\"}",app.ManuallySelImageStr,app.SelImgId,email];
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
                    
                    NSLog(@"favorite.php  ::::  %@",dictionary);
                    
                    
                    if (!dictionary)
                    {
                        NSLog(@"%s: JSONObjectWithData error: %@; data = %@", __FUNCTION__, parseError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                        return ;
                    }
                    else
                    {
                       json=dictionary;
                       app.jsonArr=[[json valueForKey:@"posts"]valueForKey:@"Image_path"];
                    }
                }];
            });
     });
}
-(void)removeFav
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
               if([app.view isEqualToString:@"fav"])
                {
                     app.SelImgId=app.favSelId;
                }
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                NSString *email=[prefs valueForKey:@"email"];
                NSString *urlString = [[NSString alloc]initWithFormat:@"%@fav_delete.php",app.Service ];
                NSURL *url = [NSURL URLWithString:urlString];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
                NSString *myRequestString =[NSString stringWithFormat:@"{\"fav_id\":\"%@\",\"email\":\"%@\"}",app.SelImgId,email];
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
               
                NSLog(@"fav_delete.php  ::::  %@",dictionary);
                    
                if (!dictionary)
                {
                    NSLog(@"%s: JSONObjectWithData error: %@; data = %@", __FUNCTION__, parseError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                    return ;
                }
                else
                {
                   NSLog(@"remove from favorite");
                }
            }];
        });
    });
}
-(IBAction)infoBtnPressed:(id)sender
{
    [self InfoViewShow];
}
-(void)InfoViewShow
{
    self.infoBtn.hidden=YES;
    self.backBtn.hidden=YES;
    self.favBtn.hidden=YES;
    self.ShareBtn.hidden=YES;
    self.menuBtn.hidden=YES;
    self.infoView.hidden=NO;
}
-(IBAction)infoCancelBtnPressed:(id)sender
{
    self.infoView.hidden=YES;
    self.backBtn.hidden=NO;
    self.infoBtn.hidden=NO;
    self.favBtn.hidden=NO;
    self.ShareBtn.hidden=NO;
    self.menuBtn.hidden=NO;
}
-(IBAction)editBtnPressed:(id)sender
{
    self.picNameTxt.enabled=YES;
    self.picNameTxt.tintColor=[UIColor colorWithRed:64/255.0f green:206/255.0f blue:160/255.0f alpha:1];
}
-(IBAction)shareBtnpressed:(id)sender
{
    if([[Reachability sharedReachability] internetConnectionStatus] == NotReachable)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Check Internet Connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
    else
    {
        NSData *data= [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",app.ManuallySelImageStr]]];
        UIImage *imageToShare = [UIImage imageWithData:data];
        NSArray *objectsToShare = @[imageToShare];
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
        NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                       UIActivityTypePrint,
                                       UIActivityTypeAssignToContact,
                                       UIActivityTypeSaveToCameraRoll,
                                       UIActivityTypeAddToReadingList,
                                       UIActivityTypePostToFlickr,
                                       UIActivityTypePostToVimeo];
        activityVC.excludedActivityTypes = excludeActivities;
        [self presentViewController:activityVC animated:YES completion:nil];
    }
}
-(IBAction)menuBtnPressed:(id)sender
{
    self.view1.hidden=NO;
    self.view2.hidden=NO;
    self.view3.hidden=NO;
    self.view5.hidden=NO;
    self.view6.hidden=NO;

    if([ app.DriveSelectedImageStatusStr isEqualToString:@"1"])
    {
        app.DriveSelectedImageStatusStr=@"";
        self.view4.hidden=YES;
    }
    else
    {
            self.view4.hidden=NO;
    }
    
    if([self.menuBtn isSelected])
    {
        if([ app.DriveSelectedImageStatusStr isEqualToString:@"1"])
        {
            app.DriveSelectedImageStatusStr=@"";
            self.view4.hidden=YES;
        }
        else
        {
            self.view4.hidden=NO;
        }
        [self animationhide];
        [sender setSelected:NO];
    }
    else
    {
        [self animationView];
        [sender setSelected:YES];
    }
}
-(void)animationView
{
    [UIView animateWithDuration:1.5
                     animations:^{
                         self.view1.frame =CGRectMake(self.menuBtn.frame.origin.x - 40,55,60,60);
                         self.view2.frame =CGRectMake(self.view1.frame.origin.x- 65,self.view1.frame.origin.y,self.view1.frame.size.width,self.view1.frame.size.height);
                         self.view3.frame=CGRectMake(self.view2.frame.origin.x-65,self.view1.frame.origin.y, self.view1.frame.size.width,self.view1.frame.size.height);
                         self.view4.frame=CGRectMake(self.view1.frame.origin.x,self.view1.frame.origin.y + 65, self.view1.frame.size.width,self.view1.frame.size.height);
                         self.view5.frame=CGRectMake(self.view4.frame.origin.x- 65,self.view1.frame.origin.y + 65,self.view1.frame.size.width,self.view1.frame.size.height);
                         self.view6.frame=CGRectMake(self.view5.frame.origin.x- 65,self.view1.frame.origin.y + 65,self.view1.frame.size.width,self.view1.frame.size.height);
                         self.view1.alpha=1;
                         self.view2.alpha=1;
                         self.view3.alpha=1;
                         self.view4.alpha=1;
                         self.view5.alpha=1;
                         self.view6.alpha=1;
                     }];
}
-(void)animationhide
{
    [UIView animateWithDuration:1.5
                     animations:^{
                         self.view1.frame =CGRectMake(self.menuBtn.frame.origin.x - 40,55,60,60);
                         self.view2.frame =self.view1.frame;
                         self.view3.frame=self.view1.frame;
                         self.view4.frame=self.view1.frame;
                         self.view5.frame=self.view1.frame;
                         self.view6.frame=self.view1.frame;
                         self.view1.alpha=0.0;
                         self.view2.alpha=0.0;
                         self.view3.alpha=0.0;
                         self.view4.alpha=0.0;
                         self.view5.alpha=0.0;
                         self.view6.alpha=0.0;
                     }];
}
-(IBAction)popShareBtnPressed:(id)sender
{
    if([self.popShareBtn isSelected])
    {
        [sender setSelected:NO];
    }
    else
    {
        [self animationhide];
        NSData *data= [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",app.ManuallySelImageStr]]];
        UIImage *imageToShare = [UIImage imageWithData:data];
        NSArray *objectsToShare = @[imageToShare];
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
        NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                       UIActivityTypePrint,
                                       UIActivityTypeAssignToContact,
                                       UIActivityTypeSaveToCameraRoll,
                                       UIActivityTypeAddToReadingList,
                                       UIActivityTypePostToFlickr,
                                       UIActivityTypePostToVimeo];
        activityVC.excludedActivityTypes = excludeActivities;
        [self presentViewController:activityVC animated:YES completion:nil];
        [sender setSelected:YES];
    }
}
-(IBAction)popAddDriveBtnPressed:(id)sender
{
    [indicator startAnimating];
    [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(DriveCount) userInfo:nil repeats:NO];
    if([self.popAddDriveBtn isSelected])
    {
        [self animationhide];
        [sender setSelected:NO];
    }
    else
    {
        [self animationhide];
        self.ColleCtionColl.tag=1;
        self.DriveColl.hidden=NO;
        self.ColleCtionColl.hidden=YES;
        self.CollectionSView.hidden=NO;
        Drive=@"yes";
        [sender setSelected:YES];
    }
}

-(IBAction)popAddCollectionBtnPressed:(id)sender
{
    if([self.popAddCollectionBtn isSelected])
    {
        [self animationhide];
        [sender setSelected:NO];
    }
    else
    {
        [self animationhide];
        self.ColleCtionColl.tag=2;
        self.DriveColl.hidden=YES;
        self.ColleCtionColl.hidden=NO;
        self.CollectionSView.hidden=NO;
        [sender setSelected:YES];
    }
}
-(void)CollCount
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
        NSString *urlString = [[NSString alloc]initWithFormat:@"%@all_collection.php",app.Service ];
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
            
                            NSLog(@"all_collection.php  ::::  %@",dictionary);
            
            if (!dictionary)
            {
                NSLog(@"%s: JSONObjectWithData error: %@; data = %@", __FUNCTION__, parseError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                return ;
            }
            else
            {
                NSString *success=[dictionary valueForKey:@"success"];
                if([success isEqualToString:@"1"])
                {
                    CollNameCopy = [[dictionary valueForKey:@"posts"]valueForKey:@"Collection Name"];
                    [self.ColleCtionColl reloadData];
                    Drive=@"";
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
                }
                else
                {
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
                }
            }
        }];
    }
}
-(void)DriveCount
{
    if([[Reachability sharedReachability] internetConnectionStatus] == NotReachable){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Check Internet Connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [indicator stopAnimating];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
        [av show];
    }
    else
    {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *email=[prefs valueForKey:@"email"];
        NSString *urlString = [[NSString alloc]initWithFormat:@"%@all_drive.php",app.Service ];
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSString *myRequestString =[NSString stringWithFormat:@"{\"email\":\"%@\"}",email];
        NSData *requestData = [NSData dataWithBytes:[myRequestString UTF8String] length:[myRequestString length]];
        [request setHTTPMethod: @"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody: requestData];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
         {
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
             
             NSLog(@"all_drive.php  ::::  %@",dictionary);
             
             
             if (!dictionary)
             {
                 NSLog(@"%s: JSONObjectWithData error: %@; data = %@", __FUNCTION__, parseError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                 return ;
             }
             else
             {
                 DriveNameCopy =[[dictionary valueForKey:@"posts"]valueForKey:@"drive_name"];
                 DriveStatusArr=[[dictionary valueForKey:@"posts"]valueForKey:@"drive_status"];
                 [self.DriveColl reloadData];
                 Drive=@"yes";
                 
                 [indicator stopAnimating];
                 [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
            }
         }];
    }
}
-(void)DeleteCollectionImage
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
      
        dispatch_async(dispatch_get_main_queue(), ^(void){
          if([[Reachability sharedReachability] internetConnectionStatus] == NotReachable)
          {
              UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Check Internet Connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
              [av show];
          }
          else
          {
              NSString *name =[NSString stringWithFormat:@"%@",app.CollImgURL];
              NSArray *items = [name componentsSeparatedByString:@"/"];
              NSString *ImageName = [items lastObject];
              NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
              NSString *contact=[prefs valueForKey:@"contact"];
              NSString *urlString = [[NSString alloc]initWithFormat:@"%@delete_images.php",app.Service ];
              NSURL *url = [NSURL URLWithString:urlString];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
              NSString *myRequestString =[NSString stringWithFormat:@"{\"contact\":\"%@\",\"image_name\":\"%@\"}",contact,ImageName];
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
                  
                  
                    NSLog(@"DeleteCollectionImage  ::::  %@",dictionary);
                  
                      if (!dictionary)
                      {
                          NSLog(@"%s: JSONObjectWithData error: %@; data = %@", __FUNCTION__, parseError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                          return ;
                      }
                      else
                      {
                          NSLog(@"delete image response:%@",dictionary);
                          
                            
                              [self.navigationController popViewControllerAnimated:YES];
                         
                      }
              }];
              
            }
        });
    });
}

-(IBAction)popDeleteBtnPressed:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"Are you sure you want to Delete this item? It will be removed from the cloud and from all Collections and FlippyDrives" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                         {
                             [self DeleteFun];
                         }];
    UIAlertAction* cancle = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action)
                             {
                                 [self animationhide];
                             }];
    [alertController addAction:ok];
    [alertController addAction:cancle];
    [self presentViewController:alertController animated:YES completion:nil];
}
-(void)DeleteFun
{
    [indicator startAnimating];
    if([app.view isEqualToString:@"fav"])
    {
        app.view=@"liked";
        app.LikedStatusForDelete=@"";
    }
    if([app.view isEqualToString:@"CollSub"])
    {
        app.CollectionNameArrCopy = NULL;
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(DeleteCollectionImage) userInfo:nil repeats:NO];
    }
    if ([app.view isEqualToString:@"DriveSub"])
    {
                app.DriveArrNameCopy = NULL;
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(DeleteCollectionImage) userInfo:nil repeats:NO];
    }
    NSInteger index=[app.indexStr intValue];
    [app.imagesAllBackArr removeObjectAtIndex:index];
    [app.thumAllBackArr removeObjectAtIndex:index];
    [app.LikeStatusAllArr removeObjectAtIndex:index];
    [app.favoriteAllArr removeObjectAtIndex:index];
    app.CheckLikePageString = @"no";
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(DeleteImage) userInfo:nil repeats:NO];
    [self animationhide];
}
-(void)DeleteImage
{
    [indicator startAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
            if([[Reachability sharedReachability] internetConnectionStatus] == NotReachable)
            {
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Check Internet Connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [av show];
            }
            else
            {
                if([app.LikedStatusForDelete isEqualToString:@"(null)"] )
                {
//                      NSLog(@"asd");
                }
                else
                {
                    if([app.LikedStatusForDelete isEqualToString:@""])
                    {
//                      NSLog(@"ascc");
                        likedId=[app.favSelId intValue];
                    }
                    else
                    {
                        likedId=[app.LikedStatusForDelete intValue];
                    }
                }
                NSString *name = app.ManuallySelImageStr;
                if(name == nil)
                {
                    name=app.FavSelImageStr;
                }
                NSArray *items = [name componentsSeparatedByString:@"/"];
                NSString *ImageName = [items lastObject];
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                NSString *email=[prefs valueForKey:@"email"];
                NSString *contact=[prefs valueForKey:@"contact"];
                NSString *urlString = [[NSString alloc]initWithFormat:@"%@delete_images.php",app.Service ];
                NSURL *url = [NSURL URLWithString:urlString];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
                if([app.view isEqualToString:@"liked"])
                {
                    NSString *myRequestString =[NSString stringWithFormat:@"{\"email\":\"%@\",\"fav_id\":\"%i\",\"contact\":\"%@\",\"image_name\":\"%@\"}",email,likedId,contact,ImageName];
                    NSData *requestData = [NSData dataWithBytes:[myRequestString UTF8String] length:[myRequestString length]];
                    [request setHTTPMethod: @"POST"];
                    [request setTimeoutInterval:300];
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
                        
                        
                         NSLog(@"delete_images.php liked  ::::  %@",dictionary);
                        
                        
                        if (!dictionary)
                        {
                            NSLog(@"%s: JSONObjectWithData error: %@; data = %@", __FUNCTION__, parseError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                            return ;
                        }
                        else
                        {
                            [indicator stopAnimating];
                            [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
                            [self.navigationController popViewControllerAnimated:YES];
                        }
                    }];
                 }
                else
                {
                    NSString *myRequestString =[NSString stringWithFormat:@"{\"contact\":\"%@\",\"image_name\":\"%@\"}",contact,ImageName];
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
                        
                        NSLog(@"delete_images.php   ::::  %@",dictionary);
                        
                        
                        if (!dictionary)
                        {
                            NSLog(@"%s: JSONObjectWithData error: %@; data = %@", __FUNCTION__, parseError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                            return ;
                        }
                        else
                        {
                            [indicator stopAnimating];
                            [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
                             [self.navigationController popViewControllerAnimated:YES];
                        }
                    }];
                }
            }
        });
    });
}

-(IBAction)popAddFavBtnPressed:(id)sender
{
    if([[Reachability sharedReachability] internetConnectionStatus] == NotReachable)
    {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Check Internet Connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
    }
    else
    {
            if ([app.view isEqualToString:@"liked"])
            {
                likebuttonImageV.image = [UIImage imageNamed:@"Fav_unSel143.png"];
                app.CheckLikePageString = @"0";
                app.view = @"";
                [self.favBtn setSelected:NO];
                [self removeFav];
                self.removeFavL.text=@"Mark as Favorite";
                app.selImage=[[json valueForKey:@"posts"]valueForKey:@"Image_path"];
            }
            else
            {
                likebuttonImageV.image = [UIImage imageNamed:@"Fav_Sel143.png"];
                app.CheckLikePageString = @"1";
                self.removeFavL.text=@"Remove from Favorite";
                app.view = @"liked";
                [self.favBtn setSelected:YES];
                [self addFav];
            }
            [self animationhide];
    }
}
-(IBAction)popInfoBtnPressed:(id)sender
{
     [self InfoViewShow];
     [self animationhide];
}

//----CollectionView Start
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.ColleCtionColl.tag==1)
    {
          return DriveNameCopy.count;
    }
    else
    {
          return CollNameCopy.count;
    }
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (self.ColleCtionColl.tag==1)
    {
        return UIEdgeInsetsMake(5,5,5,5);
    }
    else
    {
        return UIEdgeInsetsMake(5,5,5,5);
    }
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier=@"Cell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if (self.ColleCtionColl.tag==1)
    {
        UILabel *DriveName = (UILabel *)[cell viewWithTag:1];
        DriveName.text=[NSString stringWithFormat:@"%@",[DriveNameCopy objectAtIndex:indexPath.row]];
    }
    else
    {
        UILabel *CollectionName = (UILabel *)[cell viewWithTag:1];
        CollectionName.text=[NSString stringWithFormat:@"%@",[CollNameCopy objectAtIndex:indexPath.row]];
    }
    cell.layer.borderWidth=1.0f;
    cell.layer.borderColor=[UIColor blackColor].CGColor;
    return cell;
}
-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.ColleCtionColl.tag==1)
    {
        app.DriveStatusStr=[DriveStatusArr objectAtIndex:indexPath.row];
        if([app.DriveStatusStr isEqualToString:@"Shared"])
        {
            app.DriveStatusStr=[NSString stringWithFormat:@"1"];
            SelCollNameStr=[DriveNameCopy objectAtIndex:indexPath.row];
        }
        else
        {
            SelCollNameStr=[DriveNameCopy objectAtIndex:indexPath.row];
        }
    }
    else
    {
        SelCollNameStr=[CollNameCopy objectAtIndex:indexPath.row];
    }
    
    UICollectionViewCell* cell=[collectionView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor grayColor];
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor clearColor];
}
//---Stop


//----------  add To the selected collection  ----------//
-(IBAction)DoneBtnPressed:(id)sender
{
    [indicator startAnimating];
    if([Drive isEqualToString:@"yes"])
    {
        [self addToDrive];
    }
    else
    {
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(addCollection) userInfo:nil repeats:NO];
    }
}
-(IBAction)CancelBtnPressed:(id)sender
{
    self.CollectionSView.hidden=YES;
    [indicator stopAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
}
-(void)addToDrive
{
    if([[Reachability sharedReachability] internetConnectionStatus] == NotReachable)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Check Internet Connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
    else
    {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *email=[prefs valueForKey:@"email"];
        NSString *phone=[prefs valueForKey:@"contact"];
        NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",app.ManuallySelImageStr]];
        
        //getting only name of image without extension
        NSString *name=[NSString stringWithFormat:@"%@",app.ManuallySelImageStr];
        NSArray *items = [name componentsSeparatedByString:@"/"];
        NSString *ImageName = [items lastObject];//ImageName
        NSString* fileName = [[ImageName lastPathComponent] stringByDeletingPathExtension];
        //-------------
        
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        UIImage *image = [UIImage imageWithData:imageData];
        NSData *imageData1 = UIImagePNGRepresentation(image);
        [Base64 initialize];
        NSString *imageStringBase64 = [NSString stringWithFormat:@"%@",[Base64 encode:imageData1]];
        NSString *urlString = [[NSString alloc]initWithFormat:@"%@add_drive_img.php",app.Service];
        NSURL *url = [NSURL URLWithString:urlString];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
        
        NSString *myRequestString;
        if([app.DriveStatusStr isEqualToString:@"1"])
        {
            app.DriveStatusStr=@"";
           
            myRequestString =[NSString stringWithFormat:@"{\"drive_name\":\"%@\",\"image_name\":\"%@\",\"email\":\"%@\",\"drive_status\":\"Shared\",\"img_file_name\":\"%@\"}",SelCollNameStr,imageStringBase64,email,fileName];
        }
        else
        {
           myRequestString =[NSString stringWithFormat:@"{\"drive_name\":\"%@\",\"image_name\":\"%@\",\"email\":\"%@\",\"contact\":\"%@\",\"img_file_name\":\"%@\"}",SelCollNameStr,imageStringBase64,email,phone,fileName];
        }
        
        
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
            
            
               NSLog(@"add_drive_img.php   ::::  %@",dictionary);
            
            if (!dictionary)
            {
                NSLog(@"%s: JSONObjectWithData error: %@; data = %@", __FUNCTION__, parseError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                return ;
            }
            else
            {
                app.DriveArrNameCopy =NULL;
                app.CollJson=dictionary;
                self.CollectionSView.hidden=YES;
                [indicator stopAnimating];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
            }
        }];
    }
}
-(void)addCollection
{
    if([[Reachability sharedReachability] internetConnectionStatus] == NotReachable)
    {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Check Internet Connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
    }
    else
    {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *email=[prefs valueForKey:@"email"];
        NSString *phone=[prefs valueForKey:@"contact"];
        NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",app.ManuallySelImageStr]];
        //getting only name of image without extension
        NSString *name=[NSString stringWithFormat:@"%@",app.ManuallySelImageStr];
        NSArray *items = [name componentsSeparatedByString:@"/"];
        NSString *ImageName = [items lastObject];//ImageNamed
        NSString* fileName = [[ImageName lastPathComponent] stringByDeletingPathExtension];//remove extension
        //--------------
        
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        UIImage *image = [UIImage imageWithData:imageData];
        NSData *imageData1 = UIImagePNGRepresentation(image);
        [Base64 initialize];
        NSString *imageStringBase64 = [NSString stringWithFormat:@"%@",[Base64 encode:imageData1]];
        NSString *urlString = [[NSString alloc]initWithFormat:@"%@add_collection_img.php",app.Service];
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSString *myRequestString =[NSString stringWithFormat:@"{\"collection_name\":\"%@\",\"image_name\":\"%@\",\"email\":\"%@\",\"contact\":\"%@\",\"img_file_name\":\"%@\"}",SelCollNameStr,imageStringBase64,email,phone,fileName];
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
                
         NSLog(@"add_collection_img.php   ::::  %@",dictionary);
                
                
                if (!dictionary)
                {
                    NSLog(@"%s: JSONObjectWithData error: %@; data = %@", __FUNCTION__, parseError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                    return ;
                }
                else
                {
                    app.CollectionNameArrCopy=NULL;
                    app.CollJson=dictionary;
                    self.CollectionSView.hidden=YES;
                    [indicator stopAnimating];
                        [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
//                    NSLog(@"image of collection :  %@",app.CollJson);
                }
            }];
    }
}


//pintch gesture detection
- (void)pinchDetected:(UIPinchGestureRecognizer *)pinchRecognizer
{
    CALayer *pinchLayer;
    id layerDelegate;
    CGPoint touchPoint = [pinchRecognizer locationInView:self.view];
    pinchLayer = [self.view.layer.presentationLayer hitTest: touchPoint];
    layerDelegate = [pinchLayer delegate];
    if (layerDelegate == self.foreImageView)
    {
        self.foreImageView.transform = CGAffineTransformScale( self.foreImageView.transform, pinchRecognizer.scale, pinchRecognizer.scale);
        pinchRecognizer.scale = 1;
    }
}
//////**************


//////************ zooming with scrollview ***********
//- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
//{
//    return self.foreImageView;
//}
//- (CGRect)zoomRectForScrollView:(UIScrollView *)scrollView withScale:(float)scale withCenter:(CGPoint)center
//{
//    NSLog(@"asd");
//    CGRect zoomRect;
//    zoomRect.size.height = scrollView.frame.size.height / scale;
//    zoomRect.size.width  = scrollView.frame.size.width  / scale;
//    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
//    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
//    return zoomRect;
//}
/////*********** stop zooming  ***********

-(void) initPB
{
    indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    indicator.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width)/2, ([UIScreen mainScreen].bounds.size.height)/2 , 70.0, 70.0);
    indicator.layer.cornerRadius = 17;
    indicator.backgroundColor = [UIColor blackColor];
    indicator.center = self.view.center;
    [self.view addSubview:indicator];
    [indicator bringSubviewToFront:self.view];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
