//
//  ManuallyPhotosVC.m
//  Flippy Cloud
//
//  Created by iSquare5 on 30/08/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import "ManuallyPhotosVC.h"
#import "UIImagePickerController+HiddenAPIs.h"
#import "base64.h"
#import "ImageCollectionViewCell.h"
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
#import "Reachability.h"
#define DEGREES_TO_RADIANS(degrees)((M_PI * degrees)/180)

@interface ManuallyPhotosVC ()<IQMediaPickerControllerDelegate,UINavigationControllerDelegate,UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *tableData;
    UIImage *image;
    NSArray *imagesARR,*LikeStatus,*FavoriteId;
    NSDictionary *dic;
    AppDelegate *app;
    MBProgressHUD *hud;
    NSMutableArray *arr1,*imagePath;
    NSData *decodedData;
    UIImage *images;
    NSString *strEncoded,*cameraStatus;
    UIActivityIndicatorView *indicator;
    NSInteger resizearrayNo, newarrayNo, totalarraySizeNo;
    NSDictionary *InsertjsonDictionary;
    NSMutableData *responseDataUpload;
    NSInteger remove,index,UploadTotalItemCount;
    NSMutableArray *allImageUploadArr;

}
@property(strong,nonatomic) NSArray *imagesARRCopy,*ThumbNailImageArr;
@property (nonatomic, retain) SidebarViewController* sidebarVC;

@end

