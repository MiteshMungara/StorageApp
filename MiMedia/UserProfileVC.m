//
//  UserProfileVC.m
//  Flippy Cloud
//
//  Created by iSquare5 on 15/08/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import "UserProfileVC.h"
#import "SidebarViewController.h"
#import "Base64.h"
#import "AsyncImageView.h"
#import "Reachability.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "JBWhatsAppActivity.h"
#import "SSCWhatsAppActivity.h"
#import <Social/Social.h>

@interface UserProfileVC ()<UIActionSheetDelegate,UINavigationBarDelegate,UIImagePickerControllerDelegate>
{
    AppDelegate *app;
    CGFloat animateDistance;
    UIImageView *imageV;
    UIVisualEffectView *blurEffectView;
    UIActivityIndicatorView *indicator;
    NSString *strEncoded,*status,*planstatus;
    NSURL *ImageUrl;
    int pointsToday,PointsTotal;
    NSString *DateStr1,*DateStr2;
    NSString *TotalPoints,*SharedItem;
    
}

@property (nonatomic, retain) SidebarViewController* sidebarVC;
@end
@implementation UserProfileVC

- (void)viewDidLoad
{
   [super viewDidLoad];
   [self initPB];
   
   app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
   self.sidebarVC = [[SidebarViewController alloc] init];
   [self.sidebarVC setBgRGB:0x000000];
   self.sidebarVC.view.frame  = self.view.bounds;
   [self.view addSubview:self.sidebarVC.view];
   [self.sidebarVC showHideSidebar];
   [self viewDidAppear:YES];
   int i =[app.planstatusStr intValue];
   [self GetPointDetail];
   NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    if([app.AffStatus isEqualToString:@"1"])
    {
        self.NonSharingView.hidden=YES;
        self.SecondView.hidden=NO;
        [self.RewordBtn setTitle:[NSString stringWithFormat:@"Earn Points With Share  %@",app.AppTodayPoint] forState:UIControlStateNormal];
    }
    else
    {
        self.NonSharingView.hidden=NO;
        self.SecondView.hidden=YES;
    }
    
    
    if(i == 0)
    {

        self.RefereFrndBtn.hidden=YES;
        planstatus=@"0";
     }
    else
    {
        self.RefereFrndBtn.hidden=NO;
        self.scrollView.contentSize=CGSizeMake(self.view.frame.size.width,self.view.frame.size.height + 50);
    }
    
    if([app.CurrentversionSTR isEqualToString:@"1.4"])
    {
        self.RefereFrndBtn.hidden=YES;
        planstatus=@"0";
    }
    else
    {
        self.RefereFrndBtn.hidden=NO;
        self.scrollView.contentSize=CGSizeMake(self.view.frame.size.width,self.view.frame.size.height + 70);
    }
    
    
    imageV=(UIImageView *)[self.view viewWithTag:1];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:imageV.bounds byRoundingCorners:(UIRectCornerTopRight| UIRectCornerTopLeft | UIRectCornerBottomLeft |UIRectCornerBottomRight) cornerRadii:CGSizeMake(80,80)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.view.bounds;
    maskLayer.path  = maskPath.CGPath;
    imageV.layer.mask = maskLayer;
    

    NSString *f_name=[prefs valueForKey:@"f_name"];
    NSString *l_name=[prefs valueForKey:@"l_name"];
    NSString *email=[prefs valueForKey:@"email"];
    NSString *contact=[prefs valueForKey:@"contact"];
    NSString *photo=[prefs valueForKey:@"photo"];
    imageV.image = nil;
    self.avatarLab.text =[NSString stringWithFormat:@"%@%@",[f_name substringToIndex:1],[l_name substringToIndex:1]];
    
    self.avatarLab.layer.cornerRadius = self.avatarLab.frame.size.width/2;
    self.avatarLab.clipsToBounds = YES;
    UIView *f_nameTXT = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [self.f_nameTXT setLeftViewMode:UITextFieldViewModeAlways];
    [self.f_nameTXT setLeftView:f_nameTXT];
    UIView *l_nameTXT = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [self.l_nameTXT setLeftViewMode:UITextFieldViewModeAlways];
    [self.l_nameTXT setLeftView:l_nameTXT];
    UIView *emailTXT = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [self.emailTXT setLeftViewMode:UITextFieldViewModeAlways];
    [self.emailTXT setLeftView:emailTXT];
    UIView *contactTXT = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [self.contactTXT setLeftViewMode:UITextFieldViewModeAlways];
    [self.contactTXT setLeftView:contactTXT];
    UIView *passTXT = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [self.passTXT setLeftViewMode:UITextFieldViewModeAlways];
    [self.passTXT setLeftView:passTXT];
    UIView *addTXT = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [self.addTXT setLeftViewMode:UITextFieldViewModeAlways];
    [self.addTXT setLeftView:addTXT];
    UIView *OldpassTXT = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [self.OldpassTXT setLeftViewMode:UITextFieldViewModeAlways];
    [self.OldpassTXT setLeftView:OldpassTXT];
    UIView *UpgradeKeyTXT = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [self.UpgradeKeyTXT setLeftViewMode:UITextFieldViewModeAlways];
    [self.UpgradeKeyTXT setLeftView:UpgradeKeyTXT];

    if(photo)
    {
//      self.avatarLab.hidden=YES;
        NSString *imageStr=photo;
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadImageWithURL:[NSURL URLWithString:imageStr]
                              options:0
                             progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                 float prog = (float)receivedSize/expectedSize;
                                 int process = (int)(100.0*prog);
                                 if (process == 100)
                                 {
                                     [indicator stopAnimating];
                                     [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
                                 }
                             }
                            completed:^(UIImage *image1, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                if (image1)
                                {
                                    imageV.image = image1;
                                }
                            }];
        [indicator stopAnimating];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
    }
    else
    {
//        self.avatarLab.hidden=NO;
        [indicator stopAnimating];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
    }
    self.usernameL.text=[NSString stringWithFormat:@"%@",f_name];
    self.f_nameTXT.text=[NSString stringWithFormat:@"%@",f_name];
    self.l_nameTXT.text=[NSString stringWithFormat:@"%@",l_name];
    self.emailTXT.text=[NSString stringWithFormat:@"%@",email];
    self.contactTXT.text=[NSString stringWithFormat:@"%@",contact];
    _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    _tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:_tapRecognizer];
 
}
-(void)viewDidAppear:(BOOL)animated
{
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(FetchingPlanInfo) userInfo:nil repeats:NO];
    if([app.view isEqualToString:@"upgradeplan"])
    {
        [blurEffectView removeFromSuperview];
        self.UpgradeOptionView.hidden=YES;
    }
}
-(void)FetchingPlanInfo
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *email=[prefs valueForKey:@"email"];
    NSString *contact=[prefs valueForKey:@"contact"];

    NSString *urlString = [[NSString alloc]initWithFormat:@"%@plan.php",app.Service ];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *myRequestString =[NSString stringWithFormat:@"{\"email\":\"%@\",\"contact\":\"%@\"}",email,contact];
    NSData *requestData = [NSData dataWithBytes:[myRequestString UTF8String] length:[myRequestString length]];
    [request setTimeoutInterval:200];
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
        
        NSLog(@"plan.php   ::::  %@",dictionary);
        
        if (!dictionary)
        {
            NSLog(@"%s: JSONObjectWithData error: %@; data = %@", __FUNCTION__, parseError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            return ;
        }
        else
        {
//          NSLog(@"ds :%@",dictionary);
            imageV.imageURL=[NSURL URLWithString:[NSString stringWithFormat:@"%@",[dictionary valueForKey:@"profile"]]];
            NSString *Photoname=[NSString stringWithFormat:@"%@",[dictionary valueForKey:@"profile"]];
            NSArray *items = [Photoname componentsSeparatedByString:@"/"];
            NSString *ImageName = [items lastObject];//ImageNamed
            NSString* fileName = [[ImageName lastPathComponent] stringByDeletingPathExtension];//remove extension
            if([fileName isEqualToString:@"no-img"])
            {
                self.avatarLab.hidden=NO;
            }
            else
            {
                [prefs setObject:Photoname forKey:@"photo"];
                self.avatarLab.hidden=YES;
            }
            self.PlanName.text=[NSString stringWithFormat:@"%@",[dictionary valueForKey:@"plan"]];
            self.NonShringPlanName.text=[NSString stringWithFormat:@"%@",[dictionary valueForKey:@"plan"]];
            self.totalSize.text=[NSString stringWithFormat:@"%@ of %@",[dictionary valueForKey:@"used"],[dictionary valueForKey:@"total"]];
            self.NonShringtotalSize.text=[NSString stringWithFormat:@"%@ of %@",[dictionary valueForKey:@"used"],[dictionary valueForKey:@"total"]];
            NSString *process=[NSString stringWithFormat:@"%@",[dictionary valueForKey:@"percentage"]];
            float processValue=[process floatValue];
            self.Percantage.text=[NSString stringWithFormat:@"%.02f",processValue];
             self.NonShringPercantage.text=[NSString stringWithFormat:@"%.02f",processValue];
            NSString* formattedNumber = [NSString stringWithFormat:@"%.02f", processValue/100];
            float finalValue=[formattedNumber floatValue];
            self.ProgressView.progress=finalValue;
            self.NonShringProgressView.progress=finalValue;
            
            [indicator stopAnimating];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
        }
    }];
}
- (IBAction)show:(id)sender
{
      [self.sidebarVC showHideSidebar];
}
- (void)panDetected:(UIPanGestureRecognizer*)recoginzer
{
    [self.sidebarVC panDetected:recoginzer];
}
-(IBAction)ChangeProBtnPressed:(id)sender
{
    NSString *other1 = @"Take a photo";
    NSString *other2 = @"Choose Existing Photo";
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
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
        imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.sourceType =  UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
    else if(buttonIndex==1)
    {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
        imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickerController.sourceType= UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    imageV.image = nil;
    self.avatarLab.hidden=YES;
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if(!image)image=info[UIImagePickerControllerOriginalImage];
    NSLog(@"Scaling photo");
    imageV.image  = image;
    NSData *imagedata = UIImageJPEGRepresentation(imageV.image, 0.25);
    strEncoded = [NSString stringWithFormat:@"%@",[Base64 encode:imagedata]];
    status=@"profile";
    [self SaveProfile];
//    imageV.layer.cornerRadius = imageV.frame.size.width/2;
    [self dismissViewControllerAnimated:YES completion:nil];
}

//Upgrade plan for the storage      *******************//
-(IBAction)UpgradePlanBtnPressed:(id)sender
{
    if([planstatus isEqualToString:@"0"])
    {
        self.UpgradeKeyBTN.hidden=YES;
        self.UpgradeMerBtn.frame=CGRectMake(self.UpgradeMerBtn.frame.origin.x, 110, self.UpgradeMerBtn.frame.size.width,self.UpgradeMerBtn.frame.size.height);
    }
    else
    {
        self.UpgradeMerBtn.frame=CGRectMake(self.UpgradeMerBtn.frame.origin.x,self.UpgradeMerBtn.frame.origin.y, self.UpgradeMerBtn.frame.size.width,self.UpgradeMerBtn.frame.size.height);
        self.UpgradeKeyDoneBtn.hidden=YES;
        self.UpgradeKeyTXT.hidden=YES;
        self.UpgradeKeyLbl.hidden=YES;
        self.UpgradeMerBtn.hidden=NO;
        self.UpgradeKeyBTN.hidden=NO;
    }
    if (!UIAccessibilityIsReduceTransparencyEnabled())
    {
        self.scrollView.backgroundColor = [UIColor clearColor];
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.frame = self.view.bounds;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.scrollView addSubview:blurEffectView];
    }
    else
    {
        self.view.backgroundColor = [UIColor blackColor];
    }
    self.UpgradeBtnView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
    [self.UpgradeOptionView addSubview:self.UpgradeBtnView];
    [UIView animateWithDuration:0.3/1.5 animations:^{
        self.UpgradeBtnView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3/2 animations:^{
            self.UpgradeBtnView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3/2 animations:^{
                self.UpgradeBtnView.transform = CGAffineTransformIdentity;
            }];
        }];
    }];
    self.UpgradeOptionView.hidden=NO;
}
-(IBAction)UpgradeOptBackBtnPressed:(id)sender
{
    [blurEffectView removeFromSuperview];
    self.UpgradeOptionView.hidden=YES;
}
-(IBAction)UpgradeKeyBTNPressed:(id)sender
{
    self.UpgradeKeyDoneBtn.hidden=NO;
    self.UpgradeKeyTXT.hidden=NO;
    self.UpgradeKeyLbl.hidden=NO;
    self.UpgradeMerBtn.hidden=YES;
    self.UpgradeKeyBTN.hidden=YES;
}
-(IBAction)UpgradeMerBtnPressed:(id)sender
{
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(HideUpgradeOptionView) userInfo:nil repeats:NO];
    [self performSegueWithIdentifier:@"upgradePlanVC" sender:self];
}
-(void)HideUpgradeOptionView
{
    [blurEffectView removeFromSuperview];
    self.UpgradeOptionView.hidden=YES;
}
-(IBAction)UpgradeKeyDoneBtnPressed:(id)sender
{
    if([self.UpgradeKeyTXT.text isEqualToString:@""])
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please Fill Field First." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [indicator stopAnimating];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
        [av show];
    }
    else
    {
        [indicator startAnimating];
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(UpgradeKeyCheck) userInfo:nil repeats:NO];
    }
}
-(void)UpgradeKeyCheck
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *contact=[prefs valueForKey:@"contact"];
    NSString *urlString = [[NSString alloc]initWithFormat:@"%@voucher_plan.php",app.Service ];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *myRequestString =[NSString stringWithFormat:@"{\"key\":\"%@\",\"contact\":\"%@\"}",self.UpgradeKeyTXT.text,contact];
    NSData *requestData = [NSData dataWithBytes:[myRequestString UTF8String] length:[myRequestString length]];
    [request setTimeoutInterval:200];
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
         
         NSLog(@"voucher_plan.php   ::::  %@",dictionary);
         
         if (!dictionary)
         {
             NSLog(@"%s: JSONObjectWithData error: %@; data = %@", __FUNCTION__, parseError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
             return ;
         }
         else
         {
//             NSLog(@"%@",dictionary);
             NSString *success=[NSString stringWithFormat:@"%@",[dictionary valueForKey:@"success"]];
//             NSLog(@"%@",success);
             self.UpgradeKeyTXT.text=@"";
             if([success isEqualToString:@"1"])
             {
                 [blurEffectView removeFromSuperview];
                 self.UpgradeOptionView.hidden=YES;
                 [self viewDidAppear:YES];
                 [indicator stopAnimating];
                 [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;

             }
             else
             {
                 UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Error!" message:@"This voucher is already used." preferredStyle:UIAlertControllerStyleAlert];
                 UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"Ok"
                                                                       style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction *action) {
                                                                         self.UpgradeKeyTXT.text=@"";
                                                                     }];
                 [controller addAction:alertAction];
                 [self presentViewController:controller animated:YES completion:nil];
            }
             [indicator stopAnimating];
             [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
         }
     }];
}
////////////////////////////////////////////////////////////
-(void)SaveProfile
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *email=[prefs valueForKey:@"email"];
    NSString *contact=[prefs valueForKey:@"contact"];
    NSString *urlString = [[NSString alloc]initWithFormat:@"%@edit_profile.php",app.Service ];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *myRequestString =[NSString stringWithFormat:@"{\"email\":\"%@\",\"contact\":\"%@\",\"photo\":\"%@\"}",email,contact,strEncoded];
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
        
        
        NSLog(@"edit_profile.php   ::::  %@",dictionary);
        
        if (!dictionary)
        {
            NSLog(@"%s: JSONObjectWithData error: %@; data = %@", __FUNCTION__, parseError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            return ;
        }
        else
        {
//            NSLog(@"%@",dictionary);

            NSString *photo=[dictionary valueForKey:@"photo"];
            [prefs setObject:photo forKey:@"photo"];
        }
    }];
}
-(IBAction)HintBtnPressed:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"www.web.flippycloud.com/hints.aspx"];
    if ([[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url];
    }
}
-(IBAction)HelpBtnPressed:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"www.web.flippycloud.com/help.aspx"];
    if ([[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url];
    }
}
-(IBAction)EditBtnPressed:(id)sender
{
    self.UpdateView.hidden=NO;
}
-(IBAction)SaveBtnPressed:(id)sender
{
    [self SaveData];
}
-(void)SaveData
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *emailSTR=[prefs valueForKey:@"email"];//CurrentPoints
    NSString *contact=[prefs valueForKey:@"contact"];
