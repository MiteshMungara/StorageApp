//
//  DriveSubVC.m
//  Flippy Cloud
//
//  Created by iSquare5 on 29/08/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import "DriveSubVC.h"
#import "DriveVc.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import "ImageViewVC.h"
#import "AsyncImageView.h"
#import "ImageCollectionViewCell.h"
#import "BIZGrid4plus1CollectionViewLayout.h"
#include "ChatingVC.h"

@interface DriveSubVC ()
{
    AppDelegate *app;
    NSArray *imageCollArr,*CollImageArr;
    UIActivityIndicatorView *indicator;
    CGFloat animateDistance;
}
@end
int countIndexed=0;
@implementation DriveSubVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    [self initPB];
    
    NSLog(@"%@",app.MemberListArr);
    NSLog(@"%lu",(unsigned long)app.InviteEmailArrCopy.count);
    if([app.view isEqualToString:@"contact"])
    {
        self.MemberShowOrAddView.hidden=NO;
        [self.MemberListTableView reloadData];
    }
    else
    {
        self.MemberShowOrAddView.hidden=YES;
    }
  

    
    if([app.DriveStatusStr isEqualToString:@"1"])
    {
        self.DeleteDriveLBL.text=[NSString stringWithFormat:@"Leave Drive"];
        self.MemberListShowOrAddBtn.hidden=YES;
        MemberImgView.hidden=YES;
    }
    else
    {
        self.DeleteDriveLBL.text=[NSString stringWithFormat:@"Delete Drive"];
        self.MemberListShowOrAddBtn.hidden=NO;
        MemberImgView.hidden=NO;
    }

    self.DriveNamelbl.text=app.superDriveName;
    self.EmptyView.hidden=NO;
    self.CollectionView.hidden=YES;
    [indicator startAnimating];
    UIView *RenameColl = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [self.RenameDriveTXT setLeftViewMode:UITextFieldViewModeAlways];
    [self.RenameDriveTXT setLeftView:RenameColl];
    _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    _tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:_tapRecognizer];
}
-(IBAction)BackBtnPressed:(id)sender
{
//    NSLog(@"%@",app.DriveArrNameCopy);
    UINavigationController *navigationController = (UINavigationController *)app.window.rootViewController;
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    DriveVc *Main = (DriveVc *)[mainStoryboard instantiateViewControllerWithIdentifier: @"DriveVc"];
    [navigationController pushViewController:Main animated:NO];
    [indicator startAnimating];
}
-(void)viewWillAppear:(BOOL)animated
{
    [indicator startAnimating];
    [self DriveVC];
}
-(void)DriveVC
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
        NSString *phone=[prefs valueForKey:@"contact"];
        NSString *urlString = [[NSString alloc]initWithFormat:@"http://46.166.173.116/FlippyCloud/webservices/get_drive_image_ios.php"];//temp
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSString *myRequestString;
        if([app.DriveStatusStr isEqualToString:@"1"])
        {
//            app.DriveStatusStr=@"";
            myRequestString =[NSString stringWithFormat:@"{\"drive_name\":\"%@\",\"email\":\"%@\",\"drive_status\":\"Shared\"}",app.superDriveName,email];
        }
        else
        {
            myRequestString =[NSString stringWithFormat:@"{\"drive_name\":\"%@\",\"email\":\"%@\",\"contact\":\"%@\"}",app.superDriveName,email,phone];
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
                    self.EmptyView.hidden=YES;
                    self.CollectionView.hidden=NO;
                    photosCollectionCV.hidden=NO;
                    CollImageArr=[[dictionary valueForKey:@"posts"]valueForKey:@"images"];
                    
                    NSString *totalPhotos =[NSString stringWithFormat:@"%lu photos",(unsigned long)CollImageArr.count];
                    [prefs setObject:totalPhotos forKey:@"totalPhotos"];
                    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                    NSString *PhotosColl =[[[dictionary valueForKey:@"posts"]valueForKey:@"images"]lastObject];
                    [prefs setObject:PhotosColl forKey:@"PhotosColl"];
                    [indicator stopAnimating];
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
                    [photosCollectionCV reloadData];
                }
                else
                {
                    self.EmptyView.hidden=NO;
                    self.CollectionView.hidden=YES;
                    [indicator stopAnimating];
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
                }
            }
        }];
    }
}
-(IBAction)MenuBtnPressed:(id)sender
{
    
    self.DeleteDriveView.hidden=NO;
     self.ShareDriveView.hidden=NO;
    if([app.DriveStatusStr isEqualToString:@"1"])
    {
            self.RenameDriveView.hidden=YES;
    }
    else
    {
        self.RenameDriveView.hidden=NO;
    }

    if([self.MenuBtn isSelected])
    {
        [self animationhide];
        [UIView animateWithDuration:1.5
                         animations:^{
                             self.CollectionView.frame=CGRectMake(0,self.MenuBtn.frame.origin.y+50, self.CollectionView.frame.size.width, self.CollectionView.frame.size.height+100);
                         }];
        [sender setSelected:NO];
    }
    else
    {
        [self animationView];
        [UIView animateWithDuration:1.5
                         animations:^{
                             self.CollectionView.frame=CGRectMake(0,self.MenuBtn.frame.origin.y+150, self.CollectionView.frame.size.width,
                                                self.CollectionView.frame.size.height-100);
                         }];
        [sender setSelected:YES];
    }
}
-(void)animationView
{
    [UIView animateWithDuration:1.5
                     animations:^{
                         self.RenameDriveView.frame =CGRectMake(self.MenuBtn.frame.origin.x-20,90,60,60);
                         self.DeleteDriveView.frame =CGRectMake(self.RenameDriveView.frame.origin.x- 65,self.RenameDriveView.frame.origin.y,self.RenameDriveView.frame.size.width,self.RenameDriveView.frame.size.height);
                         self.ShareDriveView.frame =CGRectMake(self.DeleteDriveView.frame.origin.x- 65,self.DeleteDriveView.frame.origin.y,self.DeleteDriveView.frame.size.width,self.DeleteDriveView.frame.size.height);
                         self.RenameDriveView.alpha=1;
                         self.DeleteDriveView.alpha=1;
                         self.ShareDriveView.alpha=1;
                     }];
}
-(void)animationhide
{
    [UIView animateWithDuration:1.5
                     animations:^{
                         self.RenameDriveView.frame =CGRectMake(self.MenuBtn.frame.origin.x - 20,90,60,60);
                         self.DeleteDriveView.frame =self.RenameDriveView.frame;
                         self.ShareDriveView.frame =self.RenameDriveView.frame;
                         self.RenameDriveView.alpha=0.0;
                         self.DeleteDriveView.alpha=0.0;
                         self.ShareDriveView.alpha=0.0;
                     }];
}
-(IBAction)RenameCollBtnPressed:(id)sender
{
    self.RenameView.hidden=NO;
    NSLog(@"RenameCollBtnPressed show");
    self.RenameDriveTXT.text=[NSString stringWithFormat:@"%@",app.superDriveName];
    [self animationhide];
    [UIView animateWithDuration:1.5
                     animations:^{
                         self.CollectionView.frame=CGRectMake(0,self.MenuBtn.frame.origin.y+150, self.CollectionView.frame.size.width, self.CollectionView.frame.size.height+100);
                     }];
}
-(IBAction)RenameBackBtnPressed:(id)sender
{
    self.RenameView.hidden=YES;
    NSLog(@"RenameCollBtnPressed hide");
    [self animationhide];
    [UIView animateWithDuration:1.5
                     animations:^{
                         self.CollectionView.frame=CGRectMake(0,self.MenuBtn.frame.origin.y+50, self.view.frame.size.width, self.view.frame.size.height);
                     }];
    [self.RenameBackBtn setSelected:NO];
}
-(IBAction)DeleteCollBtnPressed:(id)sender
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
        NSString *urlString = [[NSString alloc]initWithFormat:@"%@delete_drive.php",app.Service];
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSString *myRequestString =[NSString stringWithFormat:@"{\"email\":\"%@\",\"drive_name\":\"%@\",\"drive_id\":\"%@\",\"contact\":\"%@\"}",email,app.superDriveName,app.CollIdarr,phone];
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
            NSLog(@"delete_drive.php  ::::  %@",dictionary);
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
                    app.DriveArrNameCopy=NULL;
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
-(IBAction)ChatBtnPressed:(id)sender
{
    UINavigationController *navigationController = (UINavigationController *)app.window.rootViewController;
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    ChatingVC *Main = (ChatingVC *)[mainStoryboard instantiateViewControllerWithIdentifier: @"ChatingVC"];
    [navigationController pushViewController:Main animated:NO];
}
-(IBAction)AddMemberBtnPressed:(id)sender//addMemberVC
{
     [self performSegueWithIdentifier:@"addMemberVC" sender:self];
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
-(IBAction)RenameDoneBtnPressed:(id)sender
{
    [indicator startAnimating];
    self.DriveNamelbl.text=app.superCollName;
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
        NSString *myRequestString =[NSString stringWithFormat:@"{\"email\":\"%@\",\"contact\":\"%@\",\"oldName\":\"%@\",\"id\":\"%@\",\"newName\":\"%@\"}",email,phone,app.superDriveName,app.CollIdarr,self.RenameDriveTXT.text];
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
                    self.DriveNamelbl.text=[NSString stringWithFormat:@"%@",[[dictionary valueForKey:@"posts"]valueForKey:@"newcollection"]];
                    self.RenameView.hidden=YES;
                    [self animationhide];
                    [UIView animateWithDuration:1.5
                                     animations:^{
                                         self.CollectionView.frame=CGRectMake(0,self.MenuBtn.frame.origin.y+50, self.view.frame.size.width, self.view.frame.size.height);
                                     }];
                    [indicator stopAnimating];
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
                }
                else
                {
                    [self animationhide];
                    [UIView animateWithDuration:1.5
                                     animations:^{
                                         self.CollectionView.frame=CGRectMake(0,self.MenuBtn.frame.origin.y+50, self.view.frame.size.width, self.view.frame.size.height);
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

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return CollImageArr.count;
}

- (ImageCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[ImageCollectionViewCell reuseIdentifier] forIndexPath:indexPath];
    UIImageView *recipeImageView = (UIImageView *)[cell viewWithTag:100];
   
    
    NSString *imsage=[CollImageArr objectAtIndex:indexPath.row];
       NSString* urlTextEscaped = [imsage stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:[NSURL URLWithString:urlTextEscaped]
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
    countIndexed = -1;
    app.view=@"DriveSub";
    if([app.DriveStatusStr isEqualToString:@"1"])
    {
        app.DriveSelectedImageStatusStr=@"1";
    }
    app.CollImgURL=[CollImageArr objectAtIndex:indexPath.row];
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
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor clearColor];
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

-(IBAction)MemberShowOrAddBtnPressed:(id)sender
{
    self.MemberShowOrAddView.hidden=NO;
    [self.MemberListTableView reloadData];
}
-(IBAction)MemberViewBackBtnPressed:(id)sender
{
    self.MemberShowOrAddView.hidden=YES;
}

#pragma mark - Table View ChatView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return app.MemberListArr.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"MemberCell";
    UITableViewCell * cell =  [self.MemberListTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell =  [self.MemberListTableView dequeueReusableCellWithIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
    }
    UILabel *EmailAddLbl=(UILabel *)[cell viewWithTag:22];
    EmailAddLbl.text=[NSString stringWithFormat:@"%@",[app.MemberListArr objectAtIndex:indexPath.row]];
    
    UILabel *Namelabel= (UILabel *)[cell viewWithTag:21];
    NSString *EmailAdd=[NSString stringWithFormat:@"%@",[app.MemberListArr objectAtIndex:indexPath.row]];
    Namelabel.text =[NSString stringWithFormat:@"%@",[EmailAdd substringToIndex:1]];
   
    
    return cell;
}
//*************



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
//    NSLog(@"%@",app.DriveArrNameCopy);
    
}

@end