@implementation ManuallyPhotosVC
@synthesize imagesARRCopy,ThumbNailImageArr;

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}
- (void)viewDidLoad {
        [super viewDidLoad];
        [self initPB];

        app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    
    self.sidebarVC = [[SidebarViewController alloc] init];
    [self.sidebarVC setBgRGB:0x000000];
    self.sidebarVC.view.frame  = self.view.bounds;
    [self.view addSubview:self.sidebarVC.view];
    [self.sidebarVC showHideSidebar];
    
    
        if([app.view isEqualToString:@"intro"])
        {
            IQMediaPickerController *controller = [[IQMediaPickerController alloc] init];
            controller.delegate = self;
            [controller setMediaType:IQMediaPickerControllerMediaTypePhotoLibrary];
            controller.allowsPickingMultipleItems = YES;//Yes
            [self presentViewController:controller animated:YES completion:nil];
        }
        NSString *ViewControllerstr = [NSString stringWithFormat:@"%@",[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2]];
        NSRange r1 = [ViewControllerstr rangeOfString:@"<"];
        NSRange r2 = [ViewControllerstr rangeOfString:@":"];
        NSRange rSub = NSMakeRange(r1.location + r1.length, r2.location - r1.location - r1.length);
        NSString *sub = [ViewControllerstr substringWithRange:rSub];
        if([sub isEqualToString:@"ImageViewVC"])
        {
            [indicator startAnimating];
            [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(LoadimagesCache) userInfo:nil repeats:NO];
        }
        else
        {
            if([app.manuallyPhotosStatusStr isEqualToString:@"0"])
            {
                [indicator startAnimating];
                [self redirectImages];
            }
            else
            {
                [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(LoadimagesCache) userInfo:nil repeats:NO];
            }
        }
}
-(void)viewWillAppear:(BOOL)animated
{
    if(![app.manuallyPhotosStatusStr isEqualToString:@"0"])
    {
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(LoadimagesCache) userInfo:nil repeats:NO];
    }
    else
    {
        app.manuallyPhotosStatusStr=@"1";
    }
}
-(void)LoadimagesCache
{
     [indicator stopAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
    NSLog(@"app.CheckLikePageString%@",app.CheckLikePageString);
    if ([app.CheckLikePageString isEqualToString:@"1"]) {
        int indexPath = [app.indexStr intValue];
        [app.LikeStatusAllArr replaceObjectAtIndex:indexPath withObject:@"1"];
    }
    else  if ([app.CheckLikePageString isEqualToString:@"0"])
    {
        int indexPath = [app.indexStr intValue];
        [app.LikeStatusAllArr replaceObjectAtIndex:indexPath withObject:@"0"];
    }
    
    imagesARRCopy = [app.imagesAllBackArr copy];
    ThumbNailImageArr = [app.thumAllBackArr copy];
    LikeStatus = [app.LikeStatusAllArr copy];
    FavoriteId = [app.favoriteAllArr copy];
    [self.photosCollectionVi reloadData];
    self.photosCollectionVi.hidden=NO;
    [LeftButtonAnimationView.layer removeAllAnimations];
    self.introView.hidden=YES;
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
}

-(void)redirectImages
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
        NSString *email = [prefs valueForKey:@"email"];
        NSString *contact = [prefs valueForKey:@"contact"];
        NSString *urlString = [[NSString alloc]initWithFormat:@"%@contact_image.php",app.Service ];
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSString *myRequestString =[NSString stringWithFormat:@"{\"email\":\"%@\",\"contact\":\"%@\"}",email,contact];
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
            
            
            NSLog(@"contact_image.php   ::::  %@",dictionary);
            
            
            if (!dictionary)
            {
                NSLog(@"%s: JSONObjectWithData error: %@; data = %@", __FUNCTION__, parseError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                return ;
            }
            else
            {
                [indicator stopAnimating];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;

                if([[dictionary valueForKey:@"success"] isEqualToString:@"1"])
                {
                    imagesARRCopy=[[dictionary valueForKey:@"posts"]valueForKey:@"images"];
                    LikeStatus=[[dictionary valueForKey:@"posts"]valueForKey:@"like"];
                    FavoriteId=[[dictionary valueForKey:@"posts"]valueForKey:@"fav_id"];
                    ThumbNailImageArr=[[dictionary valueForKey:@"posts"]valueForKey:@"thumbnail"];
                    app.imagesAllBackArr = [[NSMutableArray alloc]init];
                    app.thumAllBackArr = [[NSMutableArray alloc]init];
                    app.LikeStatusAllArr = [[NSMutableArray alloc]init];
                    app.favoriteAllArr  = [[NSMutableArray alloc]init];
                    app.imagesAllBackArr = [imagesARRCopy mutableCopy];
                    app.thumAllBackArr = [ThumbNailImageArr mutableCopy];
                    app.LikeStatusAllArr = [LikeStatus mutableCopy];
                    app.favoriteAllArr = [FavoriteId mutableCopy];
                    [_photosCollectionVi reloadData];
                    _photosCollectionVi.hidden=NO;
                    self.introView.hidden=YES;
                }
                else
                {
                    _photosCollectionVi.hidden=YES;
                    self.introView.hidden=NO;
                }
            }
            [indicator stopAnimating];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
             [LeftButtonAnimationView.layer removeAllAnimations];
            LeftButtonAnimationView.hidden=YES;
         }];
     }
}
- (IBAction)presentImagePicker:(id)sender
{
    IQMediaPickerController *controller = [[IQMediaPickerController alloc] init];
    controller.delegate = self;
    app.maxImageCounter = @"20";
    [controller setMediaType:IQMediaPickerControllerMediaTypePhotoLibrary];
    [controller setAllowsPickingMultipleItems:YES];
    [self presentViewController:controller animated:YES completion:nil];
}
-(IBAction)CameraBtnPressed:(id)sender
{
    IQMediaPickerController *controller = [[IQMediaPickerController alloc] init];
    controller.delegate = self;
    cameraStatus=@"camera";
    [controller setMediaType:IQMediaPickerControllerMediaTypePhoto];
    [self presentViewController:controller animated:YES completion:nil];
}

//*****************************************************************************//
    #pragma mark - UIImagePickerControllerHiddenAPIDelegate Methods
