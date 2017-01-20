//
//  ManuallyVideosVC.m
//  Flippy Cloud
//
//  Created by iSquare5 on 01/09/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import "ManuallyVideosVC.h"
#import "UIImagePickerController+HiddenAPIs.h"
#import "base64.h"
#import "IQMediaPickerController.h"
#import "IQFileManager.h"
#import "ImageCollectionViewCell.h"
#import "SidebarViewController.h"
#import "AsyncImageView.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "Reachability.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "SDAVAssetExportSession.h"
typedef void (^ALAssetsLibraryAssetForURLResultBlock)(ALAsset *asset);
typedef void (^ALAssetsLibraryAccessFailureBlock)(NSError *error);
@interface ManuallyVideosVC ()<IQMediaPickerControllerDelegate,UINavigationControllerDelegate,UIGestureRecognizerDelegate>
{
    
     UIActivityIndicatorView *indicator;
    AppDelegate *app;
    NSArray *videoUrl,*videoURLCopy,*infoArry,*videoImageArry,*ImgaesArr;
    NSMutableArray *  arr1,*multiVideos,*arr2,*videoImageArryCopy, *videoImageArryCopy2,*video_imageArr;
    NSDictionary *mediaInfo;
    NSMutableArray *imagesAllArray;
    NSInteger AllItems;
    NSDictionary *dict;
    NSInteger DicItems,TotalCount,noItem;
    UIImage *thumbnail;
    NSIndexPath *indexPathForDelete ;
    NSString *VideoNameStr,*VideoThumNameStr;
    UIRefreshControl *refreshControl;
    NSInteger resizearrayNo,newarrayNo,totalarraySizeNo;//
    NSInteger remove,index,UploadTotalItemCount;//

}
@property (nonatomic, retain) SidebarViewController* sidebarVC;
@end

