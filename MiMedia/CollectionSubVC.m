//
//  CollectionSubVC.m
//  Flippy Cloud
//
//  Created by iSquare5 on 20/08/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import "CollectionSubVC.h"
#import "CollectionVC.h"
#import "AppDelegate.h"
#import "ImageViewVC.h"
#import "AsyncImageView.h"
#import "AlbumContentsViewController.h"
#import "AssetsDataIsInaccessibleViewController.h"
#import "ImageCollectionViewCell.h"
#import "Reachability.h"
#import "BIZGrid4plus1CollectionViewLayout.h"


#import "ManuallyPhotosVC.h"
#import "UIImagePickerController+HiddenAPIs.h"
#import "base64.h"
#import "IQAlbumAssetsViewController.h"
#import "SidebarViewController.h"
#import "ImageViewVC.h"
#import "AsyncImageView.h"
#import "MBProgressHUD.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "UIImage+Resize.h"
#import "IQMediaPickerController.h"
#import "IQFileManager.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "M13ProgressViewRing.h"
#define DEGREES_TO_RADIANS(degrees)((M_PI * degrees)/180)

@interface CollectionSubVC ()<IQMediaPickerControllerDelegate,UINavigationControllerDelegate>
{
    AppDelegate *app;
    NSArray *imageCollArr,*CollImageArr;
    UIActivityIndicatorView *indicator;
    NSMutableArray *tableData;

    NSMutableArray *allImageUploadArr;
    UIImage *images;
    NSData *decodedData;
    NSInteger resizearrayNo, newarrayNo, totalarraySizeNo;
    NSString *strEncoded,*cameraStatus;
    NSInteger remove,index,UploadTotalItemCount;
    NSMutableArray *arr1,*imagePath;
    UIRefreshControl *refreshControl;


}
@end

BOOL downViewsees = NO;
BOOL tableClickedeed = YES;
int countIndexeed=0;

@implementation CollectionSubVC

-(void)viewDidLoad
{
    [super viewDidLoad];
    app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    [self initPB];
    app.view=@"sub";
    [indicator startAnimating];
    _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    _tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:_tapRecognizer];
   
    UIView *RenameColl = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [self.RenameCollTXT setLeftViewMode:UITextFieldViewModeAlways];
    [self.RenameCollTXT setLeftView:RenameColl];
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
    NSLog(@"asd");
     [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(CollectVC) userInfo:nil repeats:NO];
}
-(void)CollectVC
{
    self.CollName.text=app.superCollName;
    if([[Reachability sharedReachability] internetConnectionStatus] == NotReachable){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Check Internet Connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
    else
    {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *email=[prefs valueForKey:@"email"];
        NSString *phone=[prefs valueForKey:@"contact"];
//      NSString *urlString = [[NSString alloc]initWithFormat:@"%@get_collection_image.php",app.Service];

    NSString *urlString = [[NSString alloc]initWithFormat:@"http://46.166.173.116/FlippyCloud/webservices/get_collection_image_ios.php"];//temp
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSString *myRequestString =[NSString stringWithFormat:@"{\"collection_name\":\"%@\",\"email\":\"%@\",\"contact\":\"%@\"}",app.superCollName,email,phone];
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
             NSLog(@"get_collection_image_ios.php  ::::  %@",dictionary);
            if (!dictionary)
            {
                NSLog(@"%s: JSONObjectWithData error: %@; data = %@", __FUNCTION__, parseError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                return ;
            }
            else
            {
//                NSLog(@"%@",dictionary);
                NSString *success=[dictionary valueForKey:@"success"];
                if([success isEqualToString:@"1"])
                {
                    self.EmptyView.hidden=YES;
                    self.collectionView.hidden=NO;
                    photosCollectionVii.hidden=NO;
                    CollImageArr=[[dictionary valueForKey:@"posts"]valueForKey:@"images"];
                   
                    NSString *totalPhotos =[NSString stringWithFormat:@"%lu photos",(unsigned long)CollImageArr.count];
                    [prefs setObject:totalPhotos forKey:@"totalPhotos"];
                    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                    NSString *PhotosColl =[[[dictionary valueForKey:@"posts"]valueForKey:@"images"]lastObject];
                    [prefs setObject:PhotosColl forKey:@"PhotosColl"];
                    [indicator stopAnimating];
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
                    [photosCollectionVii reloadData];
                }
                else
                {
                    self.EmptyView.hidden=NO;
                    self.collectionView.hidden=YES;
                    [indicator stopAnimating];
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
                }
            }
        }];
    }
}
-(IBAction)BackBtnPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return CollImageArr.count;
}
- (ImageCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[ImageCollectionViewCell reuseIdentifier] forIndexPath:indexPath];
    UIImageView *recipeImageView = (UIImageView *)[cell viewWithTag:100];
    NSString *imsage=[CollImageArr objectAtIndex:indexPath.row];
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:[NSURL URLWithString:imsage]
                          options:0
                         progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                         }
                        completed:^(UIImage *image1, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                            if (image1) {
                                recipeImageView.image = image1;
                            }
                        }];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    countIndexeed = -1;
    app.view=@"CollSub";
    app.CollImgURL=[CollImageArr objectAtIndex:indexPath.row];
    [photosCollectionVii reloadItemsAtIndexPaths:[photosCollectionVii indexPathsForVisibleItems]];
    photoImageVii.imageURL = [[app.json valueForKey:@"posts"]valueForKey:@"picture_name"];

    //navigation
    UINavigationController *navigationController = (UINavigationController *)app.window.rootViewController;
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    ImageViewVC *MainPage = (ImageViewVC*)[mainStoryboard instantiateViewControllerWithIdentifier: @"ImageViewVC"];
    [navigationController pushViewController:MainPage animated:YES];
    //---- stop
    
    [collectionView reloadData];
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor clearColor];
}
//stop

