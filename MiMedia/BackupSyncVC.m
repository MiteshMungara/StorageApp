//
//  BackupSyncVC.m
//  Flippy Cloud
//
//  Created by iSquare5 on 14/09/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import "BackupSyncVC.h"
#import "IntroVC.h"
#import <Photos/Photos.h>
#import "Base64.h"
#import "AssetsDataIsInaccessibleViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "AppDelegate.h"
#import <Contacts/Contacts.h>
typedef void (^ALAssetsLibraryAssetForURLResultBlock)(ALAsset *asset);
typedef void (^ALAssetsLibraryAccessFailureBlock)(NSError *error);
@interface BackupSyncVC ()
{
    AppDelegate *app;
    NSArray *ImagesArry,*ItemsName,*CheckUncheckBtn;
    int index;
    NSString *status;
    NSMutableArray *arr,*arr1;
    NSString *strEncoded,*ImageBtnName,*ContactBtnName;
    NSUInteger total;
    NSString *orgFilename;
    NSMutableArray *imagesAllArray;
    NSInteger AllItems;
    NSDictionary *dict;
    NSURL  *url;
    NSInteger DicItems,TotalCount,noItem;
    int a,b;
    NSMutableArray *contactno,*firstname,*lastname,*emailARR,*phoneno;
    NSString *statusContact,*phoneNumber,*CoEmail,*FirstnameStr,*LastnameStr, *LocalPath;
    NSInteger CurrentItemNo,totalitemcount;
    NSMutableArray *totalItemArr;
}
@end

BOOL dwView = NO;
BOOL tabletaped = YES;
int indexcount=0;

@implementation BackupSyncVC
@synthesize assARR,assGroupps,assLibrary,grPss;

-(void)viewDidLoad
{
    [super viewDidLoad];
    app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    b=0;
    self.imageManager = [[PHCachingImageManager alloc] init];
    self.assetsFetchResults = [PHAsset fetchAssetsWithOptions:nil];
    arr =[[NSMutableArray alloc]init];
}
-(IBAction)backBtnPressed:(id)sender
{
     [self.navigationController popViewControllerAnimated:YES];
}
-(IBAction)PhotosBtnPressed:(id)sender
{
    if([self.PhotosBtn isSelected])
    {
        NSLog(@"no");
        ImageBtnName =@"";
        [sender setSelected:NO];
    }
    else
    {
        NSLog(@"yes");
        ImageBtnName =@"photos";
        [sender setSelected:YES];
    }
}