@implementation ManuallyVideosVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initPB];
    [indicator startAnimating];
    app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    arr1=[[NSMutableArray alloc]init];
    arr2=[[NSMutableArray alloc]init];
    multiVideos=[[NSMutableArray alloc]init];
    videoImageArryCopy=[[NSMutableArray alloc]init];
    videoImageArryCopy2= [[NSMutableArray alloc]init];
    video_imageArr = [[NSMutableArray alloc]init];
  
    self.sidebarVC = [[SidebarViewController alloc] init];
    [self.sidebarVC setBgRGB:0x000000];
    self.sidebarVC.view.frame  = self.view.bounds;
    [self.view addSubview:self.sidebarVC.view];
    [self.sidebarVC showHideSidebar];
    
    NSString *documentsDirectory= [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *directory = [documentsDirectory stringByAppendingPathComponent:@""];
    NSError *error = nil;
    for (NSString *file in [fm contentsOfDirectoryAtPath:directory error:&error])
    {
        BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@%@", documentsDirectory, file] error:&error];
        if (!success || error)
        {
        }
    }
    
    if([[Reachability sharedReachability] internetConnectionStatus] == NotReachable)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Check Internet Connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [indicator stopAnimating];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
        [av show];
    }
    else
    {
        [NSTimer scheduledTimerWithTimeInterval:0.1 //Every how many seconds
                                         target:self
                                       selector:@selector(allVideos)
                                       userInfo:nil
                                        repeats:NO];
    }
    
    UILongPressGestureRecognizer *lpgr
    = [[UILongPressGestureRecognizer alloc]
       initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.delegate = self;
    lpgr.delaysTouchesBegan = YES;
    [self.photosCollectionVi addGestureRecognizer:lpgr];

    self.photosCollectionVi.allowsMultipleSelection=NO;

   refreshControl = [[UIRefreshControl alloc]init];
    [self.photosCollectionVi addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
}
- (void)refreshTable
{
    
    NSLog(@"refreshing");
    [refreshControl endRefreshing];
    [self.photosCollectionVi reloadData];
}
-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded)
    {
        UICollectionViewCell* cell =
        [self.photosCollectionVi cellForItemAtIndexPath:indexPathForDelete];
        UIImageView *CheckedmarkImgView= (UIImageView *)[cell viewWithTag:1];
        CheckedmarkImgView.hidden=YES;
        return;
    }
    CGPoint p = [gestureRecognizer locationInView:self.photosCollectionVi];
    
    indexPathForDelete = [self.photosCollectionVi indexPathForItemAtPoint:p];
    if (indexPathForDelete == nil)
    {
        NSLog(@"couldn't find index path");
    }
    else
    {
        UICollectionViewCell* cell =
        [self.photosCollectionVi cellForItemAtIndexPath:indexPathForDelete];
        UIImageView *CheckedmarkImgView= (UIImageView *)[cell viewWithTag:1];
        CheckedmarkImgView.hidden=NO;
        self.DeleteVideosBtn.hidden=NO;
        
        NSString *VideoThumbName =[NSString stringWithFormat:@"%@",[ImgaesArr objectAtIndex:indexPathForDelete.row]];
        NSArray *VideoThumb = [VideoThumbName componentsSeparatedByString:@"/"];
        NSString *VideoName =[NSString stringWithFormat:@"%@",[videoURLCopy objectAtIndex:indexPathForDelete.row]];
        NSArray *Video = [VideoName componentsSeparatedByString:@"/"];

        VideoNameStr=[NSString stringWithFormat:@"%@",[Video lastObject]];
        VideoThumNameStr=[NSString stringWithFormat:@"%@",[VideoThumb lastObject]];
        
    }
}
-(IBAction)DeleteAVideosBtnPressed:(id)sender
{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"Are you sure you want to Delete this item? It will be removed from the cloud." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                         {
                             [self DeleteFun];
                         }];
    UIAlertAction* cancle = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action)
                             {

                             }];
    [alertController addAction:ok];
    [alertController addAction:cancle];
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}
-(void)DeleteFun
{
    [indicator startAnimating];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *contact=[prefs valueForKey:@"contact"];
    NSString *urlString = [[NSString alloc]initWithFormat:@"%@delete_video.php",app.Service ];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *myRequestString =[NSString stringWithFormat:@"{\"contact\":\"%@\",\"video_name\":\"%@\",\"video_thumb\":\"%@\"}",contact,VideoNameStr,VideoThumNameStr];
    
    NSData *requestData = [NSData dataWithBytes:[myRequestString UTF8String] length:[myRequestString length]];
    [request setTimeoutInterval:200];
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
        
        
        NSLog(@"delete_video.php   ::::  %@",dictionary);
        
        if (!dictionary)
        {
            NSLog(@"%s: JSONObjectWithData error: %@; data = %@", __FUNCTION__, parseError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            return ;
        }
        else
        {
            if([[dictionary valueForKey:@"success"] isEqualToString:@"1"])
            {
                UICollectionViewCell* cell =
                [self.photosCollectionVi cellForItemAtIndexPath:indexPathForDelete];
                
                UIImageView *CheckedmarkImgView= (UIImageView *)[cell viewWithTag:1];
                CheckedmarkImgView.hidden=YES;
                self.DeleteVideosBtn.hidden=YES;
                [self allVideos];
            }
            else
            {
                [indicator stopAnimating];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
            }
        }
    }];

}
-(void)allVideos
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *contact=[prefs valueForKey:@"contact"];
    NSString *urlString = [[NSString alloc]initWithFormat:@"%@contact_video.php",app.Service ];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *myRequestString =[NSString stringWithFormat:@"{\"contact\":\"%@\"}",contact];
    NSData *requestData = [NSData dataWithBytes:[myRequestString UTF8String] length:[myRequestString length]];
    [request setTimeoutInterval:200];
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
        
        
                    NSLog(@"contact_video.php   ::::  %@",dictionary);
        
        if (!dictionary)
        {
            NSLog(@"%s: JSONObjectWithData error: %@; data = %@", __FUNCTION__, parseError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            return ;
        }
        else
        {
            if([[dictionary valueForKey:@"success"] isEqualToString:@"1"])
            {
                [indicator stopAnimating];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
                videoURLCopy=[[dictionary valueForKey:@"posts"]valueForKey:@"video"];
                ImgaesArr=[[dictionary valueForKey:@"posts"]valueForKey:@"image"];
                
                
                app.VidesAllBackArr = [[NSMutableArray alloc]init];
                app.VidesImageAllBackArr = [[NSMutableArray alloc]init];

                app.VidesAllBackArr = [videoURLCopy mutableCopy];
                app.VidesImageAllBackArr = [ImgaesArr mutableCopy];
                [self.photosCollectionVi reloadData];
                self.photosCollectionVi.hidden=NO;
                self.introView.hidden=YES;
            }
            else
            {
                [indicator stopAnimating];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
                self.photosCollectionVi.hidden=YES;
                self.introView.hidden=NO ;
            }
        }
    }];
}
- (IBAction)presentImagePicker:(id)sender
{
    IQMediaPickerController *controller = [[IQMediaPickerController alloc] init];
    controller.delegate = self;
    [controller setMediaType:IQMediaPickerControllerMediaTypeVideoLibrary];
    app.maxVideoCounter=@"2";
    [controller setAllowsPickingMultipleItems:YES];
    [self presentViewController:controller animated:YES completion:nil];
}
//*****************************************************************************/
#pragma mark - UIImagePickerControllerHiddenAPIDelegate Methods
//*****************************************************************************/
- (void)mediaPickerController:(IQMediaPickerController*)controller didFinishMediaWithInfo:(NSDictionary *)info;
{
    
    mediaInfo = [info copy];
    NSString *key = @"IQMediaTypeVideo";
    dict = [mediaInfo objectForKey:key];//4
    [self VideoConverting];
   
}