//  NSString *password=[prefs valueForKey:@"password"];
    NSString *Newpassword=[prefs valueForKey:@"newpassword"];
    NSString *photoStr;
    if(strEncoded == NULL)
    {
        photoStr=@"";
    }
    else
    {
        photoStr=strEncoded;
    }
    NSString *pass;
    if([self.OldpassTXT.text isEqualToString:@""])
    {
        pass=Newpassword;
    }
    else
    {
        pass=self.OldpassTXT.text;
    }
    NSString *urlString = [[NSString alloc]initWithFormat:@"%@edit.php",app.Service ];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *myRequestString =[NSString stringWithFormat:@"{\"email\":\"%@\",\"contact\":\"%@\",\"f_name\":\"%@\",\"l_name\":\"%@\",\"address\":\"%@\",\"oldpassword\":\"%@\",\"newpassword\":\"%@\",\"photo\":\"%@\"}",emailSTR,contact,self.f_nameTXT.text,self.l_nameTXT.text,self.addTXT.text,pass,self.passTXT.text,photoStr];
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
        
        NSLog(@"edit.php   ::::  %@",dictionary);
        
        
        
        if (!dictionary)
        {
            NSLog(@"%s: JSONObjectWithData error: %@; data = %@", __FUNCTION__, parseError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            return ;
        }
        else
        {
            if([[dictionary valueForKey:@"Success"] isEqualToString:@"1"])
            {
                NSString *email =[dictionary valueForKey:@"email"];
                NSString *phone =[dictionary valueForKey:@"contact"];
                NSString *UserId =[dictionary valueForKey:@"id"];
                NSString *f_name =[dictionary valueForKey:@"f_name"];//f_name
                NSString *l_name =[dictionary valueForKey:@"l_name"];
                NSString *NewPass=[dictionary valueForKey:@"newpassword"];
                if([status isEqualToString:@"profile"])
                {
                    NSString *photo =[dictionary valueForKey:@"photo"];
                    imageV.imageURL =[NSURL URLWithString:photo];
                    [prefs setObject:photo forKey:@"photo"];
                }
                [prefs setObject:email forKey:@"email"];
                [prefs setObject:phone forKey:@"contact"];
                [prefs setObject:UserId forKey:@"id"];
                [prefs setObject:f_name forKey:@"f_name"];
                [prefs setObject:l_name forKey:@"l_name"];
                [prefs setObject:NewPass forKey:@"newpassword"];
                self.usernameL.text=[NSString stringWithFormat:@"%@",f_name];
                self.UpdateView.hidden=YES;
                self.OldpassTXT.text=@"";
                self.passTXT.text=@"";
            }
            else
            {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error!" message:@"Something Wrong!" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:ok];
                [self presentViewController:alertController animated:YES completion:nil];
            }
        }
    }];
}

