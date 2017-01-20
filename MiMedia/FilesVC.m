//
//  FilesVC.m
//  Flippy Cloud
//
//  Created by iSquare5 on 29/08/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import "FilesVC.h"
#import "AppDelegate.h"
#import "SidebarViewController.h"
#import "Reachability.h"

@interface FilesVC ()
{
    AppDelegate *app;
    NSArray *FilesArry;
    UIActivityIndicatorView *indicator;

}
@property (nonatomic, retain) SidebarViewController* sidebarVC;

@end

@implementation FilesVC

- (UIStatusBarStyle)preferredStatusBarStyle {
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
    [indicator startAnimating];
    if([[Reachability sharedReachability] internetConnectionStatus] == NotReachable){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Check Internet Connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [indicator stopAnimating];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
        [av show];
    }
    else
    {
        [self GetFiles];
    }
   
}
-(void)GetFiles
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *contact=[prefs valueForKey:@"contact"];
    NSString *urlString = [[NSString alloc]initWithFormat:@"%@contact_files.php",app.Service ];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *myRequestString =[NSString stringWithFormat:@"{\"contact\":\"%@\"}",contact];
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
        
        NSLog(@"contact_files.php  ::::  %@",dictionary);
        
        if (!dictionary)
        {
            NSLog(@"%s: JSONObjectWithData error: %@; data = %@", __FUNCTION__, parseError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            return ;
        }
        else
        {
            if([[dictionary valueForKey:@"success"] isEqualToString:@"1"])
            {
                FilesArry=[[dictionary valueForKey:@"posts"]valueForKey:@"files"];
                self.introview.hidden=YES;
                self.FileListView.hidden=NO;
                [self.FileListView reloadData];
                [indicator stopAnimating];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
            }
            else
            {
                self.introview.hidden=NO;
                self.FileListView.hidden=YES;
                [indicator stopAnimating];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
            }
        }
    }];

}
// ------  collection view start   -------
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(FilesArry == NULL)
    {
        return 0;
    }
    else
    {
        return FilesArry.count;        
    }
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
        static NSString *identifier=@"Cell";
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        UILabel *music=(UILabel *)[cell viewWithTag:100];
        NSString *asd=[NSString stringWithFormat:@"%@",[FilesArry objectAtIndex:indexPath.row]];
        NSArray *parts = [asd componentsSeparatedByString:@"/"];
        NSString *filename = [parts lastObject];
        app.ReadingFileNameStr =filename;
        music.text=[NSString stringWithFormat:@"%@",filename];
        return cell;
}
-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"selected Coll:%ld",(long)indexPath.row);
   /****************** open files (start) *****************/
    NSString *urlstring=[NSString stringWithFormat:@"%@",[FilesArry objectAtIndex:indexPath.row]];
    
//    
//    NSURL *URL=[NSURL URLWithString:urlstring];
    
    
    
   
    NSString *urlTextEscaped = [urlstring stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *URL = [NSURL URLWithString: urlTextEscaped];
    
    
    NSString *asd=[NSString stringWithFormat:@"%@",[FilesArry objectAtIndex:indexPath.row]];
    NSArray *parts = [asd componentsSeparatedByString:@"/"];
    NSString *filename = [parts lastObject];
    app.ReadingFileNameStr =filename;

    app.ReadFileUrlStr=urlstring;
    
    
    
//    [self performSegueWithIdentifier:@"ReadFileVC" sender:self];
    BOOL checkurl=[[UIApplication sharedApplication]canOpenURL:URL];
    if(checkurl){
        [[UIApplication sharedApplication] openURL:URL];
    }else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"No suitable App installed" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    /*************** open files(stop) ********************/
}
// ------  stop   -------//

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (IBAction)show:(id)sender
{
    [self.sidebarVC showHideSidebar];
}
- (void)panDetected:(UIPanGestureRecognizer*)recoginzer
{
    [self.sidebarVC panDetected:recoginzer];
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