-(void)VideoConverting
{
    imagesAllArray = [[NSMutableArray alloc]init];
    DicItems = dict.count;
    
    
    [self convertVideoToMP4];
   // [self FinalCall];
}

- (NSData *)getCroppedData:(NSURL *)urlMedia
{
    ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
    __block NSData *iData = nil;
    __block BOOL bBusy = YES;
    
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
    {
        ALAssetRepresentation *representation = myasset.defaultRepresentation;
        long long size = representation.size;
        NSMutableData *rawData = [[NSMutableData alloc] initWithCapacity:size];
        void *buffer = [rawData mutableBytes];
        [representation getBytes:buffer fromOffset:0 length:size error:nil];
        iData = [[NSData alloc] initWithBytes:buffer length:size];
        bBusy = NO;
    };
    
    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
    {
        NSLog(@"booya, cant get image - %@",[myerror localizedDescription]);
    };
    
    [assetLibrary assetForURL:urlMedia
                    resultBlock:resultblock
                   failureBlock:failureblock];
    
    while (bBusy)
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    
    return iData;
}
-(void)insertVideo
{
    NSData *data123;
    NSString *base64String;
    NSString *myDocumentPath;
    NSURL *urlVideo;
    NSString *documentsDirectory= [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];

    myDocumentPath= [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"MergeVideo%li.MOV",(long)DicItems]];
    NSLog(@"myDocumentPath %@",myDocumentPath);
    urlVideo = [[NSURL alloc] initFileURLWithPath:myDocumentPath];
    NSLog(@"%li  urlVideo: %@",(long)DicItems,urlVideo);
    data123 = [NSData dataWithContentsOfURL:urlVideo];
    base64String = [data123 base64EncodedStringWithOptions:0];
    [arr1 addObject:base64String];
    NSURL *imageUrl = [[dict valueForKey:@"IQMediaAssetURL"]objectAtIndex:DicItems];
    AVURLAsset *asset=[[AVURLAsset alloc] initWithURL:imageUrl options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform=TRUE;
    CMTime thumbTime = CMTimeMakeWithSeconds(0,3);
    NSLog(@"Goods");
    AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
        if (result != AVAssetImageGeneratorSucceeded) {
            NSLog(@"couldn't generate thumbnail, error:%@", error);
        }
        UIImage *videoImage1=[UIImage imageWithCGImage:im];
        NSData *data = UIImagePNGRepresentation([UIImage imageWithCGImage:im]);
        CGSize newSize=CGSizeMake(60,60);
        UIGraphicsBeginImageContext(newSize);
        [videoImage1 drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        UIImage *thumbimage= UIGraphicsGetImageFromCurrentImageContext();
        NSData *imageDataThumb = UIImageJPEGRepresentation(thumbimage, 1);
        [Base64 initialize];
        NSString *imageStringThumb = [NSString stringWithFormat:@"%@",[Base64 encode:imageDataThumb]];
        [video_imageArr addObject:imageStringThumb];
        NSLog(@"fab lastly");
        if (DicItems == 0) {
            AllItems = arr1.count;
            [self MethodCounterCall];
        }
        else if (DicItems > 0)
        {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
            dispatch_async(queue, ^{

                [self convertVideoToMP4];
            });
        }
    };
    CGSize maxSize = CGSizeMake(50, 50);
    generator.maximumSize = maxSize;
    [generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:handler];
}