-(IBAction)BackBtnPressed:(id)sender
{
    self.UpdateView.hidden=YES;
}

//**********   textfileds methods
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


-(IBAction)ShareBtnPressed:(id)sender
{
    pointsToday = pointsToday +10;
    
    if(pointsToday <= 200)
    {
        if (pointsToday % 20)
        {
            NSLog(@"odd");

            NSURL *myWebsite = [NSURL URLWithString:SharedItem];
            SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            [tweetSheet setInitialText:@"First post from my iPhone app"];
            [tweetSheet addURL:myWebsite];
            [tweetSheet addImage:[UIImage imageNamed:[NSString stringWithFormat:@"icon_latest.png"]]];
            
            [tweetSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
                switch (result) {
                    case SLComposeViewControllerResultCancelled:
                    {
                        UIAlertView *Alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Cancel Or Fail To Share" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [Alert show];
                    }
                    break;
                    case SLComposeViewControllerResultDone:
                    {
                        UIAlertView *Alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Point Added Successfully." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
                        NSString *TodayPoints=[NSString stringWithFormat:@"%d",pointsToday];
                         NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                        [prefs setObject:TodayPoints forKey:@"pointsToday"];
                        [self PointsCount];
                        [Alert show];
                    }
                        NSLog(@"Post Sucessful");
                        break;
                    default:
                        break;
                }
            }];
            [self presentViewController:tweetSheet animated:YES completion:Nil];
        }
        else
        {
            NSLog(@"even");
            NSURL *messageBody = [NSURL URLWithString:SharedItem];
            UIImage *imageToShare = [UIImage imageNamed:[NSString stringWithFormat:@"icon_latest.png"]];

            NSMutableArray *all =[[NSMutableArray alloc]init];
            
            [all addObject:messageBody];
            [all addObject:imageToShare];
            SSCWhatsAppActivity *whatsAppActivity = [[SSCWhatsAppActivity alloc] init];
            UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[messageBody,imageToShare] applicationActivities:@[whatsAppActivity]];
            [activityViewController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
                NSString *ServiceMsg = nil;
                if (! completed){
                    UIAlertView *Alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Cancel Or Fail To Share" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [Alert show];
                }
                else
                {
                    UIAlertView *Alert = [[UIAlertView alloc] initWithTitle:ServiceMsg message:@"Point Added Successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    
                    [Alert show];
                  
                    NSString *TodayPoints=[NSString stringWithFormat:@"%d",pointsToday];
                    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                    [prefs setObject:TodayPoints forKey:@"pointsToday"];

                    [self PointsCount];
                }
            }];
            [self presentViewController:activityViewController animated:YES completion:nil];
        }
    }
    else
    {
            UIAlertView *Alert = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Your Today's limit is over" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [Alert show];
    }
}
-(void)PointsCount
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *email=[prefs valueForKey:@"email"];
    NSString *contact=[prefs valueForKey:@"contact"];
    NSString *point=[NSString stringWithFormat:@"%d",pointsToday];
    NSString *urlString = [[NSString alloc]initWithFormat:@"%@sharing_points.php",app.Service ];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *myRequestString =[NSString stringWithFormat:@"{\"email\":\"%@\",\"contact\":\"%@\",\"point\":\"%@\"}",email,contact,point];
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
        NSLog(@"edit_profile.php   ::::  %@",dictionary);
        if (!dictionary)
        {
            NSLog(@"%s: JSONObjectWithData error: %@; data = %@", __FUNCTION__, parseError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            return ;
        }
        else
        {
            [self GetPointDetail];
            NSString *CurrentPoints =[NSString stringWithFormat:@"%@",[[dictionary valueForKey:@"posts"]valueForKey:@"points"]];
            [prefs setObject:CurrentPoints forKey:@"CurrentPoints"];
        }
    }];
}
-(void)GetPointDetail
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *email=[prefs valueForKey:@"email"];
    NSString *contact=[prefs valueForKey:@"contact"];
    NSString *urlString = [[NSString alloc]initWithFormat:@"%@get_pointdetail.php",app.Service ];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *myRequestString =[NSString stringWithFormat:@"{\"email\":\"%@\",\"contact\":\"%@\"}",email,contact];
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
        
        
        NSLog(@"edit_profile.php   ::::  %@",dictionary);
        
        if (!dictionary)
        {
            NSLog(@"%s: JSONObjectWithData error: %@; data = %@", __FUNCTION__, parseError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            return ;
        }
        else
        {
            TotalPoints =[NSString stringWithFormat:@"%@",[[dictionary valueForKey:@"posts"]valueForKey:@"total_point"]];
            SharedItem =[NSString stringWithFormat:@"%@",[[dictionary valueForKey:@"posts"]valueForKey:@"shareditem"]];
            NSString *TodayPoints=[NSString stringWithFormat:@"%@",[[dictionary valueForKey:@"posts"]valueForKey:@"today_point"]];
            pointsToday =[TodayPoints intValue];
            
            NSString *Totalpoint=[NSString stringWithFormat:@"Earn Points: %@",TotalPoints];
            self.TotalPointsLbl.text=[NSString stringWithFormat:@"%@",Totalpoint];
            
            NSString *title= [NSString stringWithFormat:@"Earn Points With Share  %d",pointsToday];

            [self.RewordBtn setTitle:title forState:UIControlStateNormal];
            
            PointsTotal =[TotalPoints intValue];

        }
    }];

}
-(IBAction)TermsNConditionBtnPressed:(id)sender
{
    NSString *urlstring=[NSString stringWithFormat:@"http://pricingterms.flippycloud.com"];
    NSURL *URL=[NSURL URLWithString:urlstring];
    BOOL checkurl=[[UIApplication sharedApplication]canOpenURL:URL];
    if(checkurl){
        [[UIApplication sharedApplication] openURL:URL];
    }else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"No suitable App installed" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }

}
-(IBAction)PrivacyPolicyBtnPressed:(id)sender
{
    NSString *urlstring=[NSString stringWithFormat:@"http://privacy.flippycloud.com/"];
    NSURL *URL=[NSURL URLWithString:urlstring];
    BOOL checkurl=[[UIApplication sharedApplication]canOpenURL:URL];
    if(checkurl){
        [[UIApplication sharedApplication] openURL:URL];
    }else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"No suitable App installed" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