-(IBAction)ContactAllBtnPressed:(id)sender
{
    if([self.ContactBtn isSelected])
    {
        NSLog(@"no");
        ContactBtnName =@"";
        [sender setSelected:NO];
    }
    else
    {
         [sender setSelected:YES];
        ContactBtnName =@"contact";
        
    }
}
-(void)SendContacts
{
//  BtnName =@"contact";
//  åååååååååååååååååååååå   contact getting start   ååååååååååååååååååå
    contactno = [[NSMutableArray alloc]init];
    firstname = [[NSMutableArray alloc]init];
    lastname= [[NSMutableArray alloc]init];
    emailARR = [[NSMutableArray alloc]init];
    phoneno =[[NSMutableArray alloc]init];
    CNAuthorizationStatus status1 = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if( status1 == CNAuthorizationStatusDenied || status1 == CNAuthorizationStatusRestricted)
    {
        NSLog(@"access denied");
    }
    else
    {
        CNContactStore *contactStore = [[CNContactStore alloc] init];
        NSArray *keys = @[CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPhoneNumbersKey, CNContactImageDataKey,CNContactEmailAddressesKey];
        CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:keys];
        request.predicate = nil;
        [contactStore enumerateContactsWithFetchRequest:request
                                                  error:nil
                                             usingBlock:^(CNContact* __nonnull contact, BOOL* __nonnull stop)
         {
             phoneNumber = @"";
             if( contact.phoneNumbers)
                 phoneNumber = [[[contact.phoneNumbers firstObject] value] stringValue];
             FirstnameStr=contact.givenName;
             LastnameStr=contact.familyName;
             CoEmail = [[contact.emailAddresses valueForKey:@"value"] lastObject];
             if(CoEmail==nil)
             {
                 CoEmail=@"";
             }
             else
             {
                 NSMutableArray *ContactEmails=[[NSMutableArray alloc]init];
                 [ContactEmails addObject:CoEmail];
                 NSLog(@"ContactEmails : %@    FirstName:::  %@,LastName::: %@, CoEmail :::  %@, Phone::: %@",ContactEmails,FirstnameStr,LastnameStr,CoEmail,phoneNumber);
                 [self SaveContactList];
             }
         }];
    }
}
-(void)SaveContactList
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *email=[prefs valueForKey:@"email"];
    NSString *contact=[prefs valueForKey:@"contact"];
    NSString *urlString = [[NSString alloc]initWithFormat:@"%@contact_list.php",app.Service ];
    NSURL *url1 = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url1];
    NSString *myRequestString =[NSString stringWithFormat:@"{\"family_name\":\"%@\",\"given_name\":\"%@\",\"user_email\":\"%@\",\"user_contact\":\"%@\",\"phone_no\":\"%@\"}",FirstnameStr,LastnameStr,email,contact,phoneNumber];
    NSData *requestData = [NSData dataWithBytes:[myRequestString UTF8String] length:[myRequestString length]];
    [request setHTTPMethod: @"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody: requestData];
    NSError *error;
    NSURLResponse *response;
    NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingAllowFragments error:nil];
    NSLog(@"Contact Responce :  %@",jsonDictionary);
}
//åååååååååååååååååååååå   contact getting stop  ååååååååååååååååååå


-(IBAction)SelectAllBtnPressed:(id)sender
{
    if([self.SelectallBtn isSelected])
    {
        [self.PhotosBtn setSelected:NO];
        [self.ContactBtn setSelected:NO];
        ImageBtnName=@"";
        ContactBtnName=@"";
        [sender setSelected:NO];
    }
    else
    {
        ImageBtnName=@"photos";
        ContactBtnName=@"contact";
        [self.PhotosBtn setSelected:YES];
        [self.ContactBtn setSelected:YES];
        [sender setSelected:YES];
    }
}
-(IBAction)BackUpBtnPressed:(id)sender
{
    if([ImageBtnName isEqualToString:@"photos"])
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            
            dispatch_async(dispatch_get_main_queue(), ^
                           {
                               [self PrepareImagesToSend];
                           });
        });
        

        
    }
    if([ContactBtnName isEqualToString:@"contact"])
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            
            dispatch_async(dispatch_get_main_queue(), ^
                           {
                               [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(SendContacts) userInfo:nil repeats:NO];
                           });
        });
        
    }

}
-(void)PrepareImagesToSend
{
    for (int i=0; i<self.assetsFetchResults.count; i++)
    {
        [self.imageManager requestImageDataForAsset:self.assetsFetchResults[i]
                                            options:nil
                                      resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info)
         {
             UIImage *image = [UIImage imageWithData:imageData];
             UIImageView* imgView =[[UIImageView alloc]init];
             imgView.image=image;
             NSData *imagedata = UIImageJPEGRepresentation(imgView.image, 0.25);
             strEncoded = [NSString stringWithFormat:@"%@",[Base64 encode:imagedata]];
             PHAsset *asset= [self.assetsFetchResults objectAtIndex:i];
             NSArray *resources = [PHAssetResource assetResourcesForAsset:asset];
             orgFilename = ((PHAssetResource*)resources[0]).originalFilename;
             NSLog(@"  orgFilename  :  %@",orgFilename);
             [self sendData];
         }];
    }

}
-(void)sendData
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *email=[prefs valueForKey:@"email"];
    NSString *contact=[prefs valueForKey:@"contact"];
    NSString *urlStr = [[NSString alloc]initWithFormat:@"%@upload_image.php",app.Service ];
    NSURL *url1 = [NSURL URLWithString:[NSString stringWithFormat:@"%@",urlStr]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url1];
    NSString *myRequestString =[NSString stringWithFormat:@"{\"email\":\"%@\",\"contact\":\"%@\",\"image_name\":\"%@\",\"image\":\"%@\"}",email,contact,orgFilename,strEncoded];
    NSData *requestData = [NSData dataWithBytes:[myRequestString UTF8String] length:[myRequestString length]];
    [request setTimeoutInterval:300];
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
        if (!dictionary)
        {
            NSLog(@"%s: JSONObjectWithData error: %@; data = %@", __FUNCTION__, parseError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            return ;
        }
        else
        {
            NSLog(@"Backup Responce : %@",dictionary);
        }
    }];
}