-(void)convertVideoToMP4
{
    
    [indicator startAnimating];
    int tempDic = (int)DicItems;
    DicItems = 0;
    DicItems = tempDic - 1;
    NSURL *url = [[dict valueForKey:@"IQMediaAssetURL"]objectAtIndex:DicItems];
    
    // Create the asset url with the video file
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    // Check if video is supported for conversion or not
    if ([compatiblePresets containsObject:AVAssetExportPresetLowQuality])
        
    {
        //Create Export session
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset presetName:AVAssetExportPresetLowQuality];
    
        NSString *documentsDirectory= [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString  *myDocumentPath= [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"MergeVideo%li.MOV",(long)DicItems]];
        NSLog(@"myDocumentPath %@",myDocumentPath);

        
        NSURL *url = [[NSURL alloc] initFileURLWithPath:myDocumentPath];
        //Check if the file already exists then remove the previous file
        if ([[NSFileManager defaultManager]fileExistsAtPath:myDocumentPath])
        {
            [[NSFileManager defaultManager]removeItemAtPath:myDocumentPath error:nil];
        }
        
        exportSession.outputURL = url;
        //set the output file format if you want to make it in other file format (ex .3gp)
        exportSession.outputFileType = AVFileTypeMPEG4;
        exportSession.shouldOptimizeForNetworkUse = YES;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            
            switch ([exportSession status])
            {
                case AVAssetExportSessionStatusFailed:
                {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        
                        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                        message:[[exportSession error] localizedDescription]
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles: nil];
                        [alert show];
                    });
                    break;
                }
                    
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Export canceled");
                    break;
                case AVAssetExportSessionStatusCompleted:
                {
                       [self insertVideo];
                    //Video conversion finished
                    NSLog(@"Successful!");
                }
                    break;
                default:
                    break;
            }
        }];
    }
    else
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Video file not supported."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
}
-(void)FinalCall
{
    NSError *error = nil;
    [indicator startAnimating];
    AVMutableComposition* composition;
    NSURL *urlVideo;
    NSString* myDocumentPath;
    int tempDic = (int)DicItems;
    DicItems = 0;
    DicItems = tempDic - 1;
    NSURL *url = [[dict valueForKey:@"IQMediaAssetURL"]objectAtIndex:DicItems];
    NSString* documentsDirectory= [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    myDocumentPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"MergeVideo%li.MOV",(long)DicItems]];
    NSLog(@"%@",myDocumentPath);
    NSData *data = [self getCroppedData:url];
    
    [data writeToFile:myDocumentPath atomically:YES];
    
    composition = [[AVMutableComposition alloc]init];
    AVURLAsset* video1 = [[AVURLAsset alloc]initWithURL:url options:nil];
     
    composition = [AVMutableComposition composition];
    AVMutableCompositionTrack* composedTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [composedTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, video1.duration)
                           ofTrack:[[video1 tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                            atTime:kCMTimeZero error:nil];
    AVMutableCompositionTrack* audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAssetTrack *audio = [[video1 tracksWithMediaType:AVMediaTypeAudio] firstObject];
    [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, video1.duration) ofTrack:audio atTime:kCMTimeZero error:nil];

    urlVideo = [[NSURL alloc] initFileURLWithPath:myDocumentPath];
    if([[NSFileManager defaultManager]fileExistsAtPath:myDocumentPath])
    {
        [[NSFileManager defaultManager]removeItemAtPath:myDocumentPath error:nil];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.status.hidden=NO;
        AVAssetExportSession*exporter = [[AVAssetExportSession alloc]initWithAsset:composition presetName:AVAssetExportPresetLowQuality];
        exporter.outputURL=urlVideo;
        exporter.outputFileType=@"com.apple.quicktime-movie";
        exporter.shouldOptimizeForNetworkUse=YES;
        [exporter exportAsynchronouslyWithCompletionHandler:^{
            self.status.hidden=NO;
            switch([exporter status])
            {
                case AVAssetExportSessionStatusFailed:
                {
                    self.introView.hidden=YES;
                    self.status.hidden=YES;
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error!" message:@"Faild to upload." preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                    [alertController addAction:ok];
                    [self presentViewController:alertController animated:YES completion:nil];
                    break;
                }
                case AVAssetExportSessionStatusCancelled:
                {
                    NSLog(@"Failed to export video");
                    self.introView.hidden=YES;
                    self.status.hidden=YES;
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error!" message:@"Uploading cancel" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                    [alertController addAction:ok];
                    [self presentViewController:alertController animated:YES completion:nil];
                    break;
                }   
                case AVAssetExportSessionStatusCompleted:
                {
                    self.status.hidden=NO;
                    NSLog(@"Merging completed");
                                     dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                    dispatch_async(queue, ^{
                         [self insertVideo];
                    });
                    break;
                }
                default:
                    break;
            }
            NSError* error;
            NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:myDocumentPath error: &error];
            NSNumber *size = [fileDictionary objectForKey:NSFileSize];
            NSLog(@"%@",size);
        }];
    });
}



