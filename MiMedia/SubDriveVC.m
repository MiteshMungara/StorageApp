//
//  SubDriveVC.m
//  Flippy Cloud
//
//  Created by isquare3 on 11/23/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import "SubDriveVC.h"
#import "DriveVc.h"
#import "AppDelegate.h"
#import "ImageViewVC.h"
#import "AsyncImageView.h"
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
#import <Contacts/Contacts.h>
#import <MessageUI/MessageUI.h>
#import "InvitationVC.h"
#define DEGREES_TO_RADIANS(degrees)((M_PI * degrees)/180)

@interface SubDriveVC ()<IQMediaPickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UIGestureRecognizerDelegate,MFMessageComposeViewControllerDelegate>

{
    AppDelegate *app;
    NSMutableArray *ChatStrsArr;
    NSString *Messagetext;
    NSMutableArray *commentArr,*emailArr;
    NSArray *imageCollArr,*CollImageArr,*TypeArr,*OriginalLink;
    NSMutableArray *ImgArr1,*imagePath;
    UIActivityIndicatorView *indicator;
    NSMutableArray *allImageUploadArr;
    UIImage *images;
    NSData *decodedData;
    NSInteger resizearrayNo, newarrayNo, totalarraySizeNo;
    NSString *strEncoded,*cameraStatus,*actionItemStr;
    NSInteger remove,index,UploadTotalItemCount;
    NSTimer *timer;
    NSIndexPath *indexPathForDelete ;
    NSString *ItemNameStr,*VideoThumNameStr,*DriveStatusStr,*InfoStr;
    //add multiple videos
    NSDictionary *mediaInfo;
    NSDictionary *dict;
    NSMutableArray *imagesAllArray;
    NSInteger DicItems,TotalCount,noItem;
    NSMutableArray *arr1,*multiVideos,*arr2,*videoImageArryCopy, *videoImageArryCopy2,*video_imageArr;
    NSInteger AllItems;
    UIRefreshControl   *refreshControl;
    NSArray *videoUrl,*videoURLCopy,*infoArry,*videoImageArry,*ImgaesArr;
    NSMutableArray* differentIndex,*RemainingContacts;
    //Contact
    NSString *statusContact,*phoneNumber,*CoEmail,*FirstnameStr,*LastnameStr, *LocalPath,*CollectionName,*ContactToSendMsg;
    NSMutableArray *contactno,*firstname,*lastname,*emailARR,*phoneno,*ContactEmails,*InvitedEmailArr,*CoverImageARR,*FullNameArr;
    NSMutableArray *selectedContacts,*SharedEmailIDArr,*SelectMobileNo,*Demo;
    NSDictionary *ContactDic;
    UITableViewCell * Tcell;
}

