//
//  SidebarViewController.m
//  LLBlurSidebar
//
//  Created by Lugede on 14/11/20.
//  Copyright (c) 2014年 lugede.cn. All rights reserved.
//

#import "SidebarViewController.h"
#import "HomeVC.h"
#import "PhotosVC.h"
#import "VideosVC.h"
#import "MusicVC.h"
#import "FavoriteVC.h"
#import "UserProfileVC.h"
#import "CollectionVC.h"
#import "DriveVc.h"
#import "UploadSettingVC.h"
#import "BackupRestoreVc.h"
#import "FilesVC.h"
#import "ManuallyPhotosVC.h"
#import "ManuallyVideosVC.h"
#import "IntroVC.h"
#import "NotificationVC.h"
#import "AffiliateProVC.h"


@interface SidebarViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSArray *titles;
    NSArray *images;
    NSString *Status;

}
@property (nonatomic, retain) UITableView* menuTableView;

@end

@implementation SidebarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    appDel = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    self.contentView.frame=CGRectMake(0,20, 220, 650);
    self.menuTableView = [[UITableView alloc] initWithFrame:self.contentView.bounds];
    self.menuTableView.frame=CGRectMake(0, 0, 220, 650);
    self.menuTableView.separatorColor=[UIColor clearColor];
    self.menuTableView.backgroundColor = [UIColor clearColor];
    self.menuTableView.delegate = self;
    self.menuTableView.dataSource = self;
    CAGradientLayer *leftGradient = [CAGradientLayer layer];
    leftGradient.frame = CGRectMake(0, 0,self.menuTableView.frame.size.width, self.menuTableView.frame.size.height+100);
   leftGradient.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:0.5].CGColor, (id)[UIColor clearColor].CGColor, nil];
     [leftGradient setStartPoint:CGPointMake(1.5, 0.1)];
    [leftGradient setEndPoint:CGPointMake(0.5, 0.1)];
    [ self.menuTableView.layer addSublayer:leftGradient];
    
    

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *f_name=[prefs valueForKey:@"f_name"];
    NSString *upgradeplan=[prefs valueForKey:@"upgradeplan"];
    
    if([upgradeplan isEqualToString:@"nil"])
    {
        NSLog(@"nilv");
        if([upgradeplan isEqualToString:@"0"])
        {
            titles = [NSArray arrayWithObjects:@"Home",@"Photos",@"Videos",@"Music",@"Files",@"Favorites",@"Collections",@"Flippydrive",[NSString stringWithFormat:@"%@'s profile",f_name],@"Notification", nil];
            images = [NSArray arrayWithObjects:@"home1Menu.png",@"images1Menu.png",@"videos1.png",@"music1Menu.png",@"files1Menu.png",@"Favorite1.png",@"collection1Menu.png",@"flippy_drive1Menu.png",@"profile1Menu.png",@"Notification.png",nil];
            [self.contentView addSubview:self.menuTableView];
        }
        else
        {
            titles = [NSArray arrayWithObjects:@"Home",@"Photos",@"Videos",@"Music",@"Files",@"Favorites",@"Collections",@"Flippydrive",@"Affiliate Program",[NSString stringWithFormat:@"%@'s profile",f_name],@"Notification", nil];
            images = [NSArray arrayWithObjects:@"home1Menu.png",@"images1Menu.png",@"videos1.png",@"music1Menu.png",@"files1Menu.png",@"Favorite1.png",@"collection1Menu.png",@"flippy_drive1Menu.png",@"webnetwork-.png",@"profile1Menu.png",@"Notification.png",nil];
            [self.contentView addSubview:self.menuTableView];
        }

    }
    else
    {
        NSLog(@"nil");
    


    NSString *email=[prefs valueForKey:@"email"];
    NSString *contact=[prefs valueForKey:@"contact"];
    NSString *urlString = [[NSString alloc]initWithFormat:@"%@upgradeplan.php",appDel.Service ];
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
        
        
        NSLog(@"upgradeplan.php   ::::  %@",dictionary);
        
        if (!dictionary)
        {
            NSLog(@"%s: JSONObjectWithData error: %@; data = %@", __FUNCTION__, parseError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            return ;
        }
        else
        {
            appDel.planstatusStr=[dictionary valueForKey:@"upgradeplan"];
            appDel.CurrentversionSTR=[dictionary valueForKey:@"current_version"];
            
            NSString *upgradeplan =[NSString stringWithFormat:@"%@",appDel.planstatusStr];
            
            [prefs setObject:upgradeplan forKey:@"upgradeplan"];
            Status=[NSString stringWithFormat:@"%@",appDel.planstatusStr];
            //    Status=@"0";
            
            if([Status isEqualToString:@"0"])
            {
                titles = [NSArray arrayWithObjects:@"Home",@"Photos",@"Videos",@"Music",@"Files",@"Favorites",@"Collections",@"Flippydrive",[NSString stringWithFormat:@"%@'s profile",f_name],@"Notification", nil];
                images = [NSArray arrayWithObjects:@"home1Menu.png",@"images1Menu.png",@"videos1.png",@"music1Menu.png",@"files1Menu.png",@"Favorite1.png",@"collection1Menu.png",@"flippy_drive1Menu.png",@"profile1Menu.png",@"Notification.png",nil];
                [self.contentView addSubview:self.menuTableView];
            }
            else
            {
                titles = [NSArray arrayWithObjects:@"Home",@"Photos",@"Videos",@"Music",@"Files",@"Favorites",@"Collections",@"Flippydrive",@"Affiliate Program",[NSString stringWithFormat:@"%@'s profile",f_name],@"Notification", nil];
                images = [NSArray arrayWithObjects:@"home1Menu.png",@"images1Menu.png",@"videos1.png",@"music1Menu.png",@"files1Menu.png",@"Favorite1.png",@"collection1Menu.png",@"flippy_drive1Menu.png",@"webnetwork-.png",@"profile1Menu.png",@"Notification.png",nil];
                [self.contentView addSubview:self.menuTableView];
            }

        }
    }];
        }

    
    
    
}
-(void)CloseButtonClicked:sender
{
    [self showHideSidebar];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return titles.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *sidebarMenuCellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sidebarMenuCellIdentifier];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sidebarMenuCellIdentifier] ;
        cell.backgroundColor = [UIColor clearColor];
    }
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.frame=CGRectMake(0, 60, 200, 508);
    bgColorView.backgroundColor = [UIColor clearColor];
    [cell setSelectedBackgroundView:bgColorView];
    cell.textLabel.textColor = [UIColor blackColor];
    
    if(indexPath.row == 4 || indexPath.row == 7)
    {
        UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0,55,self.menuTableView.frame.size.width,1)];
        line.backgroundColor = [UIColor blackColor];
        [cell addSubview:line];

    }

    UILabel *titleL = [[UILabel alloc]initWithFrame:CGRectMake(50, 14, 150, 20)];
    [titleL setFont: [cell.textLabel.font fontWithSize: 16]];