#pragma Videos Sync while backup btn tapped
-(void)VideosSyncGet
{
    NSData * cpdata =[[NSUserDefaults standardUserDefaults]valueForKey:@"cameraImageKey"];
    photoImageVis.image = [UIImage imageWithData:cpdata];
    dwView = NO;
    indexcount=0;
    photoViewss.frame=CGRectMake(0, 0, screenBounds.size.width, screenBounds.size.height-100);
    acViews.frame=CGRectMake(-screenBounds.size.width, photoViewss.frame.size.height, screenBounds.size.width, screenBounds.size.height-photoViewss.frame.size.height);
    bcViews.frame=CGRectMake(0, 60, screenBounds.size.width, screenBounds.size.height-photoViewss.frame.size.height);
    if (assLibrary == nil) {
        assLibrary = [[ALAssetsLibrary alloc] init];
    }
    if (grPss == nil) {
        grPss = [[NSMutableArray alloc] init];
    } else {
        [grPss removeAllObjects];
    }
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        AssetsDataIsInaccessibleViewController *assetsDataInaccessibleViewController =
        [self.storyboard instantiateViewControllerWithIdentifier:@"inaccessibleViewController"];
        NSString *errorMessage = nil;
        switch ([error code]) {
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
            [grPss insertObject:group atIndex:0];
            tabletaped = YES;
            if (grPss.count > 0)
            {
                self.assGroupps = grPss[0];
                if (!assARR) {
                    assARR = [[NSMutableArray alloc] init];
                } else {
                    [assARR removeAllObjects];
                }
                ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    if (result) {
                        [assARR insertObject:result.defaultRepresentation.url atIndex:0];
                    }
                };
                ALAssetsFilter *onlyPhotosFilter2 = [ALAssetsFilter allVideos];
                [assGroupps setAssetsFilter:onlyPhotosFilter2];
                [assGroupps enumerateAssetsUsingBlock:assetsEnumerationBlock];
                [photosCollectionVis reloadData];
            }
        }
        else
        {
            for (int i=0; i<self.assARR.count; i++)
            {
                url=[NSURL URLWithString:[NSString stringWithFormat:@"%@",[assARR objectAtIndex:i]]];
                imagesAllArray = [[NSMutableArray alloc]init];
                DicItems = dict.count;
//                [self VideosArray];
                int c=(int)self.assARR.count;
                if(a   < c)
                {
                    NSLog(@"A :%i  < C:%i",a,c);
//                    [self FinallyCalled];
                }
            }
            totalItemArr = [[NSMutableArray alloc]init];
            totalItemArr = [NSMutableArray arrayWithArray:assARR];
            totalitemcount = (int)assARR.count;
            CurrentItemNo = 0;
            [self UploadFile];
        }
    };
    NSUInteger groupTypes = ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces | ALAssetsGroupSavedPhotos ;
    [self.assLibrary enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock failureBlock:failureBlock];
}

