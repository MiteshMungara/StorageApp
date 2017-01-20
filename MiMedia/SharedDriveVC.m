//
//  SharedDriveVC.m
//  Flippy Cloud
//
//  Created by isquare3 on 11/17/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import "SharedDriveVC.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import "DriveVc.h"

@interface SharedDriveVC ()
{
    AppDelegate *app;
    NSMutableArray *SharedDriveNameArr,*SharedEmailArr;
    int index;
    UIActivityIndicatorView *indicator;
}

@end

@implementation SharedDriveVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initPB];
    app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    [indicator startAnimating];
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(SharedDriveGet) userInfo:nil repeats:NO];
}
-(void)SharedDriveGet
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
        NSString *UserId = [prefs valueForKey:@"id"];
        NSString *urlString = [[NSString alloc]initWithFormat:@"http://46.166.173.116/FlippyCloud/webservices/all_shared_drive_ios.php"];
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSString *myRequestString =[NSString stringWithFormat:@"{\"user_id\":\"%@\"}",UserId];
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
             
             NSLog(@"all_shared_drive_ios.php   ::::  %@",dictionary);
             
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
                     SharedDriveNameArr =[[dictionary valueForKey:@"posts"]valueForKey:@"drive_name"];
                     SharedEmailArr = [[dictionary valueForKey:@"posts"] valueForKey:@"share_email"];
                     [indicator stopAnimating];
                     [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
                     [self.collectionView reloadData];
                 }
                 else
                 {
                     self.collectionView.hidden=YES;
                     UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"You have no shared drive." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                     [indicator stopAnimating];
                     [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
                     [av show];

                 }
             }
         }];
    }
}

// ------  collection view start   -------
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
            return SharedDriveNameArr.count;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier=@"Cell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell = nil;
    if (cell == nil)
    {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    }
    UILabel *distance = (UILabel *)[cell viewWithTag:1];
    distance.text=[SharedDriveNameArr objectAtIndex:indexPath.row];
    UIButton *JoinBtn=(UIButton *)[cell viewWithTag:2];
    [JoinBtn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    index=(int)indexPath.row;
    return cell;
}

-(void)buttonPressed:(UIButton*)sender
{
    [indicator startAnimating];
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:(UICollectionViewCell *)[[[sender superview]superview]superview]];
    NSLog(@"%@  %ld",[SharedDriveNameArr objectAtIndex:indexPath.row],(long)indexPath.row);
    
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
        NSString *UserId = [prefs valueForKey:@"id"];
        NSString *email=[prefs valueForKey:@"email"];
        NSString *urlString = [[NSString alloc]initWithFormat:@"http://46.166.173.116/FlippyCloud/webservices/join_drive_status.php"];
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSString *myRequestString =[NSString stringWithFormat:@"{\"user_id\":\"%@\",\"email\":\"%@\",\"drive_name\":\"%@\"}",UserId,email,[NSString stringWithFormat:@"%@",[SharedDriveNameArr objectAtIndex:indexPath.row]]];
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
             
             NSLog(@"join_drive_status.php   ::::  %@",dictionary);
             
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
                     NSLog(@"%@",success);
                     UINavigationController *navigationController = (UINavigationController *)app.window.rootViewController;
                     UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                     DriveVc *Main = (DriveVc *)[mainStoryboard instantiateViewControllerWithIdentifier: @"DriveVc"];
                     [navigationController pushViewController:Main animated:NO];
                     app.DriveArrNameCopy=NULL;
                     [indicator stopAnimating];
                     [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;

//                     [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(SharedDriveGet) userInfo:nil repeats:NO];
                 }
             }
         }];
    }
}


-(IBAction)BackBtnPressed:(id)sender
{
    app.DriveArrNameCopy=NULL;
    if([app.view isEqualToString:@"intro"])
    {
        UINavigationController *navigationController = (UINavigationController *)app.window.rootViewController;
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        DriveVc *MainPage = (DriveVc*)[mainStoryboard instantiateViewControllerWithIdentifier: @"DriveVc"];
        [navigationController pushViewController:MainPage animated:YES];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:TRUE];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