- (void)updateLabelWhenBackgroundDone
{
    self.introView.hidden=YES;
    self.status.hidden=YES;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Completed!" message:@"Videos are uploaded successfully." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    [self presentViewController:alertController animated:YES completion:nil];
    [self allVideos];
    [self.photosCollectionVi reloadData];
}
-(void)MethodCounterCall
{
    if (AllItems == 0)
    {
        [self SendButton];
    }
    else
    {
        int tempadd = (int)AllItems;
        AllItems = 0;
        AllItems = tempadd -1;
        [self SendButton];
    }
}
-(void)SendButton
{
    if([[Reachability sharedReachability] internetConnectionStatus] == NotReachable){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Check Internet Connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }else{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *contact=[prefs valueForKey:@"contact"];
        NSString *urlString = [[NSString alloc]initWithFormat:@"%@add_video.php",app.Service ];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *myRequestString =[NSString stringWithFormat:@"{\"contact\":\"%@\",\"video_name\":\[\"%@\"],\"video_image\":\[\"%@\"]}",contact,[NSString stringWithFormat:@"%@",[arr1 objectAtIndex:AllItems]],[NSString stringWithFormat:@"%@",[video_imageArr objectAtIndex:AllItems]]];
    NSData *requestData = [NSData dataWithBytes:[myRequestString UTF8String] length:[myRequestString length]];
    [request setHTTPMethod: @"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody: requestData];
    [request setTimeoutInterval:300];
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
            
                                NSLog(@"add_video.php   ::::  %@",dictionary);
            
            if (!dictionary)
            {
                NSLog(@"%s: JSONObjectWithData error: %@; data = %@", __FUNCTION__, parseError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                return ;
            }
            else
            {
//              NSLog(@"%@",dictionary);
                if([[dictionary valueForKey:@"success"] isEqualToString:@"1"])
                {
                    [indicator stopAnimating];
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
                    if (AllItems != 0) {
                        [self MethodCounterCall];
                    }
                    if (AllItems == 0) {
                        self.status.hidden=YES;
                        NSArray *NewVideosARRCopy=[[dictionary valueForKey:@"posts"]valueForKey:@"video"];
                        NSArray *NewVideosImageArr=[[dictionary valueForKey:@"posts"]valueForKey:@"image"];
                        
                        for (int i=0;i<NewVideosARRCopy.count ; i++)
                        {
                            [app.VidesAllBackArr addObject:[NSString stringWithFormat:@"%@",[NewVideosARRCopy objectAtIndex:i]]];
                            [app.VidesImageAllBackArr addObject:[NSString stringWithFormat:@"%@",[NewVideosImageArr objectAtIndex:i]]];
                                                    }
                        self.photosCollectionVi.hidden=NO;
                        self.introView.hidden=YES;
                        [self.photosCollectionVi reloadData];
                        
                                      }
                }
                else
                {
                    [indicator stopAnimating];
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
                    self.status.hidden=YES;
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error!" message:@"Fail to upload multiple videos." preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                    [alertController addAction:ok];
                    [self presentViewController:alertController animated:YES completion:nil];
                    [self.photosCollectionVi reloadData];
                }
                
                resizearrayNo = (int)[videoURLCopy count];//
                newarrayNo = (int)[arr1 count];//
                videoURLCopy = [app.VidesAllBackArr copy];//
                ImgaesArr = [app.VidesImageAllBackArr copy];//
                totalarraySizeNo = resizearrayNo + newarrayNo;//
                videoURLCopy = [app.VidesAllBackArr copy];//
                [arr1 removeAllObjects];//
                if(DicItems != 0)//
                {//
                    DicItems = DicItems - 1;//
                    
                }//

            }
        }];
    }
}
-(void)mediaPickerControllerDidCancel:(IQMediaPickerController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"Cancelled");
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(videoUrl == NULL)
    {
        return ImgaesArr.count;
    }
    else if (videoUrl == NULL && videoURLCopy == NULL)
    {
        return 0;
    }
    else
    {
        return videoUrl.count;
    }
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