//*****************************************************************************//
- (void)mediaPickerController:(IQMediaPickerController*)controller didFinishMediaWithInfo:(NSDictionary *)info;
{
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(ShowAnimation) userInfo:nil repeats:NO];
        if([cameraStatus isEqualToString:@"camera"])
        {
            UIImage *imagestr= [[[info valueForKey:@"IQMediaTypeImage"]valueForKey:@"IQMediaImage"]objectAtIndex:0];
            UIImageWriteToSavedPhotosAlbum(imagestr, nil, nil, nil);
            image =[[[info valueForKey:@"IQMediaTypeImage"]valueForKey:@"IQMediaImage"]objectAtIndex:0];
            self.status.hidden=NO;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                
                    UIImage *imageV  = [self rotateUIImage:image];

//                    self.StatusView.hidden=NO;
//                    decodedData = UIImagePNGRepresentation(imageV);
//                    if ((decodedData.length/1024) >= 1024)
//                    {
//                        while ((decodedData.length/700) >= 700)
//                        {
//                            CGSize currentSize = CGSizeMake(imageV.size.width, imageV.size.height);
//                            imageV = [imageV resizedImage:CGSizeMake(roundf(((currentSize.width/100)*95)), roundf(((currentSize.height/100)*95))) interpolationQuality:1];
//                            decodedData = UIImageJPEGRepresentation(imageV, 0.25);
//                        }
//                    }
//                    else
//                    {
//                        decodedData = UIImageJPEGRepresentation(imageV, 0.25);
//                    }
 decodedData = UIImageJPEGRepresentation(imageV, 0.25);
                [tableData addObject:decodedData];
                [self.tableview reloadData];
                    dispatch_async(dispatch_get_main_queue(), ^
                    {
                        [self ImagePickerSave];//code here
                    });
                });
        }
        else
        {
            imagePath = [[info valueForKey:@"IQMediaTypeImage"]valueForKey:@"IQMediaImage"];
            self.status.hidden=NO;
            self.assetsFetchResults = [PHAsset fetchAssetsWithOptions:nil];
            PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
            options.version = PHVideoRequestOptionsVersionOriginal;
            PHAsset *asset= nil;
            NSString *orgFilename;
            tableData =[[NSMutableArray alloc]init];
            for (int i=0; i<imagePath.count; i++)
            {
                if (self.assetsFetchResults != nil && self.assetsFetchResults.count > 0)
                {
                    asset = [self.assetsFetchResults objectAtIndex:i];
                    NSArray *resources = [PHAssetResource assetResourcesForAsset:asset];
                    orgFilename = ((PHAssetResource*)resources[0]).originalFilename;
                }
                [tableData addObject:orgFilename];
                [self.tableview reloadData];
            }
            [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(insertImage) userInfo:nil repeats:NO];
        }
}

