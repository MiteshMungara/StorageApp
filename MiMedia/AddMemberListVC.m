//
//  AddMemberListVC.m
//  Flippy Cloud
//
//  Created by isquare3 on 11/22/16.
//  Copyright © 2016 MitSoft. All rights 
//
//
//
//
//
//√√√√√√√√√√√√    Setting Page     √√√√√√√√√√√√√√√√√
//
//
//

#import "AddMemberListVC.h"
#import <Contacts/Contacts.h>
#import "AppDelegate.h"
#import "AsyncImageView.h"
#import "DriveVc.h"
#import "Reachability.h"

@interface AddMemberListVC ()

{
    AppDelegate *app;
    UIActivityIndicatorView *indicator;
    UITableViewCell * Tcell;
}

@end

@implementation AddMemberListVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    [self initPB];
    if(app.SettingProfilePic == NULL)
    {
        SettingImage.image=[UIImage imageNamed:@"img.png"];
    }
    else
    {
        SettingImage.imageURL=[NSURL URLWithString:app.SettingProfilePic];        
    }
    DriveName.text=app.superDriveName;
    [[DeleteDriveBtn layer] setBorderWidth:2.0f];
    [[DeleteDriveBtn layer] setBorderColor:[UIColor redColor].CGColor];
    [[LeaveDriveBtn layer] setBorderWidth:2.0f];
    [[LeaveDriveBtn layer] setBorderColor:[UIColor redColor].CGColor];

    if([app.DriveStatusStr isEqualToString:@"1"])
    {
        LeaveDriveBtn.hidden=NO;
        DeleteDriveBtn.hidden=YES;
        Drivetxt.enabled = NO;
    }
    else
    {
        Drivetxt.enabled = YES;
        LeaveDriveBtn.hidden=YES;
        DeleteDriveBtn.hidden=NO;
    }
}
-(IBAction)AddMemberBackBtnPressed:(id)sender
{
     [self.navigationController popViewControllerAnimated:YES];
}
-(IBAction)DriveEditBtnPressed:(id)sender
{
    DriveName.hidden=YES;
    Drivetxt.hidden=NO;
    Drivetxt.text=[NSString stringWithFormat:@"%@",app.superDriveName];
    DriveNameEditBtn.hidden=YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    NSLog(@"done %@",Drivetxt.text);
    DriveName.text=[NSString stringWithFormat:@"%@",Drivetxt.text];
    Drivetxt.hidden=YES;
    DriveName.hidden=NO;
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
        NSString *myRequestString =[NSString stringWithFormat:@"{\"email\":\"%@\",\"contact\":\"%@\",\"oldName\":\"%@\",\"id\":\"%@\",\"newName\":\"%@\"}",email,phone,app.superDriveName,app.CollIdarr,Drivetxt.text];
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
-(IBAction)DeleteDriveBtnPressed:(id)sender
{
    [indicator startAnimating];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"Are you sure you want to Delete this FlippyDrive?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                         {
                             [self DeleteOrLeaveDrive];
                         }];
    UIAlertAction* cancle = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action)
                             {
                             }];
    [alertController addAction:ok];
    [alertController addAction:cancle];
    [self presentViewController:alertController animated:YES completion:nil];
}
-(IBAction)LeaveDriveBtnPressed:(id)sender
{
    [indicator startAnimating];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"Are you sure you want to leave this FlippyDrive?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Leave" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                         {
                             [self DeleteOrLeaveDrive];
                         }];
    UIAlertAction* cancle = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action)
                             {
                             }];
    [alertController addAction:ok];
    [alertController addAction:cancle];
    [self presentViewController:alertController animated:YES completion:nil];
}
-(void)DeleteOrLeaveDrive
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
                    UINavigationController *navigationController = (UINavigationController *)app.window.rootViewController;
                    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                    DriveVc *Main = (DriveVc *)[mainStoryboard instantiateViewControllerWithIdentifier: @"DriveVc"];
                    [navigationController pushViewController:Main animated:NO];
                    app.DriveArrNameCopy=NULL;
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return app.MemberListArr.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   return 60;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"EmailTableView";
    Tcell =  [InvitedEmaillist dequeueReusableCellWithIdentifier:cellIdentifier];
    if (Tcell == nil)
    {
        Tcell =  [InvitedEmaillist dequeueReusableCellWithIdentifier:cellIdentifier];
        Tcell.backgroundColor = [UIColor clearColor];
    }
    NSString *EmailAdd=[NSString stringWithFormat:@"%@",[app.MemberListArr objectAtIndex:indexPath.row]];
    UILabel *ContactFirstChar=(UILabel *)[Tcell viewWithTag:1];
    ContactFirstChar.text=[NSString stringWithFormat:@"%@",[EmailAdd substringToIndex:1]];
    UILabel *ContactEmail=(UILabel *)[Tcell viewWithTag:2];
    ContactEmail.text=[NSString stringWithFormat:@"%@",[app.MemberListArr objectAtIndex:indexPath.row]];
    return Tcell;
}
-(IBAction)ShowInviteEmailBtnPressed:(id)sender
{
    InvitedEmailsListview.hidden=NO;
    [InvitedEmaillist reloadData];
}
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