-(void)UploadFile
{
    if (totalitemcount != 0)
    {
        [self FinallyCalled];
    }
}
-(void)FinallyCalled
{
      url=[NSURL URLWithString:[NSString stringWithFormat:@"%@",[totalItemArr objectAtIndex:CurrentItemNo]]];
        NSLog(@"b :%i",b);
        DicItems = dict.count;//4
        AVMutableComposition* composition;
        NSString* myDocumentPath;
        int tempDic = (int)DicItems;
        DicItems = 0;
        tempDic = (int)DicItems +1;
        composition = [[AVMutableComposition alloc]init];
        AVURLAsset* video1 = [[AVURLAsset alloc]initWithURL:url options:nil];
        AVMutableCompositionTrack* composedTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [composedTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, video1.duration)
        ofTrack:[[video1 tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
        atTime:kCMTimeZero error:nil];
        NSString *documentsDirectory= [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        myDocumentPath= [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"MergeVideo%d.MOV",a]];
        LocalPath = [NSString stringWithFormat:@"%@",myDocumentPath];
        NSError *error;
        NSData *fileData = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@",myDocumentPath] options:0 error:&error];
        if (fileData == nil)
        {
            NSLog(@"Failed to read file, error %@", error);
        }
        else
        {
            NSLog(@"start uploading");
            [self SaveVideos];
        }
/*   ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
//    [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset)
//                               {
//                                   ALAssetRepresentation *rep = [asset defaultRepresentation];
//                                   Byte *buffer = (Byte*)malloc(rep.size);
//                                   NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
//                             }
//       failureBlock:^(NSError *err) {
//           NSLog(@"Error: %@",[err localizedDescription]);
//       }];
//    NSURL *VideoDocUrl=[NSURL URLWithString:[NSString stringWithFormat:@"%@",url]];
//    NSData *VideoDocData = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@",VideoDocUrl]];
//    
//     ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
//    {
//        ALAssetRepresentation *rep = [myasset defaultRepresentation];
//              rep = [myasset defaultRepresentation];
//                Byte *buffer = (Byte*)malloc((NSUInteger)rep.size);
//                NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:(NSUInteger)rep.size error:nil];
//                NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
//            NSLog(@"%@",data);
//    };
//    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
//    {
//        NSLog(@"Can't get image - %@",[myerror localizedDescription]);
//    };
//    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
//    [assetslibrary assetForURL:url resultBlock:resultblock failureBlock:failureblock];

    
    
    
    
    
    //   // NSString *docPath = [NSSearchPathForDirectoriesInDomains
//                    //     (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//  //  NSString *path1 = [docPath stringByAppendingPathComponent:@"/video1.MOV"];
//    composition = [[AVMutableComposition alloc]init];
//    //Create assests url for first video
//    AVURLAsset* video1 = [[AVURLAsset alloc]initWithURL:url options:nil];
//    //Create assests url for second video
//    AVMutableCompositionTrack* composedTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
//    [composedTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, video1.duration)
//                           ofTrack:[[video1 tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
//                            atTime:kCMTimeZero error:nil];
//    // Create a temp path to save the video in the documents dir.
//    NSString* documentsDirectory= [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    NSString* myDocumentPath= [documentsDirectory stringByAppendingPathComponent:@"MergeVideo.MOV"];
//    NSLog(@"myDocumentPath %@",myDocumentPath);
//   // NSURL *LocalPathUrl = [[NSURL alloc] initFileURLWithPath: myDocumentPath];
//    LocalPath = [NSString stringWithFormat:@"%@",myDocumentPath];
//    //Check if the file exists then delete the old file to save the merged video file.
//    if([[NSFileManager defaultManager]fileExistsAtPath:myDocumentPath])
//    {
//        [[NSFileManager defaultManager]removeItemAtPath:myDocumentPath error:nil];
//    }
//    // Create the export session to merge and save the video
//    AVAssetExportSession*exporter = [[AVAssetExportSession alloc]initWithAsset:composition presetName:AVAssetExportPresetLowQuality];
//    exporter.outputURL=url;
//    exporter.outputFileType=@"com.apple.quicktime-movie";
//    exporter.shouldOptimizeForNetworkUse=YES;
//    [exporter exportAsynchronouslyWithCompletionHandler:^{
//        switch([exporter status])
//        {
//            case AVAssetExportSessionStatusFailed:
//                NSLog(@"Failed to export video");
//                break;
//            case AVAssetExportSessionStatusCancelled:
//                NSLog(@"export cancelled");
//                break;
//            case AVAssetExportSessionStatusCompleted:
//                //Here you go you have got the merged video :)
//                //[self playVideo1];
//                [self SaveVideos];
//                NSLog(@"Merging completed");
//                break;
//            default:
//                break;
//        }
//        NSError* error;
//        NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:myDocumentPath error: &error];
//        NSNumber *size = [fileDictionary objectForKey:NSFileSize];
//        NSLog(@"%@",size);
//    }];
//                 a=a+1;*/
}
/////////////////////   videos complete   //////////////////////////


-(void)SaveVideos
{
    NSString *base64String;
    NSError *error;
    NSURL *LocalPathUrl = [[NSURL alloc] initFileURLWithPath: LocalPath];
    NSData *Filedata =[NSData dataWithContentsOfURL:LocalPathUrl options:0 error:&error];
    base64String = [Filedata base64EncodedStringWithOptions:0];
    [arr addObject:base64String];
    NSString *videoName=[NSString stringWithFormat:@"video%i.mp4",a];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *email=[prefs valueForKey:@"email"];
    NSString *contact=[prefs valueForKey:@"contact"];
    NSString *urlString = [[NSString alloc]initWithFormat:@"%@upload_video.php",app.Service ];
    NSURL *url1 = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url1];
    NSString *myRequestString =[NSString stringWithFormat:@"{\"email\":\"%@\",\"contact\":\"%@\",\"video\":\"%@\",\"video_name\":\"%@\"}",email,contact,[arr objectAtIndex:a],videoName];
    NSData *requestData = [NSData dataWithBytes:[myRequestString UTF8String] length:[myRequestString length]];
    [request setHTTPMethod: @"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody: requestData];
    [request setTimeoutInterval:300];
    NSURLResponse *response;
    NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingAllowFragments error:nil];
    
    NSLog(@"***************************************** json : %@",jsonDictionary);

    if([[jsonDictionary valueForKey:@"success"] isEqualToString:@"1"])
    {
        b=b+1;
        a=b;
        if (totalItemArr.count != 0)
        {
            [totalItemArr removeObjectAtIndex:CurrentItemNo];
            totalitemcount = totalitemcount - 1;
            [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(UploadFile) userInfo:nil repeats:NO];
        }
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Uploaded" message:@"Uploaded SuccessFully" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

-(IBAction)BtnPressed:(id)sender
{
    
}
/*-(void)FinalCall
{
AVMutableComposition* composition;
NSURL *urlVideo;
NSString* myDocumentPath;
int tempDic = (int)DicItems;
DicItems = 0;
    tempDic = (int)DicItems +1;
    composition = [[AVMutableComposition alloc]init];
    AVURLAsset* video1 = [[AVURLAsset alloc]initWithURL:url options:nil];
    AVMutableCompositionTrack* composedTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [composedTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, video1.duration)
                           ofTrack:[[video1 tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                            atTime:kCMTimeZero error:nil];
    NSString *documentsDirectory= [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    myDocumentPath= [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"MergeVideo%i.MOV",a]];
    NSLog(@"myDocumentPath %@",myDocumentPath);
    urlVideo = [[NSURL alloc] initFileURLWithPath:myDocumentPath];
    NSLog(@"%i  urlVideo: %@",a,urlVideo);

    [self insertVideo];
}
- (void)updateLabelWhenBackgroundDone
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Completed!" message:@"Videos are uploaded successfully." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    [self presentViewController:alertController animated:YES completion:nil];
}
-(void)insertVideo
{
    NSData *data123;
    NSString *base64String;//,*documentsDirectory;
    //    NSURL *vedioURL;
    NSString* myDocumentPath;
    NSURL *urlVideo;
    NSString *documentsDirectory= [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    myDocumentPath= [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"MergeVideo%li.MOV",(long)DicItems]];
    NSLog(@"myDocumentPath %@",myDocumentPath);
    urlVideo = [[NSURL alloc] initFileURLWithPath:myDocumentPath];
    NSLog(@"%li  urlVideo: %@",(long)DicItems,urlVideo);
    data123 = [NSData dataWithContentsOfURL:urlVideo];
    base64String = [data123 base64EncodedStringWithOptions:0];
    [arr addObject:base64String];
    AVURLAsset *asset=[[AVURLAsset alloc] initWithURL:urlVideo options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform=TRUE;
    CMTime thumbTime = CMTimeMakeWithSeconds(0,5);
    NSLog(@"Goods");
    AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
        if (result != AVAssetImageGeneratorSucceeded) {
            NSLog(@"couldn't generate thumbnail, error:%@", error);
        }
        UIImage *videoImage=[UIImage imageWithCGImage:im];
        CGSize newSize=CGSizeMake(60,60); // I am giving resolution 50*50 , you can change your need
        UIGraphicsBeginImageContext(newSize);
        [videoImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        UIImage *thumbimage= UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        //        Convert into Base64 image...
        NSData *imageDataThumb = UIImageJPEGRepresentation(thumbimage, 1);
        [Base64 initialize];
        NSString *imageStringThumb = [NSString stringWithFormat:@"%@",[Base64 encode:imageDataThumb]];
        [arr1 addObject:imageStringThumb];
        //        [videoImageArryCopy addObject:videoImage];
        NSLog(@"fab lastly");
        //  [self FinalCall];
        if (DicItems == 0) {
//            AllItems = arr1.count;
        NSLog(@"insertVideo %i",a);
            [self MethodCounterCall];
        }
        else if (DicItems > 0)
        {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
            dispatch_async(queue, ^{
                [self MethodCounterCall];
            });
        }
    };
    CGSize maxSize = CGSizeMake(20, 20);
    generator.maximumSize = maxSize;
    [generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:handler];
//    NSLog(@"array count : %lu",(unsigned long)arr1.count);
}
-(void)MethodCounterCall
{
    NSLog(@"MethodCounterCall %i",a);
    if (AllItems == 0) {
       [self sendData];
    }
    else
    {
        int tempadd = (int)AllItems;
        AllItems = 0;
        AllItems = tempadd -1;
        [self sendData];
    }
}

-(void)sendData
{
    NSLog(@"sendData %i",a);
    if(a<self.assARR.count)
    {
     
        NSString *videoName=[NSString stringWithFormat:@"video%i.mp4",a];
        
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSString *email=[prefs valueForKey:@"email"];
            NSString *contact=[prefs valueForKey:@"contact"];
        
            NSString *urlString = [[NSString alloc]initWithFormat:@"%@upload_video.php",app.Service ];
            NSURL *url = [NSURL URLWithString:urlString];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            //            fav_id"image_name":"IMG_0001.JPG"
            NSString *myRequestString =[NSString stringWithFormat:@"{\"email\":\"%@\",\"contact\":\"%@\",\"video\":\"%@\",\"video_name\":\"%@\"}",email,contact,[arr objectAtIndex:a],videoName];
        
            NSData *requestData = [NSData dataWithBytes:[myRequestString UTF8String] length:[myRequestString length]];
            [request setHTTPMethod: @"POST"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody: requestData];
            [request setTimeoutInterval:300];
            NSError *error;
            NSURLResponse *response;
            NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"***************************************** \json : %@",jsonDictionary);
        if([[jsonDictionary valueForKey:@"success"] isEqualToString:@"1"])
        {
               a=a+1;
            [self VideosArray];

        }
        else
        {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"uploaded!" message:@"Uploading successFully" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            [self presentViewController:alertController animated:YES completion:nil];
            
        }

    }
    else
    {
        NSLog(@"asd");
    }
  
   
}*/

- (void)didReceiveMemoryWarning {
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