//    [titleL setFont:[cell.textLabel.font ]]
    titleL.text = [NSString stringWithFormat:@"%@", [titles objectAtIndex:indexPath.row]];
    [cell.contentView addSubview:titleL];
   UIImageView *facebookImage = [[UIImageView alloc] initWithFrame:CGRectMake(17, 14, 23, 23)];
    facebookImage.image =[UIImage imageNamed:[NSString stringWithFormat:@"%@",[images objectAtIndex:indexPath.row]]];
    [cell.contentView addSubview:facebookImage];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if([Status isEqualToString:@"0"])
    {
        
        if (indexPath.row==0) {
            UINavigationController *navigationController = (UINavigationController *)appDel.window.rootViewController;
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            IntroVC *MainPage = (IntroVC*)[mainStoryboard instantiateViewControllerWithIdentifier: @"IntroVC"];
            [navigationController pushViewController:MainPage animated:YES];
            
            
        }
        else if (indexPath.row==1) {//ManuallyPhotosVC
            
            //        UINavigationController *navigationController = (UINavigationController *)appDel.window.rootViewController;
            //        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            //
            //        PhotosVC *Listroute = (PhotosVC *)[mainStoryboard instantiateViewControllerWithIdentifier: @"PhotosVC"];
            //        [navigationController pushViewController:Listroute animated:YES];
            appDel.view=@"direct";
            UINavigationController *navigationController = (UINavigationController *)appDel.window.rootViewController;
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            
            ManuallyPhotosVC *Listroute = (ManuallyPhotosVC *)[mainStoryboard instantiateViewControllerWithIdentifier: @"ManuallyPhotosVC"];
            [navigationController pushViewController:Listroute animated:YES];
            
            
        }
        else if (indexPath.row==2) {//ViedosVC
            //        UINavigationController *navigationController = (UINavigationController *)appDel.window.rootViewController;
            //        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            //
            //        VideosVC *Listroute = (VideosVC *)[mainStoryboard instantiateViewControllerWithIdentifier: @"VideosVC"];
            //        [navigationController pushViewController:Listroute animated:YES];  ManuallyVideosVC
            
            UINavigationController *navigationController = (UINavigationController *)appDel.window.rootViewController;
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            
            ManuallyVideosVC *Listroute = (ManuallyVideosVC *)[mainStoryboard instantiateViewControllerWithIdentifier: @"ManuallyVideosVC"];
            [navigationController pushViewController:Listroute animated:YES];
            
            
            
        }
        else if (indexPath.row==3) {//MusicVC
            
            UINavigationController *navigationController = (UINavigationController *)appDel.window.rootViewController;
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            
            MusicVC *Listroute = (MusicVC *)[mainStoryboard instantiateViewControllerWithIdentifier: @"MusicVC"];
            [navigationController pushViewController:Listroute animated:YES];
            
            
        }
        else if (indexPath.row==4) {//FilesVC
            UINavigationController *navigationController = (UINavigationController *)appDel.window.rootViewController;
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            
            FilesVC *Listroute = (FilesVC *)[mainStoryboard instantiateViewControllerWithIdentifier: @"FilesVC"];
            [navigationController pushViewController:Listroute animated:YES];
            
        }
        
        else if (indexPath.row==5) {//FavoriteVC
            
            UINavigationController *navigationController = (UINavigationController *)appDel.window.rootViewController;
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            
            FavoriteVC *Listroute = (FavoriteVC *)[mainStoryboard instantiateViewControllerWithIdentifier: @"FavoriteVC"];
            [navigationController pushViewController:Listroute animated:YES];
            
            
        }
        else if (indexPath.row==6) {//CollectionVC
            
            UINavigationController *navigationController = (UINavigationController *)appDel.window.rootViewController;
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            
            CollectionVC *Listroute = (CollectionVC *)[mainStoryboard instantiateViewControllerWithIdentifier: @"CollectionVC"];
            [navigationController pushViewController:Listroute animated:YES];
            
            
            
        }
        else if (indexPath.row==7) {//DriveVc
            UINavigationController *navigationController = (UINavigationController *)appDel.window.rootViewController;
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            
            DriveVc *Listroute = (DriveVc *)[mainStoryboard instantiateViewControllerWithIdentifier: @"DriveVc"];
            [navigationController pushViewController:Listroute animated:YES];
            
            
            
            
        }
        //    else if (indexPath.row==8) {//UploadSettingVC
        ////        UINavigationController *navigationController = (UINavigationController *)appDel.window.rootViewController;
        ////        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        ////
        ////        UploadSettingVC *Listroute = (UploadSettingVC *)[mainStoryboard instantiateViewControllerWithIdentifier: @"UploadSettingVC"];
        ////        [navigationController pushViewController:Listroute animated:YES];
        //        UINavigationController *navigationController = (UINavigationController *)appDel.window.rootViewController;
        //        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        //
        //        UserProfileVC *Listroute = (UserProfileVC *)[mainStoryboard instantiateViewControllerWithIdentifier: @"UserProfileVC"];
        //        [navigationController pushViewController:Listroute animated:YES];
        ////
        //    }
        else if (indexPath.row==8) //UserProfileVC
        {
            //        UINavigationController *navigationController = (UINavigationController *)appDel.window.rootViewController;
            //        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            //
            //        UserProfileVC *Listroute = (UserProfileVC *)[mainStoryboard instantiateViewControllerWithIdentifier: @"UserProfileVC"];
            //        [navigationController pushViewController:Listroute animated:YES];
            UINavigationController *navigationController = (UINavigationController *)appDel.window.rootViewController;
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            
            UserProfileVC *Listroute = (UserProfileVC *)[mainStoryboard instantiateViewControllerWithIdentifier: @"UserProfileVC"];
            [navigationController pushViewController:Listroute animated:YES];
            
        }
        else
        {
            UINavigationController *navigationController = (UINavigationController *)appDel.window.rootViewController;
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            
            NotificationVC *Listroute = (NotificationVC *)[mainStoryboard instantiateViewControllerWithIdentifier: @"NotificationVC"];
            [navigationController pushViewController:Listroute animated:YES];
        }

    }
    else
    {
        
        if (indexPath.row==0) {
            UINavigationController *navigationController = (UINavigationController *)appDel.window.rootViewController;
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            IntroVC *MainPage = (IntroVC*)[mainStoryboard instantiateViewControllerWithIdentifier: @"IntroVC"];
            [navigationController pushViewController:MainPage animated:YES];
            
            
        }
        else if (indexPath.row==1) {//ManuallyPhotosVC
            
            //        UINavigationController *navigationController = (UINavigationController *)appDel.window.rootViewController;
            //        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            //
            //        PhotosVC *Listroute = (PhotosVC *)[mainStoryboard instantiateViewControllerWithIdentifier: @"PhotosVC"];
            //        [navigationController pushViewController:Listroute animated:YES];
            appDel.view=@"direct";
            UINavigationController *navigationController = (UINavigationController *)appDel.window.rootViewController;
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            
            ManuallyPhotosVC *Listroute = (ManuallyPhotosVC *)[mainStoryboard instantiateViewControllerWithIdentifier: @"ManuallyPhotosVC"];
            [navigationController pushViewController:Listroute animated:YES];
            
            
        }
        else if (indexPath.row==2) {//ViedosVC
            //        UINavigationController *navigationController = (UINavigationController *)appDel.window.rootViewController;
            //        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            //
            //        VideosVC *Listroute = (VideosVC *)[mainStoryboard instantiateViewControllerWithIdentifier: @"VideosVC"];
            //        [navigationController pushViewController:Listroute animated:YES];  ManuallyVideosVC
            
            UINavigationController *navigationController = (UINavigationController *)appDel.window.rootViewController;
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            
            ManuallyVideosVC *Listroute = (ManuallyVideosVC *)[mainStoryboard instantiateViewControllerWithIdentifier: @"ManuallyVideosVC"];
            [navigationController pushViewController:Listroute animated:YES];
            
            
            
        }
        else if (indexPath.row==3) {//MusicVC
            
            UINavigationController *navigationController = (UINavigationController *)appDel.window.rootViewController;
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            
            MusicVC *Listroute = (MusicVC *)[mainStoryboard instantiateViewControllerWithIdentifier: @"MusicVC"];
            [navigationController pushViewController:Listroute animated:YES];
            
            
        }
        else if (indexPath.row==4) {//FilesVC
            UINavigationController *navigationController = (UINavigationController *)appDel.window.rootViewController;
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            
            FilesVC *Listroute = (FilesVC *)[mainStoryboard instantiateViewControllerWithIdentifier: @"FilesVC"];
            [navigationController pushViewController:Listroute animated:YES];
            
        }
        
        else if (indexPath.row==5) {//FavoriteVC
            
            UINavigationController *navigationController = (UINavigationController *)appDel.window.rootViewController;
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            
            FavoriteVC *Listroute = (FavoriteVC *)[mainStoryboard instantiateViewControllerWithIdentifier: @"FavoriteVC"];
            [navigationController pushViewController:Listroute animated:YES];
            
            
        }
        else if (indexPath.row==6) {//CollectionVC
            
            UINavigationController *navigationController = (UINavigationController *)appDel.window.rootViewController;
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            
            CollectionVC *Listroute = (CollectionVC *)[mainStoryboard instantiateViewControllerWithIdentifier: @"CollectionVC"];
            [navigationController pushViewController:Listroute animated:YES];
            
            
            
        }
        else if (indexPath.row==7) {//DriveVc
            UINavigationController *navigationController = (UINavigationController *)appDel.window.rootViewController;
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            
            DriveVc *Listroute = (DriveVc *)[mainStoryboard instantiateViewControllerWithIdentifier: @"DriveVc"];
            [navigationController pushViewController:Listroute animated:YES];
            
            
            
            
        }
        //    else if (indexPath.row==8) {//UploadSettingVC
        ////        UINavigationController *navigationController = (UINavigationController *)appDel.window.rootViewController;
        ////        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        ////
        ////        UploadSettingVC *Listroute = (UploadSettingVC *)[mainStoryboard instantiateViewControllerWithIdentifier: @"UploadSettingVC"];
        ////        [navigationController pushViewController:Listroute animated:YES];
        //        UINavigationController *navigationController = (UINavigationController *)appDel.window.rootViewController;
        //        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        //
        //        UserProfileVC *Listroute = (UserProfileVC *)[mainStoryboard instantiateViewControllerWithIdentifier: @"UserProfileVC"];
        //        [navigationController pushViewController:Listroute animated:YES];
        ////
        //    }
        else if (indexPath.row==8) //AffiliateProVC
        {
            
            UINavigationController *navigationController = (UINavigationController *)appDel.window.rootViewController;
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            
            AffiliateProVC *Listroute = (AffiliateProVC *)[mainStoryboard instantiateViewControllerWithIdentifier: @"AffiliateProVC"];
            [navigationController pushViewController:Listroute animated:YES];
        }
        else if (indexPath.row==9) //UserProfileVC
        {
            //        UINavigationController *navigationController = (UINavigationController *)appDel.window.rootViewController;
            //        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            //
            //        UserProfileVC *Listroute = (UserProfileVC *)[mainStoryboard instantiateViewControllerWithIdentifier: @"UserProfileVC"];
            //        [navigationController pushViewController:Listroute animated:YES];
            UINavigationController *navigationController = (UINavigationController *)appDel.window.rootViewController;
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            
            UserProfileVC *Listroute = (UserProfileVC *)[mainStoryboard instantiateViewControllerWithIdentifier: @"UserProfileVC"];
            [navigationController pushViewController:Listroute animated:YES];
            
        }
        else
        {
            UINavigationController *navigationController = (UINavigationController *)appDel.window.rootViewController;
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            
            NotificationVC *Listroute = (NotificationVC *)[mainStoryboard instantiateViewControllerWithIdentifier: @"NotificationVC"];
            [navigationController pushViewController:Listroute animated:YES];
        }

        
    }
         [self showHideSidebar];
}
@end