@end
int countIndexedd=0;
@implementation SubDriveVC
@synthesize chatTableV;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initPB];
    app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    PhotoCollectionView.hidden=YES;
    MainCommentView.hidden=YES;
    SettingView.hidden=YES;
    ContactDic=[[NSDictionary alloc]init];
    differentIndex = [[NSMutableArray alloc] init];
    RemainingContacts =[[NSMutableArray alloc]init];
    commentArr = [[NSMutableArray alloc]init];
    emailArr = [[NSMutableArray alloc]init];
    arr1=[[NSMutableArray alloc]init];
    video_imageArr=[[NSMutableArray alloc]init];
    Demo=[[NSMutableArray alloc]init];

    screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat width = [UIScreen mainScreen].bounds.size.width;

    self.chatTableV.frame = CGRectMake(0, self.view.frame.origin.y + 10, width,(self.view.frame.size.height +20)-commentView.frame.size.height);
    [self setUpTextFieldforIphone];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChangeOpen:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.chatTableV addGestureRecognizer:gestureRecognizer];
    
    UILongPressGestureRecognizer *lpgr
    = [[UILongPressGestureRecognizer alloc]
       initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.delegate = self;
    lpgr.delaysTouchesBegan = YES;
    [photosCollectionCV addGestureRecognizer:lpgr];
    
    refreshControl = [[UIRefreshControl alloc]init];
    [photosCollectionCV addSubview:refreshControl];//EmailTableView
        [self.EmailTableView addSubview:refreshControl];//
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
}
- (void)refreshTable
{
    [refreshControl endRefreshing];
    [photosCollectionCV reloadData];
     CollectionName =@"contact";
    [self.EmailTableView reloadData];
}
-(IBAction)InviteBtnPressed:(id)sender
{
    UINavigationController *navigationController = (UINavigationController *)app.window.rootViewController;
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    InvitationVC *Listroute = (InvitationVC *)[mainStoryboard instantiateViewControllerWithIdentifier: @"InvitationVC"];
    [navigationController pushViewController:Listroute animated:YES];
}
-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded)
    {
        UICollectionViewCell* cell =
        [photosCollectionCV cellForItemAtIndexPath:indexPathForDelete];
        UIImageView *CheckedmarkImgView= (UIImageView *)[cell viewWithTag:1];
        CheckedmarkImgView.hidden=YES;
        self.DeleteVideosBtn.hidden=YES;
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            cell.transform = CGAffineTransformMakeScale(1,1);
        } completion:^(BOOL finished){
        }];
        return;
    }
    CGPoint p = [gestureRecognizer locationInView:photosCollectionCV];
    
    indexPathForDelete = [photosCollectionCV indexPathForItemAtPoint:p];
    if (indexPathForDelete == nil)
    {
        NSLog(@"couldn't find index path");
    }
    else
    {
        UICollectionViewCell* cell =
        [photosCollectionCV cellForItemAtIndexPath:indexPathForDelete];
        UIImageView *CheckedmarkImgView= (UIImageView *)[cell viewWithTag:1];
        CheckedmarkImgView.hidden=NO;
        self.DeleteVideosBtn.hidden=NO;
        NSString *SeletedItemName =[NSString stringWithFormat:@"%@",[OriginalLink objectAtIndex:indexPathForDelete.row]];
        NSArray *SelectedItem = [SeletedItemName componentsSeparatedByString:@"/"];
        NSLog(@"%@",[NSString stringWithFormat:@"%@",[SelectedItem lastObject]]);
        ItemNameStr=[NSString stringWithFormat:@"%@",[SelectedItem lastObject]];
        cell.backgroundColor= [UIColor lightGrayColor];
    }
}
-(IBAction)DeleteAVideosBtnPressed:(id)sender
{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"Are you sure you want to Delete this item? It will be removed from the cloud." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                         {
                             NSString *TypeUrl=[NSString stringWithFormat:@"%@",[TypeArr objectAtIndex:indexPathForDelete.row]];
                             if([TypeUrl isEqualToString:@"image"])
                             {
                                 [indicator startAnimating];
                                 [self DeleteImageFun];
                                 NSLog(@"imageDelete");
                             }
                             else
                             {
                                 [indicator startAnimating];
                                 [self DeleteVideoFun];
                                 NSLog(@"VideosDelete");
                             }

                         }];
    UIAlertAction* cancle = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action)
                             {
                                 
                             }];
    [alertController addAction:ok];
    [alertController addAction:cancle];
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}
-(void)DeleteVideoFun
{
    [indicator startAnimating];
    if([[Reachability sharedReachability] internetConnectionStatus] == NotReachable)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Check Internet Connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
    else
    {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *email=[prefs valueForKey:@"email"];
        NSString *contact=[prefs valueForKey:@"contact"];
        NSString *urlString = [[NSString alloc]initWithFormat:@"%@delete_from_drive_video.php",app.Service ];
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSString *myRequestString;
        if([app.DriveStatusStr isEqualToString:@"1"])
        {
            DriveStatusStr=[NSString stringWithFormat:@"shared"];
            myRequestString =[NSString stringWithFormat:@"{\"drive_name\":\"%@\",\"video_name\":\"%@\",\"email\":\"%@\",\"drive_status\":\"%@\"}",app.superDriveName,ItemNameStr,email,DriveStatusStr];
        }
        else
        {
            DriveStatusStr=[NSString stringWithFormat:@""];
            myRequestString =[NSString stringWithFormat:@"{\"drive_name\":\"%@\",\"video_name\":\"%@\",\"email\":\"%@\",\"drive_status\":\"%@\",\"contact\":\"%@\"}",app.superDriveName,ItemNameStr,email,DriveStatusStr,contact];
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
            [indicator startAnimating];
            NSLog(@"DeleteCollectionImage  ::::  %@",dictionary);
            if (!dictionary)
            {
                NSLog(@"%s: JSONObjectWithData error: %@; data = %@", __FUNCTION__, parseError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                return ;
            }
            else
            {
                UICollectionViewCell* cell =
                [photosCollectionCV cellForItemAtIndexPath:indexPathForDelete];
                UIImageView *CheckedmarkImgView= (UIImageView *)[cell viewWithTag:1];
                CheckedmarkImgView.hidden=YES;
                        self.DeleteVideosBtn.hidden=YES;
                [indicator startAnimating];
                [self DriveVC];
            }
        }];
    }
}
-(void)DeleteImageFun
{
    [indicator startAnimating];
    if([[Reachability sharedReachability] internetConnectionStatus] == NotReachable)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Check Internet Connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
    else
    {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *contact=[prefs valueForKey:@"contact"];
        NSString *urlString = [[NSString alloc]initWithFormat:@"%@delete_images.php",app.Service ];
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSString *myRequestString =[NSString stringWithFormat:@"{\"contact\":\"%@\",\"image_name\":\"%@\"}",contact,ItemNameStr];
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
            [indicator startAnimating];
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
                [indicator startAnimating];
                UICollectionViewCell* cell =
                [photosCollectionCV cellForItemAtIndexPath:indexPathForDelete];
                UIImageView *CheckedmarkImgView= (UIImageView *)[cell viewWithTag:1];
                CheckedmarkImgView.hidden=YES;
                        self.DeleteVideosBtn.hidden=YES;
                [self DriveVC];
            }
        }];
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"timer nill");
    UICollectionViewCell* cell =
    [photosCollectionCV cellForItemAtIndexPath:indexPathForDelete];
    UIImageView *CheckedmarkImgView= (UIImageView *)[cell viewWithTag:1];
    CheckedmarkImgView.hidden=YES;
    self.DeleteVideosBtn.hidden=YES;
    [super viewWillDisappear:YES];
}
- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    NSLog(@"tapping");
    screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    self.chatTableV.frame = CGRectMake(0, self.view.frame.origin.y + 10, width,(self.view.frame.size.height -150)-commentView.frame.size.height);
    DriveNameTXT.hidden=YES;
    DriveNameLbl.hidden=NO;
    DriveNameEditBtn.hidden=NO;
    [self setUpTextFieldforIphone];
    [self.view endEditing:YES];
}
-(void)GetComment
{
    NSLog(@"getcomment");
    if([[Reachability sharedReachability] internetConnectionStatus] == NotReachable){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Check Internet Connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [indicator stopAnimating];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
        [av show];
    }
    else
    {
        NSString *urlString = [[NSString alloc]initWithFormat:@"%@get_comment.php",app.Service ];
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSString *myRequestString;
        if([app.SharedDriveIdStr isEqualToString:@"null"])
        {
            myRequestString =[NSString stringWithFormat:@"{\"drive_id\":\"%@\"}",app.CollIdarr];
        }
        else
        {
            myRequestString =[NSString stringWithFormat:@"{\"drive_id\":\"%@\"}",app.SharedDriveIdStr];
        }
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
             NSLog(@"get_comment.php  ::::  %@",dictionary);
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
                     NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                     commentArr = [NSMutableArray arrayWithArray:[[dictionary valueForKey:@"posts"]valueForKey:@"comment"]];
                     NSLog(@"%@",[commentArr objectAtIndex:commentArr.count - 1]);
                     
                     emailArr = [NSMutableArray arrayWithArray:[[dictionary valueForKey:@"posts"]valueForKey:@"user"]];
                     if(app.ChatCountArr.count<commentArr.count)
                     {

                         [self.chatTableV reloadData];
                     }
                     NSLog(@"√√√√   %lu , %lu",(unsigned long)app.ChatCountArr.count,(unsigned long)commentArr.count);
                     [prefs setObject:commentArr forKey:@"commentArr"];
                     [prefs setObject:emailArr forKey:@"emailArr"];
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
-(void)viewWillAppear:(BOOL)animated
{
     CollectionName =@"";
    SettingView.hidden=YES;
    self.AddBtn.hidden=YES;
    self.DeleteVideosBtn.hidden=YES;
    self.AddMemberBtn.hidden=YES;
    self.SettingPageBtn.hidden=YES;
    self.InviteBtn.hidden=YES;
    MainCommentView.hidden=YES;
    PhotoCollectionView.hidden=YES;
    [_segment setSelectedSegmentIndex:1];
    [indicator startAnimating];
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(GettingComments) userInfo:nil repeats:NO];
    screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    self.chatTableV.frame = CGRectMake(0, self.view.frame.origin.y + 10, width,(self.view.frame.size.height -120)-commentView.frame.size.height);
    NSString *title = [_segment titleForSegmentAtIndex:_segment.selectedSegmentIndex];
    NSLog(@"%@",title);
    MainCommentView.hidden=NO;
    [indicator startAnimating];
    NSLog(@"segment clicked \n  %lu , %lu",(unsigned long)app.ChatCountArr.count,(unsigned long)commentArr.count);
    if (app.ChatCountArr.count == commentArr.count)
    {
        MainCommentView.hidden=NO;
        [indicator stopAnimating];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
    }
    else
    {
        [self.chatTableV reloadData];
    }
    PhotoCollectionView.hidden=YES;
    SettingView.hidden=YES;
}
-(void)DriveVC
{
    [indicator startAnimating];
    if([[Reachability sharedReachability] internetConnectionStatus] == NotReachable)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Check Internet Connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [indicator stopAnimating];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
        [av show];
    }
    else
    {
        [indicator startAnimating];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *email=[prefs valueForKey:@"email"];
        NSString *phone=[prefs valueForKey:@"contact"];
        NSString *urlString = [[NSString alloc]initWithFormat:@"http://46.166.173.116/FlippyCloud/webservices/get_drive_image_ios.php"];//temp
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSString *myRequestString;
        if([app.DriveStatusStr isEqualToString:@"1"])
        {
            NSLog(@"shared");
            myRequestString =[NSString stringWithFormat:@"{\"drive_name\":\"%@\",\"email\":\"%@\",\"drive_status\":\"Shared\"}",app.superDriveName,email];
        }
        else
        {
            NSLog(@"created");
            myRequestString =[NSString stringWithFormat:@"{\"drive_name\":\"%@\",\"email\":\"%@\",\"contact\":\"%@\"}",app.superDriveName,email,phone];
        }
        NSData *requestData = [NSData dataWithBytes:[myRequestString UTF8String] length:[myRequestString length]];
        [request setHTTPMethod: @"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody: requestData];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            [indicator startAnimating];
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
            [indicator startAnimating];
            NSError *parseError = nil;
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            NSLog(@"get_drive_image_ios.php  ::::  %@",dictionary);
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
                    TypeArr=[[dictionary valueForKey:@"posts"]valueForKey:@"type"];
                    CollImageArr=[[dictionary valueForKey:@"posts"]valueForKey:@"video_thum"];
                    OriginalLink=[[dictionary valueForKey:@"posts"]valueForKey:@"link"];
                    if ([app.DriveIntroInfo isEqualToString:@"no"])
                    {
                    }
                    else
                    {
                        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Long press to remove item." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [av show];
                        app.DriveIntroInfo=[NSString stringWithFormat:@"no"];
                    }
                    [indicator stopAnimating];
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
                    [photosCollectionCV reloadData];
                }
                else
                {
                    SettingImage.image=[UIImage imageNamed:@"img.png"];
                    [indicator stopAnimating];
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
                }
            }
        }];
    }
}
-(IBAction)AddMemberBtnPressed:(id)sender//addMemberVC
{
    app.SettingProfilePic = [OriginalLink objectAtIndex:0];
    [self performSegueWithIdentifier:@"addMemberVC" sender:self];
}
-(IBAction)segmentvalueselected:(id)sender
{
    UICollectionViewCell* cell =
    [photosCollectionCV cellForItemAtIndexPath:indexPathForDelete];
    UIImageView *CheckedmarkImgView= (UIImageView *)[cell viewWithTag:1];
    CheckedmarkImgView.hidden=YES;
    self.DeleteVideosBtn.hidden=YES;

    if(self.segment.selectedSegmentIndex == 0)
    {
        self.AddBtn.hidden=YES;
        self.DeleteVideosBtn.hidden=YES;
        self.SettingPageBtn.hidden=YES;
        self.InviteBtn.hidden=YES;
        self.AddMemberBtn.hidden=YES;
        NSString *title = [_segment titleForSegmentAtIndex:_segment.selectedSegmentIndex];
        NSLog(@"%@",title);
        [self DriveVC];
        MainCommentView.hidden=YES;
        SettingView.hidden=YES;
        PhotoCollectionView.hidden=NO;
    }
    else if (self.segment.selectedSegmentIndex == 1)
    {
        CollectionName =@"";
        CollImageArr=nil;
        self.AddBtn.hidden=YES;
        self.DeleteVideosBtn.hidden=YES;
        self.SettingPageBtn.hidden=YES;
        self.InviteBtn.hidden=YES;
        self.AddMemberBtn.hidden=YES;
        [indicator startAnimating];
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(GettingComments) userInfo:nil repeats:NO];
        screenBounds = [[UIScreen mainScreen] bounds];
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
            self.chatTableV.frame = CGRectMake(0, self.view.frame.origin.y + 10, width,(self.view.frame.size.height -120)-commentView.frame.size.height);
        NSString *title = [_segment titleForSegmentAtIndex:_segment.selectedSegmentIndex];
        NSLog(@"%@",title);
        MainCommentView.hidden=NO;
        [indicator startAnimating];
        NSLog(@"segment clicked \n  %lu , %lu",(unsigned long)app.ChatCountArr.count,(unsigned long)commentArr.count);
        if (app.ChatCountArr.count == commentArr.count)
        {
            MainCommentView.hidden=NO;
            [indicator stopAnimating];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
        }
        else
        {
            [self.chatTableV reloadData];
        }
        PhotoCollectionView.hidden=YES;
        SettingView.hidden=YES;
    }
    else
    {
        SettingView.hidden=NO;
        self.AddBtn.hidden=YES;
        self.DeleteVideosBtn.hidden=YES;
        self.AddMemberBtn.hidden=YES;
//      self.SettingPageBtn.hidden=NO;
        self.InviteBtn.hidden=NO;
        MainCommentView.hidden=YES;
        PhotoCollectionView.hidden=YES;
         CollectionName =@"contact";
        
        [self.EmailTableView setAllowsMultipleSelection:YES];
        [self.EmailTableView reloadData];
//        ContactEmails=[[NSMutableArray alloc]init];
//        FullNameArr=[[NSMutableArray alloc]init];
//        contactno=[[NSMutableArray alloc]init];
//
//        selectedContacts=[[NSMutableArray alloc]init];
//        SelectMobileNo=[[NSMutableArray alloc]init];
//        CNAuthorizationStatus status1 = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
//        if(status1 == CNAuthorizationStatusDenied || status1 == CNAuthorizationStatusRestricted)
//        {
//            NSLog(@"access denied");
//        }
//        else
//        {
//            
//            CNContactStore *contactStore = [[CNContactStore alloc] init];
//            NSArray *keys = @[CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPhoneNumbersKey, CNContactImageDataKey,CNContactEmailAddressesKey];
//            CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:keys];
//            request.predicate = nil;
//            [contactStore enumerateContactsWithFetchRequest:request
//                                                      error:nil
//                                                 usingBlock:^(CNContact* __nonnull contact, BOOL* __nonnull stop)
//             {
//                 phoneNumber = @"";
//                 if( contact.phoneNumbers)
//                 phoneNumber = [[[contact.phoneNumbers firstObject] value] stringValue];
//                 FirstnameStr=contact.givenName;
//                 LastnameStr=contact.familyName;
//                 CoEmail = [[contact.emailAddresses valueForKey:@"value"] lastObject];
//                 
//                 
//                 if(CoEmail==nil)
//                 {
//                     CoEmail=@"";
//                 }
//                 if(phoneNumber==nil)
//                 {
//                     phoneNumber=@"";
//                 }
//              
//                 
//                 NSString *TrimedPhone =[[[phoneNumber stringByReplacingOccurrencesOfString:@")" withString:@""] stringByReplacingOccurrencesOfString:@"(" withString:@""]stringByReplacingOccurrencesOfString:@"-" withString:@""];
//                 phoneNumber =[[TrimedPhone componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
//                               componentsJoinedByString:@""];
//
//                NSString *FullName=[NSString stringWithFormat:@"%@ %@",FirstnameStr,LastnameStr];
//                NSString *trimmed ;
//             
//                if([[FullName substringToIndex:1] isEqualToString:@" "])
//                {
//                    trimmed = [FullName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//                    int len = [trimmed length];
//                    if(len == 0)
//                    {
//                        trimmed = FullName;
//                    }
//                }
//                else
//                {
//                    trimmed =FullName;
//                }
//
//                
//                 
//             
//                [FullNameArr addObject:trimmed];
//                [contactno addObject:phoneNumber];
//                [ContactEmails addObject:CoEmail];
//                NSString *ContactStr=[NSString stringWithFormat:@"%@,%@",trimmed,phoneNumber];
//                 [Demo addObject:ContactStr];
//                 
//                 
//                ContactDic = [NSDictionary dictionaryWithObject:FullNameArr forKey:@"FullName"];
//
//            }];
//        }
//        [indicator startAnimating];
//        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(ReloadColl) userInfo:nil repeats:NO];
    }
}
//-(void)ReloadColl//contactList
//{
//    
//    CollectionName =@"contact";
//    NSLog(@"Demo ::::  %@",Demo);
//    app.demoList =Demo;
//    NSLog(@"Contact Dic ::::  %@",[ContactDic valueForKey:@"FullName"]);
//    for (int i=0; i<contactno.count; i++)
//    {
//        NSString *a=[contactno objectAtIndex:i];
//        NSLog(@"%@",a);
//        
//        for (int k=0; k<[app.RegContactList count]; k++)
//        {
//                    NSLog(@"%@",[app.RegContactList objectAtIndex:k]);
//            if ([[app.RegContactList objectAtIndex:k] containsString:a])
//            {
//                NSLog(@"string contains bla!");
//                [differentIndex addObject:a];
//            }
//            else
//            {
//                NSLog(@"string does not contain bla");
//                
//            }
//            
//        }
//        [RemainingContacts addObject:a];
//    }
//
//    NSLog(@"differentIndex ::::  %@",differentIndex);
//    app.RemainingContList=RemainingContacts;
//    [self.EmailTableView reloadData];
//
//    [indicator stopAnimating];
//    [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
//}
-(void)GettingComments
{
    [indicator startAnimating];
    timer =  [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(GetComment) userInfo:nil repeats:YES];
}
//≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈   PhotoCollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return CollImageArr.count;
}