-(UIImage*)rotateUIImage:(UIImage*)src {
    
    // No-op if the orientation is already correct
    if (src.imageOrientation == UIImageOrientationUp) return src ;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (src.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, src.size.width, src.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, src.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, src.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (src.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, src.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, src.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, src.size.width, src.size.height,
                                             CGImageGetBitsPerComponent(src.CGImage), 0,
                                             CGImageGetColorSpace(src.CGImage),
                                             CGImageGetBitmapInfo(src.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (src.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,src.size.height,src.size.width), src.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,src.size.width,src.size.height), src.CGImage);
            break;
    }
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

-(void)ShowAnimation
{
    self.ShowTableView.hidden=NO;
    [UIView animateWithDuration:1.0
                 animations:^{
                     self.ShowTableView.frame =CGRectMake(self.view.frame.size.width - 155,65,150,50);
                     self.ShowTableView.alpha=1;
                 }];
}

/*************************************************************/

-(IBAction)ProgressBtnPressed:(id)sender
{
    self.ShowTableView.hidden=YES;
    [self animationView];
}
-(IBAction)BackBtbUploadingListPressed:(id)sender
{
     [self animationhide];

        self.ShowTableView.hidden=NO;
}
-(void)animationView
{
    [UIView animateWithDuration:0.1
                     animations:^{
                         self.TableView.frame =CGRectMake(self.view.frame.size.width- 200,20,250,self.view.frame.size.height);
                         self.TableView.alpha=1;
                     }];
}
-(void)animationhide
{
    [UIView animateWithDuration:0.1
                     animations:^{
                          self.TableView.frame =CGRectMake(self.view.frame.size.width +200,20,250,self.view.frame.size.height);
                         self.TableView.alpha=0.0;
                     }];
}
/*************************************************************/
- (void)updateLabelWhenBackgroundDone
{
    self.introView.hidden=YES;
    self.StatusView.hidden=YES;
    self.status.hidden=YES;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Completed!" message:@"Images successfully uploaded." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma multiple images selection from gallery
//multiple images from gallery
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
        [arr1 insertObject:strEncoded atIndex:index];
        NSString *obje = [NSString stringWithFormat:@"\"%@\"",strEncoded];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *email=[prefs valueForKey:@"email"];
        NSString *contact=[prefs valueForKey:@"contact"];
        NSString *urlStr = [[NSString alloc]initWithFormat:@"%@add_images.php",app.Service ];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",urlStr]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSString *myRequestString =[NSString stringWithFormat:@"{\"email\":\"%@\",\"contact\":\"%@\",\"image_name\":\[%@]}",email,contact,obje];
        NSData *requestData = [NSData dataWithBytes:[myRequestString UTF8String] length:[myRequestString length]];
        [request setTimeoutInterval:300];
        [request setHTTPMethod: @"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody: requestData];
        if(imagesARRCopy.count != 0)
        {
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
                    
                    NSLog(@"add_images.php   ::::  %@",dictionary);
               
           
                    if (!dictionary)
                    {
                        NSLog(@" JSONObjectWithData error:; data");
                        return ;
                    }
                    else
                    {
                        NSLog(@"a");
                        if([[dictionary valueForKey:@"success"] isEqualToString:@"1"])
                        {
                            NSArray *NewimagesARRCopy =[[dictionary valueForKey:@"posts"]valueForKey:@"images"];
                            NSArray *NewThumbNailImageArr=[[dictionary valueForKey:@"posts"]valueForKey:@"thumbnail"];
                            for (int i=0;i<NewimagesARRCopy.count ; i++)
                            {
                                [app.imagesAllBackArr addObject:[NSString stringWithFormat:@"%@",[NewimagesARRCopy objectAtIndex:i]]];
                                [app.thumAllBackArr addObject:[NSString stringWithFormat:@"%@",[NewThumbNailImageArr objectAtIndex:i]]];
                                [app.LikeStatusAllArr addObject:[NSString stringWithFormat:@"0"]];
                                [app.favoriteAllArr addObject:[NSString stringWithFormat:@"0"]];
                            }
                            self.introView.hidden=YES;
                        }
                        else
                        {
                            self.status.hidden=YES;
                            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error!" message:@"Fail to upload images." preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction* noButton = [UIAlertAction
                                                       actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action)
                                                       {
                                                       }];
                            [alertController addAction:noButton];
                            [self.photosCollectionVi reloadData];
                            [self presentViewController:alertController animated:YES completion:nil];
                        }
                        resizearrayNo = (int)[imagesARRCopy count];
                        newarrayNo = (int)[arr1 count];
                        imagesARRCopy = [app.imagesAllBackArr copy];
                        ThumbNailImageArr = [app.thumAllBackArr copy];
                        LikeStatus = [app.LikeStatusAllArr copy];
                        FavoriteId = [app.favoriteAllArr copy];
                        totalarraySizeNo = resizearrayNo + newarrayNo;
                        int resizeno = (int)resizearrayNo ;
                        imagesARRCopy = [app.imagesAllBackArr copy];
                        [self.photosCollectionVi performBatchUpdates:^{
                          NSMutableArray *arrayWithIndexPaths = [NSMutableArray array];
                            for (int j = resizeno; j <  totalarraySizeNo; j++)
                            {
                                [arrayWithIndexPaths addObject:[NSIndexPath indexPathForRow:j inSection:0]];
                            }
                            [self.photosCollectionVi insertItemsAtIndexPaths:arrayWithIndexPaths];
                            
                            [arr1 removeAllObjects];
                            if(UploadTotalItemCount != 0)
                            {
                                UploadTotalItemCount = UploadTotalItemCount - 1;
                                [tableData removeObjectAtIndex:index];
                                [allImageUploadArr removeObjectAtIndex:index];
                                [self.tableview reloadData];
                                [NSTimer scheduledTimerWithTimeInterval:0.30 target:self selector:@selector(UploadImages) userInfo:nil repeats:NO];
                                if (allImageUploadArr.count == 0) {
                                    [self animationhide];
                                    self.ShowTableView.hidden=YES;
                                    allImageUploadArr =nil;
                                }
                            }

                        } completion:nil];
                    }
                }];
        }
        else
        {
            NSError *error;
            NSURLResponse *response;
            NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            if (urlData)
            {
                NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:urlData options:0 error:nil];
                if (dictionary)
                {
                    if([[dictionary valueForKey:@"success"] isEqualToString:@"1"])
                    {
                        [self animationhide];
//                        self.ShowTableView.hidden=YES;
                        app.imagesAllBackArr = [[NSMutableArray alloc]init];
                        app.thumAllBackArr =  [[NSMutableArray alloc]init];
                        app.LikeStatusAllArr =  [[NSMutableArray alloc]init];
                        app.favoriteAllArr =  [[NSMutableArray alloc]init];
                        NSArray *NewimagesARRCopy =[[dictionary valueForKey:@"posts"]valueForKey:@"images"];
                        NSArray *NewThumbNailImageArr=[[dictionary valueForKey:@"posts"]valueForKey:@"thumbnail"];
                        for (int i=0;i<NewimagesARRCopy.count ; i++)
                        {
                            [app.imagesAllBackArr addObject:[NSString stringWithFormat:@"%@",[NewimagesARRCopy objectAtIndex:i]]];
                            [app.thumAllBackArr addObject:[NSString stringWithFormat:@"%@",[NewThumbNailImageArr objectAtIndex:i]]];
                            [app.LikeStatusAllArr addObject:[NSString stringWithFormat:@"0"]];
                            [app.favoriteAllArr addObject:[NSString stringWithFormat:@"0"]];
                        }
                        self.introView.hidden=YES;
                    }
                    else
                    {
                        self.status.hidden=YES;
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error!" message:@"Fail to upload images." preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction* noButton = [UIAlertAction
                                                   actionWithTitle:@"OK"
                                                   style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action)
                                                   {
                                                   }];
                        [alertController addAction:noButton];
                        [self.photosCollectionVi reloadData];
                        [self presentViewController:alertController animated:YES completion:nil];
                    }
                    resizearrayNo = (int)[imagesARRCopy count];
                    newarrayNo = (int)[arr1 count];
                    imagesARRCopy = [app.imagesAllBackArr copy];
                    ThumbNailImageArr = [app.thumAllBackArr copy];
                    LikeStatus = [app.LikeStatusAllArr copy];
                    FavoriteId = [app.favoriteAllArr copy];
                    totalarraySizeNo = resizearrayNo + newarrayNo;
                    imagesARRCopy = [app.imagesAllBackArr copy];
                    [arr1 removeAllObjects];
                    if(UploadTotalItemCount != 0)
                    {
                        UploadTotalItemCount = UploadTotalItemCount - 1;
                        [tableData removeObjectAtIndex:index];
                        [allImageUploadArr removeObjectAtIndex:index];
                        [self.tableview reloadData];
                        [NSTimer scheduledTimerWithTimeInterval:0.30 target:self selector:@selector(UploadImages) userInfo:nil repeats:NO];
                        if (allImageUploadArr.count == 0) {
                            [self animationhide];
                             self.ShowTableView.hidden=YES;
                        }
                    }
                 
                    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(reloadCollectionView) userInfo:nil repeats:NO];
                }
            }
        }
    }
}
-(void)reloadCollectionView
{
  [self.photosCollectionVi reloadData];
}

