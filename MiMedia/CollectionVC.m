//
//  CollectionVC.m
//  Flippy Cloud
//
//  Created by iSquare5 on 18/08/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import "CollectionVC.h"
#import "SidebarViewController.h"
#import "AppDelegate.h"
#import "CollectionSubVC.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "Reachability.h"
#import "AsyncImageView.h"
#define LL_IS_IOS_6_OR_EARLIER [[UIDevice currentDevice] systemVersion].floatValue < 7.0

@interface CollectionVC ()
{
    UIVisualEffectView *blurEffectView;
    CGFloat animateDistance;
    UIView *collView;
    UIActivityIndicatorView *indicator;
    NSArray *CollName,*CollNameCopy,*TotalCount,*CollImageArr,*CollIDArr;
    NSMutableArray *CoverImageARR;
    AppDelegate *app;
    NSString *PhotosColl;
}
@property (nonatomic, retain) SidebarViewController* sidebarVC;
@end

@implementation CollectionVC
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
     [self initPB];
    self.CollectionTxt.text=@"";
    UIView *CollectionTxt = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [self.CollectionTxt setLeftViewMode:UITextFieldViewModeAlways];
    [self.CollectionTxt setLeftView:CollectionTxt];
    [indicator startAnimating];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    PhotosColl=[prefs valueForKey:@"PhotosColl"];
    self.sidebarVC = [[SidebarViewController alloc] init];
    [self.sidebarVC setBgRGB:0x000000];
    self.sidebarVC.view.frame  = self.view.bounds;
    [self.view addSubview:self.sidebarVC.view];
    [self.sidebarVC showHideSidebar];
    
    _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    _tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:_tapRecognizer];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    if(app.CollectionNameArrCopy == NULL)
    {
        [indicator startAnimating];
        [self CollCount];
    }
    else
    {
        [indicator stopAnimating];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;

        self.collectionView.hidden=NO;
        self.mainView.hidden=YES;
        [self.collectionView reloadData];
    }
}
-(void)CollCount
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
        NSString *contact = [prefs valueForKey:@"contact"];
        NSString *urlString = [[NSString alloc]initWithFormat:@"http://46.166.173.116/FlippyCloud/webservices/all_collection_ios.php"];
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
            NSLog(@"all_collection_ios.php  ::::  %@",dictionary);
            if (!dictionary)
            {
                NSLog(@"%s: JSONObjectWithData error: %@; data = %@", __FUNCTION__, parseError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                return ;
            }
            else
            {
//                NSLog(@"%@",dictionary);
                NSString *success=[dictionary valueForKey:@"success"];
                if([success isEqualToString:@"1"])
                {
                    TotalCount = [[dictionary valueForKey:@"posts"]valueForKey:@"Collection Name"];
                    CollIDArr =[[dictionary valueForKey:@"posts"]valueForKey:@"id"];
                    CoverImageARR = [[[dictionary valueForKey:@"posts"]valueForKey:@"images"]valueForKey:@"images"];
                    
                    
                   
                    app.CollectionCoverImageArrCopy =[[NSMutableArray alloc]init];
                    app.CollectionIdArrCopy =[[NSMutableArray alloc]init];
                    app.CollectionNameArrCopy =[[NSMutableArray alloc]init];
                    
                    app.CollectionNameArrCopy = [TotalCount copy];
                    app.CollectionIdArrCopy = [CollIDArr copy];
                    app.CollectionCoverImageArrCopy = [CoverImageARR copy];

                    
                    [prefs setObject:TotalCount forKey:@"collection_name"];
                    self.collectionView.hidden=NO;
                    self.mainView.hidden=YES;
                    [self.collectionView reloadData];
                    [indicator stopAnimating];
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
                }
                else
                {
                    [prefs removeObjectForKey:@"collection_name"];
                    self.mainView.hidden=NO;
                    self.collectionCreateView.hidden=YES;
                    self.mainHeaderView.hidden=NO;
                    self.collectionView.hidden=YES;
                    [indicator stopAnimating];
                    [blurEffectView removeFromSuperview];
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
                }
            }
        }];
    }
}
- (IBAction)show:(id)sender
{
    [self.sidebarVC showHideSidebar];
}
-(IBAction)createBtnPressed:(id)sender
{
    [indicator startAnimating];
    self.collectionCreateView.hidden=YES;
    self.mainHeaderView.hidden=NO;
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(CreateCollection) userInfo:nil repeats:NO];
}