- (ImageCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[ImageCollectionViewCell reuseIdentifier] forIndexPath:indexPath];
    UIImageView *recipeImageView = (UIImageView *)[cell viewWithTag:100];

    NSURL *imageUrl =[NSURL URLWithString:[NSString stringWithFormat:@"%@",[videoURLCopy objectAtIndex:indexPath.row]]];
    
    AVURLAsset *asset1 = [[AVURLAsset alloc] initWithURL:imageUrl options:nil];
    AVAssetImageGenerator *generate1 = [[AVAssetImageGenerator alloc] initWithAsset:asset1];
    generate1.appliesPreferredTrackTransform = YES;
    NSError *err = NULL;
    CMTime time = CMTimeMake(1, 2);
    CGImageRef oneRef = [generate1 copyCGImageAtTime:time actualTime:NULL error:&err];
    UIImage *one = [[UIImage alloc] initWithCGImage:oneRef];
    NSData *imageDataThumb = UIImageJPEGRepresentation(one, 1);
    recipeImageView.image=[UIImage imageWithData:imageDataThumb];
    return cell;
}
-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    int i=(int)indexPath.row;
    app.SelImgId=[NSString stringWithFormat:@"%i",i];
    UICollectionViewCell* cell =
    [self.photosCollectionVi cellForItemAtIndexPath:indexPath];
    
    UIImageView *CheckedmarkImgView= (UIImageView *)[cell viewWithTag:1];
    CheckedmarkImgView.hidden=YES;
    if(videoUrl == NULL)
    {
        NSString *videoURL =[NSString stringWithFormat:@"%@",[videoURLCopy objectAtIndex:   indexPath.row]];

        NSURL *videos=[NSURL URLWithString:videoURL];
        self.moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:videos];
        self.moviePlayerController.movieSourceType = MPMovieSourceTypeFile;
        self.moviePlayerController.backgroundView.backgroundColor  = [UIColor lightGrayColor] ;
        [self.view addSubview:self.moviePlayerController.view];
        self.moviePlayerController.fullscreen = YES;
        [self.moviePlayerController play];
    }
    else
    {
        NSString *videoURL =[NSString stringWithFormat:@"%@",[videoUrl objectAtIndex:indexPath.row]];
        NSURL *videos=[NSURL URLWithString:videoURL];
        
        
        self.moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:videos];
        self.moviePlayerController.movieSourceType = MPMovieSourceTypeFile;
        self.moviePlayerController.backgroundView.backgroundColor  = [UIColor lightGrayColor] ;
        [self.view addSubview:self.moviePlayerController.view];
        self.moviePlayerController.fullscreen = YES;
        [self.moviePlayerController play];
    }
   
//    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(activateDeletionMode:)];
//    longPress.delegate = self;
//    [self.photosCollectionVi addGestureRecognizer:longPress];
    
    
}

//- (void)activateDeletionMode:(UILongPressGestureRecognizer *)gr
//{
//    CGPoint p = [gr locationInView:self.photosCollectionVi];
//    
//        NSIndexPath *indexPath = [self.photosCollectionVi indexPathForItemAtPoint:p];
//
//    UICollectionViewCell* cell =
//            [self.photosCollectionVi cellForItemAtIndexPath:indexPath];
//    
//    NSString *name = [NSString stringWithFormat:@"%@",[videoURLCopy objectAtIndex:indexPath.row]];
//    NSArray *items = [name componentsSeparatedByString:@"/"];
//    NSString *ImageName = [items lastObject];
//    NSLog(@"Video Name : %@",ImageName);
//            cell.layer.borderWidth=3.0f;
//            cell.layer.borderColor=[UIColor blackColor].CGColor;
//    
//
//
//    if (gr.state == UIGestureRecognizerStateBegan)
//    {
//        NSLog(@"delete mode");
//    }
//}
- (IBAction)show:(id)sender
{
    [self.sidebarVC showHideSidebar];
}
- (void)panDetected:(UIPanGestureRecognizer*)recoginzer
{
    [self.sidebarVC panDetected:recoginzer];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
//-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
//{
//    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
//        return;
//    }
//    CGPoint p = [gestureRecognizer locationInView:self.photosCollectionVi];
//    
//    NSIndexPath *indexPath = [self.photosCollectionVi indexPathForItemAtPoint:p];
//    if (indexPath == nil){
//        NSLog(@"couldn't find index path");
//    }
//    else
//    {
//        // get the cell at indexPath (the one you long pressed)
//        UICollectionViewCell* cell =
//        [self.photosCollectionVi cellForItemAtIndexPath:indexPath];
//        cell.layer.borderWidth=1.0f;
//        cell.layer.borderColor=[UIColor blackColor].CGColor;
//
//    }
//}
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