-(void)ImagePickerSave//save image captured by camera
{
    if([[Reachability sharedReachability] internetConnectionStatus] == NotReachable)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Check Internet Connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];

        [av show];
    }
    else
    {
        [Base64 initialize];
        NSString *imageString = [NSString stringWithFormat:@"%@",[Base64 encode:decodedData]];
        NSString* obje = [NSString stringWithFormat:@"\"%@\"",imageString];
        NSString *urlStr = [[NSString alloc]initWithFormat:@"%@add_images.php",app.Service ];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",urlStr]];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *email=[prefs valueForKey:@"email"];
        NSString *contact=[prefs valueForKey:@"contact"];
        NSString *myRequestString =[NSString stringWithFormat:@"{\"email\":\"%@\",\"contact\":\"%@\",\"image_name\":\"%@\",\"type\":\"camera\"}",email,contact,imageString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
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
            
            NSLog(@"add_images.php   ::::  %@",dictionary);
            
            if (!dictionary)
            {
                NSLog(@"%s: JSONObjectWithData error: %@; data = %@", __FUNCTION__, parseError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                return ;
            }
            else
            {

                NSString *success=[dictionary valueForKey:@"success"];
                int successRes=[success intValue];
                if(successRes == 1)
                {
                    NSArray  *imagesARRCopy1 =[[dictionary valueForKey:@"posts"]valueForKey:@"images"];
                    NSArray  *ThumbNailImageArr1=[[dictionary valueForKey:@"posts"]valueForKey:@"thumbnail"];
                    NSArray  *LikeStatus1=[[dictionary valueForKey:@"posts"]valueForKey:@"like"];
                    NSArray  *FavoriteId1=[[dictionary valueForKey:@"posts"]valueForKey:@"fav_id"];
                    self.photosCollectionVi.hidden=NO;
                    self.introView.hidden=YES;
                    int resultsSize;
                    if(imagesARRCopy.count != 0)
                    {
                        resultsSize = (int)[app.imagesAllBackArr count];
                        int NewData = 1;
                        [app.imagesAllBackArr addObject:[imagesARRCopy1 objectAtIndex:0]];
                        [app.thumAllBackArr addObject:[ThumbNailImageArr1 objectAtIndex:0]];
                        [app.LikeStatusAllArr addObject:@"0"];
                        [app.favoriteAllArr addObject:@"0"];
                        imagesARRCopy = [app.imagesAllBackArr copy];
                        ThumbNailImageArr = [app.thumAllBackArr copy];
                        LikeStatus = [app.LikeStatusAllArr copy];
                        FavoriteId = [app.favoriteAllArr copy];
                        int total = resultsSize + NewData;
                        app.imagesAllBackArr = [[NSMutableArray alloc]init];
                        app.thumAllBackArr = [[NSMutableArray alloc]init];
                        app.LikeStatusAllArr = [[NSMutableArray alloc]init];
                        app.favoriteAllArr  = [[NSMutableArray alloc]init];
                        app.imagesAllBackArr = [imagesARRCopy mutableCopy];
                        app.thumAllBackArr = [ThumbNailImageArr mutableCopy];
                        app.LikeStatusAllArr = [LikeStatus mutableCopy];
                        app.favoriteAllArr = [FavoriteId mutableCopy];
                        [self.photosCollectionVi performBatchUpdates:^{
                         NSMutableArray *arrayWithIndexPaths = [NSMutableArray array];
                            for (int j = resultsSize; j <  total; j++)
                            {
                                [arrayWithIndexPaths addObject:[NSIndexPath indexPathForRow:j inSection:0]];
                            }
                            [self.photosCollectionVi insertItemsAtIndexPaths:arrayWithIndexPaths];
                        } completion:nil];
                    }
                    else
                    {
                        imagesARRCopy=[[dictionary valueForKey:@"posts"]valueForKey:@"images"];
                        ThumbNailImageArr=[[dictionary valueForKey:@"posts"]valueForKey:@"thumbnail"];
                        LikeStatus=[NSArray arrayWithObject:[NSString stringWithFormat:@"0"]];
                        FavoriteId=[NSArray arrayWithObject:[NSString stringWithFormat:@"0"]];
                        resultsSize = 0;
                        [self.photosCollectionVi reloadData];
                    }
                    [self animationhide];
                    self.ShowTableView.hidden=YES;
                    
                    UIAlertController * alert=   [UIAlertController
                                                alertControllerWithTitle:@"Success"
                                                  message:@"Uploaded Successfully."
                                                  preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* noButton = [UIAlertAction
                                               actionWithTitle:@"OK"
                                               style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action)
                                               {
                                                   [indicator stopAnimating];
                                                   [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
                                               }];
                    [alert addAction:noButton];
                    [self presentViewController:alert animated:YES completion:nil];
                }
                else
                {
                    [self animationhide];
                     self.ShowTableView.hidden=YES;
                    self.status.hidden=YES;
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error!" message:@"Fail to upload images." preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* noButton = [UIAlertAction
                                               actionWithTitle:@"OK"
                                               style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action)
                                               {
                                               }];
                    [alertController addAction:noButton];
                    [self presentViewController:alertController animated:YES completion:nil];
                    [self.photosCollectionVi reloadData];
                    
                }
            }
        }];
    }
}
-(void)mediaPickerControllerDidCancel:(IQMediaPickerController *)controller
{
    self.status.hidden=YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return imagesARRCopy.count;
}