- (ImageCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[ImageCollectionViewCell reuseIdentifier] forIndexPath:indexPath];
    UIImageView *recipeImageView = (UIImageView *)[cell viewWithTag:100];
    NSString *TypeUrl=[NSString stringWithFormat:@"%@",[TypeArr objectAtIndex:indexPath.row]];
    
        UIImageView *videoPlay = (UIImageView *)[cell viewWithTag:101];
    if([TypeUrl isEqualToString:@"image"])
    {
        videoPlay.hidden=YES;
        NSLog(@"%@",[OriginalLink objectAtIndex:indexPath.row]);
        NSString *imsage=[OriginalLink objectAtIndex:indexPath.row];
        recipeImageView.imageURL=[NSURL URLWithString:imsage];
    }
    else
    {
        videoPlay.hidden=NO;
        NSURL *imageUrl =[NSURL URLWithString:[NSString stringWithFormat:@"%@",[OriginalLink objectAtIndex:indexPath.row]]];
        AVURLAsset *asset1 = [[AVURLAsset alloc] initWithURL:imageUrl options:nil];
        AVAssetImageGenerator *generate1 = [[AVAssetImageGenerator alloc] initWithAsset:asset1];
        generate1.appliesPreferredTrackTransform = YES;
        NSError *err = NULL;
        CMTime time = CMTimeMake(1, 2);
        CGImageRef oneRef = [generate1 copyCGImageAtTime:time actualTime:NULL error:&err];
        UIImage *one = [[UIImage alloc] initWithCGImage:oneRef];
        NSData *imageDataThumb = UIImageJPEGRepresentation(one, 1);
        recipeImageView.image=[UIImage imageWithData:imageDataThumb];
        recipeImageView.alpha=0.8;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    countIndexedd = -1;
    NSString *TypeUrl=[NSString stringWithFormat:@"%@",[TypeArr objectAtIndex:indexPath.row]];
    if([TypeUrl isEqualToString:@"image"])
    {
        app.view=@"DriveSub";
        if([app.DriveStatusStr isEqualToString:@"1"])
        {
            app.DriveSelectedImageStatusStr=@"1";
        }
        app.CollImgURL=[OriginalLink objectAtIndex:indexPath.row];
        NSLog(@"%@",app.CollImgURL);
        [photosCollectionCV reloadItemsAtIndexPaths:[photosCollectionCV indexPathsForVisibleItems]];
        photoImageIV.imageURL = [[app.json valueForKey:@"posts"]valueForKey:@"picture_name"];
        
        //navigation
        UINavigationController *navigationController = (UINavigationController *)app.window.rootViewController;
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        ImageViewVC *MainPage = (ImageViewVC*)[mainStoryboard instantiateViewControllerWithIdentifier: @"ImageViewVC"];
        [navigationController pushViewController:MainPage animated:YES];
        //---- stop
        [collectionView reloadData];
    }
    else
    {
        NSString *videoURL =[NSString stringWithFormat:@"%@",[OriginalLink objectAtIndex:   indexPath.row]];
        NSURL *videos=[NSURL URLWithString:videoURL];
        [self.moviePlayerController prepareToPlay];
        self.moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:videos];
        self.moviePlayerController.backgroundView.backgroundColor  = [UIColor lightGrayColor] ;
        [self.moviePlayerController setMovieSourceType:MPMovieSourceTypeFile];
        [self.view addSubview:self.moviePlayerController.view];
        self.moviePlayerController.fullscreen = YES;
        [self.moviePlayerController play];
    }
}
//≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈

-(IBAction)BackBtnPressed:(id)sender
{app.DriveArrNameCopy=NULL;
    UINavigationController *navigationController = (UINavigationController *)app.window.rootViewController;
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    DriveVc *Main = (DriveVc *)[mainStoryboard instantiateViewControllerWithIdentifier: @"DriveVc"];
    [navigationController pushViewController:Main animated:NO];
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

#pragma mark - Table View ChatView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([CollectionName isEqualToString:@"contact"])
    {
        return app.FilteredContacts.count;
    }
    else
    {
        return commentArr.count;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([CollectionName isEqualToString:@"contact"])
    {
        return 60;
    }
    else
    {
        NSString *cellText =[NSString stringWithFormat:@"%@",[commentArr objectAtIndex:indexPath.row]];
        UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:15.0];
        CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
        CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
        return labelSize.height + 30;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([CollectionName isEqualToString:@"contact"])
    {
        static NSString* cellIdentifier = @"EmailTableView";
        Tcell =  [self.EmailTableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (Tcell == nil)
        {
            Tcell =  [chatTableV dequeueReusableCellWithIdentifier:cellIdentifier];
            Tcell.backgroundColor = [UIColor clearColor];
        }
        UILabel *ContactEmail=(UILabel *)[Tcell viewWithTag:2];
        UILabel *ContactFirstChar=(UILabel *)[Tcell viewWithTag:1];
        UILabel *fullName=(UILabel *)[Tcell viewWithTag:3];
//        ContactFirstChar.text=[NSString stringWithFormat:@"%@",[[FullNameArr objectAtIndex:indexPath.row] substringToIndex:1]];
//        
//        NSString *FirstChar=[[FullNameArr objectAtIndex:indexPath.row] substringToIndex:1];
//        NSLog(@"FC:%@",FirstChar);
        
        NSString *Contact=[app.FilteredContacts objectAtIndex:indexPath.row];


        for (int k=0; k<[Demo count]; k++)
        {
            NSLog(@"%@",[Demo objectAtIndex:k]);
            if ([[Demo objectAtIndex:k] containsString:Contact])
            {
                NSLog(@"string contains bla!");
                NSString *Demostr=[Demo objectAtIndex:k];
                NSArray *items = [Demostr componentsSeparatedByString:@","];
                fullName.text=[items objectAtIndex:0];
                  ContactFirstChar.text=[NSString stringWithFormat:@"%@",[[items objectAtIndex:0] substringToIndex:1]];
            }
            else
            {
                NSLog(@"string does not contain bla");
            }
        }
        ContactEmail.text=[NSString stringWithFormat:@"%@",Contact];

    }
    else
    {
        static NSString* cellIdentifier = @"messagingCell";
        Tcell =  [chatTableV dequeueReusableCellWithIdentifier:cellIdentifier];
        if (Tcell == nil)
        {
            Tcell =  [chatTableV dequeueReusableCellWithIdentifier:cellIdentifier];
            Tcell.backgroundColor = [UIColor clearColor];
        }
        Tcell.textLabel.text =[NSString stringWithFormat:@"%@",[emailArr objectAtIndex:indexPath.row]];
        Tcell.detailTextLabel.text=[NSString stringWithFormat:@"%@",[commentArr objectAtIndex:indexPath.row]];
        Tcell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
        Tcell.detailTextLabel.numberOfLines = 0;
        Tcell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
        [indicator stopAnimating];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
    }
    return Tcell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.SettingPageBtn.hidden=YES;
    self.InviteBtn.hidden=YES;
    self.AddBtn.hidden=NO;
    NSString *EmailAdd=[NSString stringWithFormat:@"%@",[ContactEmails objectAtIndex:indexPath.row]];
    NSString *ContactNo=[NSString stringWithFormat:@"%@",[contactno objectAtIndex:indexPath.row]];

    if ([EmailAdd isEqualToString:@""])
    {
        if([ContactNo isEqualToString:@""])
        {
            NSLog(@"asdasdasdasd");
        }
        else
        {
            ContactToSendMsg=[NSString stringWithFormat:@"%@",[contactno objectAtIndex:indexPath.row]];
            [SelectMobileNo addObject:ContactToSendMsg];
        }
    }
    else
    {
        [selectedContacts addObject: [NSString stringWithFormat:@"%@",[ContactEmails objectAtIndex:indexPath.row]]];
    }
}

-(void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [selectedContacts removeObject:[NSString stringWithFormat:@"%@",[ContactEmails objectAtIndex:indexPath.row]]];
    [SelectMobileNo removeObject:[NSString stringWithFormat:@"%@",[contactno objectAtIndex:indexPath.row]]];
    
    if(selectedContacts.count == 0)
    {
//        self.SettingPageBtn.hidden=NO;
        self.InviteBtn.hidden=NO;
        self.AddBtn.hidden=YES;
    }
}
- (void)showSMS:(NSString*)file
{
    if(![MFMessageComposeViewController canSendText])
    {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    NSArray *recipents = [[NSArray alloc]initWithArray:SelectMobileNo];
    NSString *message = [NSString stringWithFormat:@" %@ ", file];
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
    [messageController setBody:message];
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result)
    {
        case MessageComposeResultCancelled:
            break;

        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    [self.EmailTableView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)DoneBtnPressed:(id)sender
{
    NSString *selectedFile = @"Hey i am on FlippyCloud";
    
    NSLog(@"%@\n\n\n\n\%@",SelectMobileNo,selectedContacts);
    
    
    if(selectedContacts != NULL)
    {
        NSLog(@"%lu",(unsigned long)selectedContacts.count);
        
        if(selectedContacts.count == 0)
        {
            [self showSMS:selectedFile];
            
        }
        else
        {
            if (selectedContacts.count != 0 && SelectMobileNo.count !=0)
            {
                [self showSMS:selectedFile];

                [indicator startAnimating];
                [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(CreationDrives) userInfo:nil repeats:NO];

            }
            else
            {
                [indicator startAnimating];
                [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(CreationDrives) userInfo:nil repeats:NO];
            }
            
        }
    }
    else
    {
        [self showSMS:selectedFile];
    }
}
-(void)CreationDrives
{
    NSString *SharedEmail;
    for (int i= 0; i< selectedContacts.count; i++)
    {
        if (i==0)
        {
            SharedEmail = [NSString stringWithFormat:@"\"%@\"",[selectedContacts objectAtIndex:i]];
        }
        else
        {
            SharedEmail = [NSString stringWithFormat:@"%@,\"%@\"",SharedEmail,[selectedContacts objectAtIndex:i]];
        }
    }
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *email=[prefs valueForKey:@"email"];
    NSString *contact = [prefs valueForKey:@"contact"];
    NSString *urlString = [[NSString alloc]initWithFormat:@"%@drive.php",app.Service ];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *myRequestString =[NSString stringWithFormat:@"{\"drive_name\":\"%@\",\"email\":\"%@\",\"contact\":\"%@\",\"invite_email\":[%@]}",app.superDriveName,email,contact,SharedEmail];
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
        NSLog(@"drive.php  ::::  %@",dictionary);
        if (!dictionary)
        {
            NSLog(@"%s: JSONObjectWithData error: %@; data = %@", __FUNCTION__, parseError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            return ;
        }
        else
        {
            app.DriveArrNameCopy=NULL;
            NSLog(@"drive.php  ::::  %@",dictionary);
            UINavigationController *navigationController = (UINavigationController *)app.window.rootViewController;
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            DriveVc *Main = (DriveVc *)[mainStoryboard instantiateViewControllerWithIdentifier: @"DriveVc"];
            [navigationController pushViewController:Main animated:NO];
        }
    }];
}

//*************

-(IBAction)sendBtnClickedOfCV:(id)sender
{
  [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(SendComment) userInfo:nil repeats:NO];
}
-(void)SendComment
{
    if([[Reachability sharedReachability] internetConnectionStatus] == NotReachable)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Check Internet Connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
    }
    else
    {
        if ([messageTf.text isEqual:@"Write a message..."])
        {
            Messagetext = nil;
        }
        else
        {
            Messagetext = messageTf.text;
        }
        if ([Messagetext length] == 0)
        {
            return;
        }
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *email=[prefs valueForKey:@"email"];
        NSString *urlString = [[NSString alloc]initWithFormat:@"%@set_comment.php",app.Service ];
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSString *myRequestString;
        if([app.SharedDriveIdStr isEqualToString:@"null"])
        {
            myRequestString =[NSString stringWithFormat:@"{\"drive_id\":\"%@\",\"user\":\"%@\",\"comment\":\"%@\"}",app.CollIdarr,email,Messagetext];
        }
        else
        {
            myRequestString =[NSString stringWithFormat:@"{\"drive_id\":\"%@\",\"user\":\"%@\",\"comment\":\"%@\"}",app.SharedDriveIdStr,email,Messagetext];
        }
        NSData *requestData = [NSData dataWithBytes:[myRequestString UTF8String] length:[myRequestString length]];
        [request setHTTPMethod: @"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody: requestData];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
         {
             NSError *parseError = nil;
             NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
             NSLog(@"set_comment.php  ::::  %@",dictionary);
             if (!dictionary)
             {
                 NSLog(@"%s: JSONObjectWithData error: %@; data = %@", __FUNCTION__, parseError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                 return ;
             }
             else
             {
             }
             NSString *f_name=[prefs valueForKey:@"f_name"];
             NSString *l_name=[prefs valueForKey:@"l_name"];
             NSString *Username=[NSString stringWithFormat:@"%@ %@",f_name,l_name];
             [commentArr addObject:Messagetext];
             [emailArr addObject:Username];
             app.ChatCountArr =[commentArr copy];
             [self TableView_Reload_Bottom];
             messageTf.text=nil;
             [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
         }];
    }
}

#pragma mark - frame textview
-(void)setUpTextFieldforIphone
{
    commentView.frame=CGRectMake(0, MainCommentView.frame.size.height-55, screenBounds.size.width, 50);
    messageTf = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(8, 10, screenBounds.size.width-65, 35)];
    messageTf.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    messageTf.minNumberOfLines = 1;
    messageTf.maxNumberOfLines = 6;
    messageTf.returnKeyType = UIReturnKeyDefault;
    messageTf.font = [UIFont systemFontOfSize:16.0f];
    messageTf.delegate = self;
    messageTf.backgroundColor = [UIColor whiteColor];
    [messageTf setKeyboardType:UIKeyboardTypeAlphabet];
    [self commentsTextVPlaceholder];
    [commentView addSubview:messageTf];
}

#pragma mark - Textview Placeholder
-(void)commentsTextVPlaceholder
{
    [messageTf setText:@"Write a message..."];
    [messageTf setFont:[UIFont fontWithName:@"HelveticaNeue" size:16]];
    [messageTf setTextColor:[UIColor lightGrayColor]];
    [messageTf scrollRangeToVisible:NSMakeRange(0, 0)];
}
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    CGRect r = commentView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    commentView.frame = r;
}
#pragma mark - Keybord Method
- (void)keyboardWillChangeOpen:(NSNotification *)note
{
    NSLog(@"show");
    if ([messageTf.text isEqual:@"Write a message..."])
    {
        messageTf.text = @"";
        messageTf.textColor = [UIColor blackColor];
        [sendCommBtn setBackgroundImage:[UIImage imageNamed:@"SendBtnDark.png"] forState:UIControlStateNormal];
    }
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    CGRect containerFrame = commentView.frame;
    containerFrame.origin.y = MainCommentView.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    CGRect tableviewframe=chatTableV.frame;
    screenBounds = [[UIScreen mainScreen] bounds];
    tableviewframe.size.height = MainCommentView.frame.size.height - 310;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    commentView.frame = containerFrame;
    chatTableV.frame=tableviewframe;
    [self TableView_Reload_Bottom];
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)note
{
    NSLog(@"hide");
    if(messageTf.text.length == 0)
    {
        [self commentsTextVPlaceholder];
    }
    //TextView
    [sendCommBtn setBackgroundImage:[UIImage imageNamed:@"SendBtnLight.png"] forState:UIControlStateNormal];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    CGRect containerFrame = CGRectMake(0, 500, 375, 50);
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    CGRect tableviewframe=chatTableV.frame;
    
    //tableviewframe.size.height+=260;
    screenBounds = [[UIScreen mainScreen] bounds];
    tableviewframe.size.height =  MainCommentView.frame.size.height - 90;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    //set views with new info
    screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    chatTableV.frame = CGRectMake(0, self.view.frame.origin.y + 10, width,(self.view.frame.size.height -110)-commentView.frame.size.height);
    [self setUpTextFieldforIphone];
    
    //commit animations
    [UIView commitAnimations];
}
-(void)TableView_Reload_Bottom
{
    if (commentArr.count>0)
    {
        [chatTableV reloadData];
        NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:([commentArr count] - 1) inSection:0];
        [chatTableV scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        [chatTableV beginUpdates];
        [chatTableV reloadRowsAtIndexPaths:[NSArray arrayWithObjects:scrollIndexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
        [chatTableV endUpdates];
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    NSLog(@"done %@",DriveNameTXT.text);
    DriveNameLbl.text=[NSString stringWithFormat:@"%@",DriveNameTXT.text];
    DriveNameTXT.hidden=YES;
    DriveNameLbl.hidden=NO;
    DriveNameEditBtn.hidden=NO;
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(RenameDrive) userInfo:nil repeats:NO];
    return YES;
}
-(void)RenameDrive
{
    [indicator startAnimating];
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
        NSString *urlString = [[NSString alloc]initWithFormat:@"%@rename_drive.php",app.Service];
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSString *myRequestString =[NSString stringWithFormat:@"{\"email\":\"%@\",\"contact\":\"%@\",\"oldName\":\"%@\",\"id\":\"%@\",\"newName\":\"%@\"}",email,phone,app.superDriveName,app.CollIdarr,DriveNameTXT.text];
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
             NSLog(@"rename_drive.php  ::::  %@",dictionary);
             if (!dictionary)
             {
                 NSLog(@"%s: JSONObjectWithData error: %@; data = %@", __FUNCTION__, parseError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                 return ;
             }
             else
             {
                 NSString *success=[dictionary valueForKey:@"Success"];
                 if([success isEqualToString:@"1"])
                 {
                     NSLog(@"successfuly Renamed");
                     app.DriveArrNameCopy=NULL;
                     [indicator stopAnimating];
                     [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
                 }
                 else
                 {
                     UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Something Wrong." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                     [av show];
                     [indicator stopAnimating];
                     [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
                 }
             }
         }];
    }
}
#pragma Setting Segment

#pragma Add Multiple image to drive
-(IBAction)AddItemBtnPressed:(id)sender
{
    NSString *other1 = @"Add Images";
    NSString *other2 = @"Add Videos";
    NSString *cancelTitle = @"Cancle";
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:cancelTitle
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:other1,other2, nil];

    [actionSheet showInView:self.view];
}
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex ;
{
    if(buttonIndex==0)
    {
        actionItemStr= @"images";
        IQMediaPickerController *controller = [[IQMediaPickerController alloc] init];
        controller.delegate = self;
        app.maxImageCounter = @"10";
        [controller setMediaType:IQMediaPickerControllerMediaTypePhotoLibrary];
        [controller setAllowsPickingMultipleItems:YES];
        [self presentViewController:controller animated:YES completion:nil];
    }
    else if(buttonIndex==1)
    {
                actionItemStr= @"videos";
        IQMediaPickerController *controller = [[IQMediaPickerController alloc] init];
        controller.delegate = self;
        [controller setMediaType:IQMediaPickerControllerMediaTypeVideoLibrary];
        app.maxVideoCounter=@"2";
        [controller setAllowsPickingMultipleItems:YES];
        [self presentViewController:controller animated:YES completion:nil];
    }
}

//*****************************************************************************//
#pragma mark - UIImagePickerControllerHiddenAPIDelegate Methods
//*****************************************************************************//
- (void)mediaPickerController:(IQMediaPickerController*)controller didFinishMediaWithInfo:(NSDictionary *)info;
{
    if([actionItemStr isEqualToString:@"images"])
    {
        NSLog(@"add images");
        imagePath = [[info valueForKey:@"IQMediaTypeImage"]valueForKey:@"IQMediaImage"];
        self.assetsFetchResults = [PHAsset fetchAssetsWithOptions:nil];
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHVideoRequestOptionsVersionOriginal;
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(insertImage) userInfo:nil repeats:NO];
    }
    else
    {
        [indicator startAnimating];
        NSLog(@"add videos");
        mediaInfo = [info copy];
        NSString *key = @"IQMediaTypeVideo";
        dict = [mediaInfo objectForKey:key];//4
        [self VideoConverting];
    }
}
-(void)VideoConverting
{
    [indicator startAnimating];
    imagesAllArray = [[NSMutableArray alloc]init];
    DicItems = dict.count;
    [self convertVideoToMP4];
}
- (NSData *)getCroppedData:(NSURL *)urlMedia
{
    [indicator startAnimating];
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
    [indicator startAnimating];
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
//    NSError *error = nil;
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
        AVAssetExportSession*exporter = [[AVAssetExportSession alloc]initWithAsset:composition presetName:AVAssetExportPresetLowQuality];
        exporter.outputURL=urlVideo;
        exporter.outputFileType=@"com.apple.quicktime-movie";
        exporter.shouldOptimizeForNetworkUse=YES;
        [exporter exportAsynchronouslyWithCompletionHandler:^{
            switch([exporter status])
            {
                case AVAssetExportSessionStatusFailed:
                {
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error!" message:@"Faild to upload." preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                    [alertController addAction:ok];
                    [self presentViewController:alertController animated:YES completion:nil];
                    break;
                }
                case AVAssetExportSessionStatusCancelled:
                {
                    NSLog(@"Failed to export video");

                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error!" message:@"Uploading cancel" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                    [alertController addAction:ok];
                    [self presentViewController:alertController animated:YES completion:nil];
                    break;
                }
                case AVAssetExportSessionStatusCompleted:
                {
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
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Completed!" message:@"Videos are uploaded successfully." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    [self presentViewController:alertController animated:YES completion:nil];
    [photosCollectionCV reloadData];
}
-(void)MethodCounterCall
{
    [indicator startAnimating];
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

-(void)SendButton//videos
{
    [indicator startAnimating];
    if([[Reachability sharedReachability] internetConnectionStatus] == NotReachable){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Check Internet Connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [indicator stopAnimating];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
        [av show];
    }
    else
    {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *contact=[prefs valueForKey:@"contact"];
                NSString *email=[prefs valueForKey:@"email"];
        NSString *urlStr = [[NSString alloc]initWithFormat:@"%@add_multipal_img_drive.php",app.Service ];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSString *myRequestString;
        if([app.DriveStatusStr isEqualToString:@"1"])
        {
            myRequestString =[NSString stringWithFormat:@"{\"drive_name\":\"%@\",\"drive_status\":\"shared\",\"email\":\"%@\",\"video_name\":\[\"%@\"],\"video_img\":\[\"%@\"]}",app.superDriveName,email,[NSString stringWithFormat:@"%@",[arr1 objectAtIndex:AllItems]],[NSString stringWithFormat:@"%@",[video_imageArr objectAtIndex:AllItems]]];
        }
        else
        {
            myRequestString =[NSString stringWithFormat:@"{\"contact\":\"%@\",\"drive_name\":\"%@\",\"email\":\"%@\",\"video_name\":\[\"%@\"],\"video_img\":\[\"%@\"]}",contact,app.superDriveName,email,[NSString stringWithFormat:@"%@",[arr1 objectAtIndex:AllItems]],[NSString stringWithFormat:@"%@",[video_imageArr objectAtIndex:AllItems]]];
        }
        NSData *requestData = [NSData dataWithBytes:[myRequestString UTF8String] length:[myRequestString length]];
        [request setHTTPMethod: @"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody: requestData];
        NSError *error;
        NSURLResponse *response;
        NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingAllowFragments error:nil];
            NSLog(@" add_multipal_img_drive.Videos  ::%@",jsonDictionary);
        NSString *res=[jsonDictionary valueForKey:@"success"];
        int value=[res intValue];
        if(value == 1)
        {
            if (AllItems != 0)
            {
                [self MethodCounterCall];
            }
            if (AllItems == 0)
            {
                app.DriveIntroInfo = [NSString stringWithFormat:@"no"];
                [self DriveVC];
            }
        }
        else
        {
            [indicator stopAnimating];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error!" message:@"Fail to upload multiple videos." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            [self presentViewController:alertController animated:YES completion:nil];
            [photosCollectionCV reloadData];
        }
        resizearrayNo = (int)[videoURLCopy count];
        newarrayNo = (int)[arr1 count];
        videoURLCopy = [app.VidesAllBackArr copy];
        ImgaesArr = [app.VidesImageAllBackArr copy];
        totalarraySizeNo = resizearrayNo + newarrayNo;
        videoURLCopy = [app.VidesAllBackArr copy];
        [arr1 removeAllObjects];
        if(DicItems != 0)
        {
            DicItems = DicItems - 1;
            
        }
    }
}
-(void)mediaPickerControllerDidCancel:(IQMediaPickerController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"Cancelled");
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
        ImgArr1=[[NSMutableArray alloc]init];
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
        ImgArr1 = [[NSMutableArray alloc]init];
        [ImgArr1 insertObject:strEncoded atIndex:0];
        NSString *obje = [NSString stringWithFormat:@"\"%@\"",strEncoded];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *email=[prefs valueForKey:@"email"];
        NSString *contact=[prefs valueForKey:@"contact"];
        NSString *urlStr = [[NSString alloc]initWithFormat:@"%@add_multipal_img_drive.php",app.Service ];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",urlStr]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSString *myRequestString;
        if([app.DriveStatusStr isEqualToString:@"1"])
        {
            myRequestString =[NSString stringWithFormat:@"{\"contact\":\"%@\",\"drive_name\":\"%@\",\"image_name\":\[%@],\"drive_status\":\"shared\",\"email\":\"%@\"}",contact,app.superDriveName,obje,email];
        }
        else
        {
            NSString *drivestatus=[NSString stringWithFormat:@""];
            myRequestString =[NSString stringWithFormat:@"{\"contact\":\"%@\",\"drive_name\":\"%@\",\"image_name\":\[%@],\"drive_status\":\"%@\",\"email\":\"%@\"}",contact,app.superDriveName,obje,drivestatus,email];
        }
        NSData *requestData = [NSData dataWithBytes:[myRequestString UTF8String] length:[myRequestString length]];
        [request setHTTPMethod: @"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody: requestData];
        NSError *error;
        NSURLResponse *response;
        NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"add_multipal_img_drive.php :: %@",jsonDictionary);
        NSString *res=[jsonDictionary valueForKey:@"success"];
        int value=[res intValue];
        if(value == 1)
        {
            app.DriveArrNameCopy=NULL;
            CollImageArr=[[[[jsonDictionary valueForKey:@"posts"]valueForKey:@"image"]valueForKey:@"images"]objectAtIndex:0];
            [allImageUploadArr removeObjectAtIndex:index];
            [self FinallyCall];
            [indicator stopAnimating];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
            app.DriveIntroInfo = [NSString stringWithFormat:@"no"];
            [self DriveVC];
        }
        else
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Images are not available." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [indicator stopAnimating];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
            [av show];
        }
    }
    else
    {
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(reloadCollectionView) userInfo:nil repeats:NO];
    }
}
-(void)reloadCollectionView
{
    [photosCollectionCV reloadData];
}
- (void)didReceiveMemoryWarning
{
    NSLog(@"relese");
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