-(void)CreateCollection
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
        NSString *urlString = [[NSString alloc]initWithFormat:@"%@collection.php",app.Service];
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSString *myRequestString =[NSString stringWithFormat:@"{\"collection_name\":\"%@\",\"email\":\"%@\"}",self.CollectionTxt.text,email];
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
            
            NSLog(@"collection.php  ::::  %@",dictionary);
            if (!dictionary)
            {
                NSLog(@"%s: JSONObjectWithData error: %@; data = %@", __FUNCTION__, parseError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                return ;
            }
            else
            {
              [prefs setObject:TotalCount forKey:@"collection_name"];
                NSString *success=[dictionary valueForKey:@"success"];
                if([success isEqualToString:@"1"])
                {
                    TotalCount =[[dictionary valueForKey:@"posts"]valueForKey:@"collection_name"];
                    CollIDArr =[[dictionary valueForKey:@"posts"]valueForKey:@"id"];
                    self.mainView.hidden=YES;
                    self.mainHeaderView.hidden=NO;
                    self.collectionView.hidden=NO;
                    app.CollectionNameArrCopy= NULL;
                    [self viewWillAppear:YES];
                    self.CollectionTxt.text=@"";
                }
                else
                {
                    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Something Wrong." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [indicator stopAnimating];
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
                    [av show];
                    self.mainView.hidden=NO;
                    self.collectionCreateView.hidden=NO;
                    self.mainHeaderView.hidden=YES;
                }
                [indicator stopAnimating];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
            }
        }];
    }
}
-(IBAction)addBtnPressed:(id)sender
{
    self.collectionCreateView.hidden=NO;
    self.mainHeaderView.hidden=YES;
    collView=(UIView *)[self.view viewWithTag:1];
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = self.view.bounds;
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [collView addSubview:blurEffectView];
}
-(IBAction)CreateCollBtnPressed:(id)sender
{
    self.collectionCreateView.hidden=NO;
    self.mainHeaderView.hidden=YES;
    collView=(UIView *)[self.view viewWithTag:1];
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = self.view.bounds;
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [collView addSubview:blurEffectView];
}
-(IBAction)CancelBtnPressed:(id)sender
{
    self.collectionCreateView.hidden=YES;
    [blurEffectView removeFromSuperview];
    self.mainHeaderView.hidden=NO;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(TotalCount ==NULL)
    {
        return  app.CollectionNameArrCopy.count;
    }
    else
    {
        return  TotalCount.count;
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

    UIImageView *CoverImage=(UIImageView *)[ cell viewWithTag:100];
    CoverImage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    UIImageView *CoverBlurImage=(UIImageView *)[ cell viewWithTag:101];
    UILabel *distance = (UILabel *)[cell viewWithTag:1];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = self.view.bounds;
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [CoverBlurImage addSubview:blurEffectView];

    if(TotalCount ==NULL)
    {
        NSString *CoverImageStr=[NSString stringWithFormat:@"%@",[app.CollectionCoverImageArrCopy objectAtIndex:indexPath.row]];
        if([CoverImageStr isEqualToString:@"<null>"] || [CoverImageStr isEqualToString:@"(\n)"])
        {
            
            CoverImage.image=[UIImage imageNamed:@"img.png"];
            CoverBlurImage.image=[UIImage imageNamed:@""];
        }
        else
        {
            CoverImage.imageURL=[NSURL URLWithString:[NSString stringWithFormat:@"%@", [app.CollectionCoverImageArrCopy objectAtIndex:indexPath.row]]];
            CoverBlurImage.imageURL=[NSURL URLWithString:[NSString stringWithFormat:@"%@", [app.CollectionCoverImageArrCopy objectAtIndex:indexPath.row]]];
        }
        
        
        distance.text=[app.CollectionNameArrCopy objectAtIndex:indexPath.row];
    }
    else
    {
       
        
        NSString *CoverImageStr=[NSString stringWithFormat:@"%@",[CoverImageARR objectAtIndex:indexPath.row]];
        if([CoverImageStr isEqualToString:@"<null>"] || [CoverImageStr isEqualToString:@"(\n)"])
        {
            
            CoverImage.image=[UIImage imageNamed:@"img.png"];
            CoverBlurImage.image=[UIImage imageNamed:@""];
        }
        else
        {
            CoverImage.imageURL=[NSURL URLWithString:[NSString stringWithFormat:@"%@", [CoverImageARR objectAtIndex:indexPath.row]]];
            CoverBlurImage.imageURL=[NSURL URLWithString:[NSString stringWithFormat:@"%@", [CoverImageARR objectAtIndex:indexPath.row]]];
        }

       
        distance.text=[TotalCount objectAtIndex:indexPath.row];
    }
    return cell;
}
-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  NSLog(@"%@",TotalCount);
    if(TotalCount == NULL)
    {
     
        app.superCollName=[app.CollectionNameArrCopy objectAtIndex:indexPath.row];
        app.CollIdarr=[app.CollectionIdArrCopy objectAtIndex:indexPath.row];
    }
    else
    {
        app.superCollName=[TotalCount objectAtIndex:indexPath.row];
        app.CollIdarr=[CollIDArr objectAtIndex:indexPath.row];
    }

    [self performSegueWithIdentifier:@"CollSubVC" sender:self];
}
// ------  stop   -------//




//-------- textfield methods
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
//---stop

-(void)panDetected:(UIPanGestureRecognizer*)recoginzer
{
    [self.sidebarVC panDetected:recoginzer];
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
-(void)didReceiveMemoryWarning
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