- (ImageCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCollectionViewCell *cell = [self.photosCollectionVi dequeueReusableCellWithReuseIdentifier:[ImageCollectionViewCell reuseIdentifier] forIndexPath:indexPath];
    cell = nil;
    if (cell == nil) {
        cell = [self.photosCollectionVi dequeueReusableCellWithReuseIdentifier:[ImageCollectionViewCell reuseIdentifier] forIndexPath:indexPath];
           }
    UIImageView *recipeImageView = (UIImageView *)[cell viewWithTag:100];
    UIImageView *LikeImg = (UIImageView *)[cell viewWithTag:101];
    UILabel  *ProcessLabel = (UILabel *)[cell viewWithTag:200];
    UIImageView *BGProcessImg = (UIImageView *)[cell viewWithTag:201];
    BGProcessImg.image=[UIImage imageNamed:@"process-1.png"];
    ProcessLabel.hidden=YES;
    BGProcessImg.hidden=YES;
    NSString *imageStr=[ThumbNailImageArr objectAtIndex:indexPath.row];
    recipeImageView.imageURL = [NSURL URLWithString:imageStr];
    NSString *checkLikeStr = [NSString stringWithFormat:@"%@",[LikeStatus objectAtIndex:indexPath.row]];
    if([checkLikeStr isEqualToString:@"1"])
    {
        LikeImg.hidden=NO;
        LikeImg.image=[UIImage imageNamed:@"Fav_Sel143.png"];
    }
    else
    {
        LikeImg.hidden=YES;
    }
    return cell;
}
-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    int i=(int)indexPath.row;
    NSLog(@"%@",app.LikeStatusAllArr);
    NSLog(@"%@",FavoriteId);
    app.SelImgId=[NSString stringWithFormat:@"%i",i];
    app.ManuallySelImageStr= [NSString stringWithFormat:@"%@",[app.imagesAllBackArr objectAtIndex:indexPath.row]];
    app.SetThumbImageV = [NSString stringWithFormat:@"%@",[app.thumAllBackArr objectAtIndex:indexPath.row]];
    app.indexStr = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    NSString *checkLikeStr = [NSString stringWithFormat:@"%@",[app.LikeStatusAllArr objectAtIndex:indexPath.row]];
    int checklikedImage = [checkLikeStr intValue];
    if(checklikedImage == 1)
    {
        app.view=@"liked";
        NSString *checkLikeStr = [NSString stringWithFormat:@"%@",[app.favoriteAllArr objectAtIndex:indexPath.row]];
        if(![checkLikeStr isEqualToString:@"no"])
        {
            app.LikedStatusForDelete=[NSString stringWithFormat:@"%@",[app.favoriteAllArr objectAtIndex:indexPath.row]];
            NSLog(@"%@",[NSString stringWithFormat:@"%@",[app.favoriteAllArr objectAtIndex:checklikedImage]]);
            NSLog(@"%@",FavoriteId);
        }
    }
    else
    {
         app.view=@"";
    }
    [self performSegueWithIdentifier:@"ImageViewVC" sender:self];
}

- (IBAction)show:(id)sender
{
    [self.sidebarVC showHideSidebar];
}
- (void)panDetected:(UIPanGestureRecognizer*)recoginzer
{
    [self.sidebarVC panDetected:recoginzer];
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
-(void) initPB{
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