-(IBAction)MenuBtnPressed:(id)sender
{
    self.RenameCollView.hidden=NO;
    self.DeleteCollView.hidden=NO;
    self.ShareCollView.hidden=NO;
    if([self.MenuBtn isSelected])
    {
        [self animationhide];
        [UIView animateWithDuration:1.5
                         animations:^{
                             self.collectionView.frame=CGRectMake(0,self.MenuBtn.frame.origin.y+50, self.collectionView.frame.size.width, self.collectionView.frame.size.height+100);
                         }];
        [sender setSelected:NO];
    }
    else
    {
        [self animationView];
        [UIView animateWithDuration:1.5
                         animations:^{
                             self.collectionView.frame=CGRectMake(0,self.MenuBtn.frame.origin.y+150, self.collectionView.frame.size.width, self.collectionView.frame.size.height-100);
                         }];
        [sender setSelected:YES];
    }
}
-(void)animationView
{
    [UIView animateWithDuration:1.5
                     animations:^{
                         self.RenameCollView.frame =CGRectMake(self.MenuBtn.frame.origin.x-20,90,60,60);
                         self.DeleteCollView.frame =CGRectMake(self.RenameCollView.frame.origin.x- 65,self.RenameCollView.frame.origin.y,self.RenameCollView.frame.size.width,self.RenameCollView.frame.size.height);
                         self.ShareCollView.frame =CGRectMake(self.DeleteCollView.frame.origin.x- 65,self.DeleteCollView.frame.origin.y,self.DeleteCollView.frame.size.width,self.DeleteCollView.frame.size.height);
                        self.RenameCollView.alpha=1;
                        self.DeleteCollView.alpha=1;
                        self.ShareCollView.alpha=1;
                    }];
}
-(void)animationhide
{
    [UIView animateWithDuration:1.5
                     animations:^{
                         self.RenameCollView.frame =CGRectMake(self.MenuBtn.frame.origin.x - 20,90,60,60);
                         self.DeleteCollView.frame =self.RenameCollView.frame;
                          self.ShareCollView.frame =self.RenameCollView.frame;
                         self.RenameCollView.alpha=0.0;
                         self.DeleteCollView.alpha=0.0;
                          self.ShareCollView.alpha=0.0;
                     }];
}
-(IBAction)DeleteCollBtnPressed:(id)sender
{
    [indicator startAnimating];
    self.CollName.text=app.superCollName;
    if([[Reachability sharedReachability] internetConnectionStatus] == NotReachable){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Check Internet Connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
    else
    {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *email=[prefs valueForKey:@"email"];
        NSString *phone=[prefs valueForKey:@"contact"];
        NSString *urlString = [[NSString alloc]initWithFormat:@"%@deletecoll.php",app.Service];
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSString *myRequestString =[NSString stringWithFormat:@"{\"email\":\"%@\",\"contact\":\"%@\",\"collname\":\"%@\",\"collid\":\"%@\"}",email,phone,app.superCollName,app.CollIdarr];
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
            NSLog(@"deletecoll.php  ::::  %@",dictionary);
            
            
            if (!dictionary)
            {
                NSLog(@"%s: JSONObjectWithData error: %@; data = %@", __FUNCTION__, parseError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                return ;
            }
            else
            {
//                NSLog(@"%@",dictionary);

                NSString *success=[dictionary valueForKey:@"success"];
                if([success isEqualToString:@"1"])
                {
                    app.CollectionNameArrCopy=NULL;
                    [self.navigationController popViewControllerAnimated:YES];
                    [indicator stopAnimating];
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
                }
                else
                {
                    [indicator stopAnimating];
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
                }
            }
        }];
    }
}
-(IBAction)RenameCollBtnPressed:(id)sender
{
    self.RenameView.hidden=NO;
    NSLog(@"RenameCollBtnPressed show");
    self.RenameCollTXT.text=[NSString stringWithFormat:@"%@",app.superCollName];
    [self animationhide];
    

    
    [UIView animateWithDuration:2
                     animations:^{
                         self.collectionView.frame=CGRectMake(0,self.MenuBtn.frame.origin.y+150, self.collectionView.frame.size.width, self.collectionView.frame.size.height+100);
                     }];
}
-(IBAction)RenameBackBtnPressed:(id)sender
{
    self.RenameView.hidden=YES;
    NSLog(@"RenameCollBtnPressed hide");
    [self animationhide];
    [UIView animateWithDuration:1.5
                     animations:^{
                         self.collectionView.frame=CGRectMake(0,self.MenuBtn.frame.origin.y+50, self.view.frame.size.width, self.view.frame.size.height);
                     }];
    [self.RenameBackBtn setSelected:NO];
}
-(IBAction)RenameDoneBtnPressed:(id)sender
{
    [indicator startAnimating];
    self.CollName.text=app.superCollName;
    if([[Reachability sharedReachability] internetConnectionStatus] == NotReachable){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Check Internet Connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
    else
    {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *email=[prefs valueForKey:@"email"];
        NSString *phone=[prefs valueForKey:@"contact"];
        NSString *urlString = [[NSString alloc]initWithFormat:@"%@rename_coll.php",app.Service];
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSString *myRequestString =[NSString stringWithFormat:@"{\"email\":\"%@\",\"contact\":\"%@\",\"oldName\":\"%@\",\"id\":\"%@\",\"newName\":\"%@\"}",email,phone,app.superCollName,app.CollIdarr,self.RenameCollTXT.text];
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
            NSLog(@"rename_coll.php  ::::  %@",dictionary);
            if (!dictionary)
            {
                NSLog(@"%s: JSONObjectWithData error: %@; data = %@", __FUNCTION__, parseError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                return ;
            }
            else
            {
//                NSLog(@"%@",dictionary);

                NSString *success=[dictionary valueForKey:@"Success"];
                if([success isEqualToString:@"1"])
                {
                    app.CollectionNameArrCopy=NULL;
                    self.CollName.text=[NSString stringWithFormat:@"%@",[[dictionary valueForKey:@"posts"]valueForKey:@"newcollection"]];
                    self.RenameView.hidden=YES;
                    [self animationhide];
                    [UIView animateWithDuration:1.5
                                     animations:^{
                                         self.collectionView.frame=CGRectMake(0,self.MenuBtn.frame.origin.y+50, self.view.frame.size.width, self.view.frame.size.height);
                                     }];

                    [indicator stopAnimating];
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
                }
                else
                {
                    [self animationhide];
                    [UIView animateWithDuration:1.5
                                     animations:^{
                                         self.collectionView.frame=CGRectMake(0,self.MenuBtn.frame.origin.y+50, self.view.frame.size.width, self.view.frame.size.height);
                                     }];

                    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Something Wrong." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [av show];
                    [indicator stopAnimating];
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
                }
            }
        }];
    }
}
-(IBAction)ShareCollBtnPressed:(id)sender
{
    if([[Reachability sharedReachability] internetConnectionStatus] == NotReachable)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Check Internet Connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
    else
    {
        NSURL *Url=[NSURL URLWithString:[NSString stringWithFormat:@"http://www.flippycloud.com/"]];
        NSArray *objectsToShare = @[Url];
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
- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
   
    [self.view endEditing:YES];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField:textField up:YES];
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField:textField up:NO];
}
- (void)animateTextField:(UITextField*)textField up:(BOOL)up
{
    CGRect frame = self.view.frame;
    CGFloat keyboardHeight = 200.f;
    if (up)
    {
        CGRect textFieldFrame = textField.frame;
        CGFloat bottomYPos = textFieldFrame.origin.y + textFieldFrame.size.height;
        animateDistance = bottomYPos + 100 + keyboardHeight - frame.size.height;
        if (animateDistance < 0)
            animateDistance = 0;
        else
            animateDistance = fabs(animateDistance);
    }
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.25];
    if (!(!up && frame.origin.y == 20.f))
    {
        if([[UIApplication sharedApplication] statusBarOrientation])
        {
            frame.origin.y = frame.origin.y + (up ? -animateDistance : animateDistance);
        }
        else if([[UIApplication sharedApplication] statusBarOrientation])
        {
            frame.origin.y = frame.origin.y + (up ? animateDistance : -animateDistance);
        }
        self.view.frame = frame;
    }
    [UIView commitAnimations];
}
#pragma Add multiple images to collection
- (IBAction)presentImagePicker:(id)sender
{
    IQMediaPickerController *controller = [[IQMediaPickerController alloc] init];
    controller.delegate = self;
    app.maxImageCounter = @"10";
    [controller setMediaType:IQMediaPickerControllerMediaTypePhotoLibrary];
    [controller setAllowsPickingMultipleItems:YES];
    [self presentViewController:controller animated:YES completion:nil];
}
-(void)mediaPickerControllerDidCancel:(IQMediaPickerController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"Cancelled");
}
//*****************************************************************************//
#pragma mark - UIImagePickerControllerHiddenAPIDelegate Methods
//*****************************************************************************//
- (void)mediaPickerController:(IQMediaPickerController*)controller didFinishMediaWithInfo:(NSDictionary *)info;
{
    imagePath = [[info valueForKey:@"IQMediaTypeImage"]valueForKey:@"IQMediaImage"];
    self.assetsFetchResults = [PHAsset fetchAssetsWithOptions:nil];
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.version = PHVideoRequestOptionsVersionOriginal;
//    PHAsset *asset= nil;
//    NSString *orgFilename;
//    tableData =[[NSMutableArray alloc]init];
//    for (int i=0; i<imagePath.count; i++)
//    {
//        if (self.assetsFetchResults != nil && self.assetsFetchResults.count > 0)
//        {
//            asset = [self.assetsFetchResults objectAtIndex:i];
//            NSArray *resources = [PHAssetResource assetResourcesForAsset:asset];
//            orgFilename = ((PHAssetResource*)resources[0]).originalFilename;
//        }
//        [tableData addObject:orgFilename];
//        [self.tableview reloadData];
//    }

    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(insertImage) userInfo:nil repeats:NO];
    
    
}
-(void)insertImage
{
    if([[Reachability sharedReachability] internetConnectionStatus] == NotReachable)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Check Internet Connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
    else
    {
        arr1=[[NSMutableArray alloc]init];
        index = 0;
        allImageUploadArr =[[NSMutableArray alloc]init];
        UploadTotalItemCount  = imagePath.count;
        allImageUploadArr = [NSMutableArray arrayWithArray:imagePath];
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(UploadImages) userInfo:nil repeats:NO];
    }
}
-(void)UploadImages
{
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(FinallyCall) userInfo:nil repeats:NO];
}
-(void)FinallyCall
{
    if (allImageUploadArr.count != 0)
    {
        images = [allImageUploadArr objectAtIndex:index];
        decodedData = UIImageJPEGRepresentation(images, 0.1);
        strEncoded = [NSString stringWithFormat:@"%@",[Base64 encode:decodedData]];
        arr1 = [[NSMutableArray alloc]init];
        [arr1 insertObject:strEncoded atIndex:0];
        NSString *obje = [NSString stringWithFormat:@"\"%@\"",strEncoded];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//        NSString *email=[prefs valueForKey:@"email"];
        NSString *contact=[prefs valueForKey:@"contact"];
        NSString *urlStr = [[NSString alloc]initWithFormat:@"%@add_multipal_img_collection.php",app.Service ];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",urlStr]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSString *myRequestString =[NSString stringWithFormat:@"{\"contact\":\"%@\",\"collection_name\":\"%@\",\"image_name\":\[%@]}",contact,app.superCollName,obje];
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
            NSLog(@"add_multipal_img_drive.php  ::::  %@",dictionary);
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
                    CollImageArr=[[dictionary valueForKey:@"posts"]valueForKey:@"images"];
                    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                    NSString *PhotosColl =[[[dictionary valueForKey:@"posts"]valueForKey:@"images"]lastObject];
                    [prefs setObject:PhotosColl forKey:@"PhotosColl"];
                    [allImageUploadArr removeObjectAtIndex:index];
                    //                    index=index+1;
                    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(FinallyCall) userInfo:nil repeats:NO];
                    [indicator stopAnimating];
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
                    [photosCollectionVii reloadData];
//                    if(UploadTotalItemCount != 0)
//                    {
//                        UploadTotalItemCount = UploadTotalItemCount - 1;
//                        [tableData removeObjectAtIndex:index];
//                        [allImageUploadArr removeObjectAtIndex:index];
//                        [self.tableview reloadData];
//                        [NSTimer scheduledTimerWithTimeInterval:0.30 target:self selector:@selector(UploadImages) userInfo:nil repeats:NO];
//                        if (allImageUploadArr.count == 0) {
//                            [self animationTablehide];
//                            self.ShowTableView.hidden=YES;
//                            allImageUploadArr =nil;
//                        }
//                    }

                }
                else
                {
                    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Images are not available." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [indicator stopAnimating];
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
                    [av show];
                }
            }
        }];
    }
    else
    {
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(reloadCollectionView) userInfo:nil repeats:NO];
    }
}
-(void)reloadCollectionView
{
    [photosCollectionVii reloadData];
}
#pragma uploading image list in table view
-(void)ShowAnimation
{
    self.ShowTableView.hidden=NO;
    [UIView animateWithDuration:1.0
                     animations:^{
                         self.ShowTableView.frame =CGRectMake(self.view.frame.size.width - 155,65,150,50);
                         self.ShowTableView.alpha=1;
                     }];
}
-(IBAction)ProgressBtnPressed:(id)sender
{
    self.ShowTableView.hidden=YES;
    [self animationTableView];
}
-(void)animationTableView
{
    [UIView animateWithDuration:0.1
                     animations:^{
                         self.TableView.frame =CGRectMake(self.view.frame.size.width- 200,20,250,self.view.frame.size.height);
                         self.TableView.alpha=1;
                     }];
}
-(void)animationTablehide
{
    [UIView animateWithDuration:0.1
                     animations:^{
                         self.TableView.frame =CGRectMake(self.view.frame.size.width +200,20,250,self.view.frame.size.height);
                         self.TableView.alpha=0.0;
                     }];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableData count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    if([allImageUploadArr objectAtIndex:indexPath.row] == NULL)
    {
    }
    else
    {
        UIImageView *recipeImageView = (UIImageView *)[cell viewWithTag:101];
        recipeImageView.image =[allImageUploadArr objectAtIndex:indexPath.row];
        
        UILabel *label= (UILabel *)[cell viewWithTag:102];
        label.text=[tableData objectAtIndex:indexPath.row];
    }
    return cell;
}




- (void)didReceiveMemoryWarning
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
