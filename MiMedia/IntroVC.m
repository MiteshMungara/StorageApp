//
//  IntroVC.m
//  MiMedia
//
//  Created by iSquare5 on 08/08/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import "IntroVC.h"
#import "pageViewVC.h"
#import "LoginVC.h"
#import "AppDelegate.h"
#import "BackupRestoreVc.h"
#import "BackupSyncVC.h"
#import "ManuallyPhotosVC.h"
#import "SidebarViewController.h"
#import "Reachability.h"
#import "SharedDriveVC.h"
#import <Contacts/Contacts.h>
@interface IntroVC ()
{
    UIActivityIndicatorView *indicator;
    AppDelegate *app;
    NSArray *imagesArry,*imagesArryCopy;
    NSMutableArray *Contact,*resultArray;
    NSMutableArray *contactno,*firstname,*lastname,*emailARR,*phoneno,*ContactEmails,*InvitedEmailArr,*CoverImageARR,*FullNameArr;
    NSMutableArray *selectedContacts,*SharedEmailIDArr,*SelectMobileNo,*Demo;
     NSString *statusContact,*phoneNumber,*CoEmail,*FirstnameStr,*LastnameStr, *LocalPath,*CollectionName,*ContactToSendMsg;
    NSDictionary *ContactDic;
        NSMutableArray* differentIndex,*RemainingContacts;



}
 @property (nonatomic, retain) SidebarViewController* sidebarVC;
@end

@implementation IntroVC

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initPB];
    
        [indicator stopAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
    app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    differentIndex=[[NSMutableArray alloc]init];
    RemainingContacts=[[NSMutableArray alloc]init];
    self.sidebarVC = [[SidebarViewController alloc] init];
    [self.sidebarVC setBgRGB:0x000000];
    self.sidebarVC.view.frame  = self.view.bounds;
    [self.view addSubview:self.sidebarVC.view];
    [self.sidebarVC showHideSidebar];
    [self IntroVC];
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(UpgradPlanStatus) userInfo:nil repeats:NO];
    [self CheckInvitation];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

        dispatch_async(dispatch_get_main_queue(), ^
                       {
                                 [NSTimer scheduledTimerWithTimeInterval:0.9 target:self selector:@selector(CheckCurrentDate) userInfo:nil repeats:YES];
                       });
    });

    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(AffStatusS) userInfo:nil repeats:NO];
   
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self GetRegisteredContacts];
    });
    
    
}
-(void)CheckCurrentDate
{
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HHmmss"];
    NSString *DateStr =[NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:[NSDate date]]];
    int date =[DateStr intValue];
    if (date < 000001)
    {
        [self RefreshTodayPoint];
    }
}
-(void)RefreshTodayPoint
{
    NSString *urlString = [[NSString alloc]initWithFormat:@"http://46.166.173.116/FlippyCloud/webservices/ios/task_shadual.php"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod: @"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    NSError *error;
    NSURLResponse *response;
    NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingAllowFragments error:nil];
}
-(void)AffStatusS
{
    if([[Reachability sharedReachability] internetConnectionStatus] == NotReachable)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Check Internet Connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//      [indicator stopAnimating];
//      [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
        [av show];
    }
    else
    {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *contact=[prefs valueForKey:@"contact"];
        NSString *urlString =[[NSString alloc]initWithFormat:@"%@aff_ststus.php",app.Service];
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSString *myRequestString =[NSString stringWithFormat:@"{\"contact\":\"%@\"}",contact];
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
             NSLog(@"aff_ststus.php   ::::  %@",dictionary);
             
             if (!dictionary)
             {
                 NSLog(@"%s: JSONObjectWithData error: %@; data = %@", __FUNCTION__, parseError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                 return ;
             }
             else
             {
                 if([[dictionary valueForKey:@"success"] isEqualToString:@"1"])
                 {
                     app.AffStatus=[NSString stringWithFormat:@"1"];
                     app.AppTodayPoint=[[dictionary valueForKey:@"posts"]valueForKey:@"today_point"];
                     app.AppTotalPoints=[[dictionary valueForKey:@"posts"]valueForKey:@"total_points"];
                 }
                 else
                 {
                     app.AffStatus=[NSString stringWithFormat:@"0"];
                 }
             }
         }];
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
-(void)CheckInvitation
{
    if([[Reachability sharedReachability] internetConnectionStatus] == NotReachable)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Check Internet Connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];

        [av show];
    }
    else
    {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *UserId = [prefs valueForKey:@"id"];
        NSString *urlString =[[NSString alloc]initWithFormat:@"%@join_drive.php",app.Service];
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
             NSLog(@"join_drive.php   ::::  %@",dictionary);
             
             if (!dictionary)
             {
                 NSLog(@"%s: JSONObjectWithData error: %@; data = %@", __FUNCTION__, parseError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                 return ;
             }
             else
             {
                 app.SharedDriveOrNot=[NSString stringWithFormat:@"%@",[dictionary valueForKey:@"success"]];
                 if([[dictionary valueForKey:@"success"] isEqualToString:@"1"])
                 {
                     UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Info" message:@"You got a new invitation to join FlippyDrive." preferredStyle:UIAlertControllerStyleAlert];
                     UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                      {
                                          app.view=@"intro";
                                          UINavigationController *navigationController = (UINavigationController *)app.window.rootViewController;
                                          UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                                          SharedDriveVC *MainPage = (SharedDriveVC*)[mainStoryboard instantiateViewControllerWithIdentifier: @"SharedDriveVC"];
                                          [navigationController pushViewController:MainPage animated:YES];
                                    }];
                     UIAlertAction* cancle = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action)
                                              {
//                                                  [self animationhide];
                                              }];
                     [alertController addAction:ok];
                     [alertController addAction:cancle];
                     [self presentViewController:alertController animated:YES completion:nil];
                 }
             }
         }];
    }
}
-(void)UpgradPlanStatus
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *email=[prefs valueForKey:@"email"];
    NSString *contact=[prefs valueForKey:@"contact"];
    NSString *urlString = [[NSString alloc]initWithFormat:@"%@upgradeplan.php",app.Service ];
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
                app.planstatusStr=[dictionary valueForKey:@"upgradeplan"];
                app.CurrentversionSTR=[dictionary valueForKey:@"current_version"];
            }
    }];
}
-(void)IntroVC
{
    if([[Reachability sharedReachability] internetConnectionStatus] == NotReachable)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Check Internet Connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
    else
    {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSArray *imagePaths =[prefs valueForKey:@"image_path"];
        if(imagePaths !=NULL)
        {
            _pageImagesCopy = imagePaths;
        }
        else
        {
            NSString *urlString = [[NSString alloc]initWithFormat:@"%@introscreen.php",app.Service];
            NSURL *url = [NSURL URLWithString:urlString];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            [request setHTTPMethod: @"POST"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
            NSError *error;
            NSURLResponse *response;
            NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingAllowFragments error:nil];
                    _pageImages=[[dictionary valueForKey:@"posts"]valueForKey:@"image_path"];
                    [prefs setObject:_pageImages forKey:@"image_path"];
        }
        self.scrollView.contentSize=CGSizeMake(1880,568);
        self.PagingV.frame=CGRectMake(0, 35, self.view.frame.size.width,self.view.frame.size.height-125);
        self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
        self.pageViewController.dataSource = self;
        pageViewVC *startingViewController = [self viewControllerAtIndex:0];
        NSArray *viewControllers = @[startingViewController];
        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        self.pageViewController.view.frame = CGRectMake(self.PagingV.frame.origin.x, self.PagingV.frame.origin.y, self.PagingV.frame.size.width, self.PagingV.frame.size.height);
        [self addChildViewController:_pageViewController];
        [self.PagingV addSubview:_pageViewController.view];
        [self.pageViewController didMoveToParentViewController:self];
    }
}
//-*-*-*-*-     side menu
- (IBAction)show:(id)sender
{
    [self.sidebarVC showHideSidebar];
}
- (void)panDetected:(UIPanGestureRecognizer*)recoginzer
{
    [self.sidebarVC panDetected:recoginzer];
}
-(IBAction)PlusBtnPressed:(id)sender
{
    app.view=@"intro";
    UINavigationController *navigationController = (UINavigationController *)app.window.rootViewController;
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    ManuallyPhotosVC *Listroute = (ManuallyPhotosVC *)[mainStoryboard instantiateViewControllerWithIdentifier: @"ManuallyPhotosVC"];
    [navigationController pushViewController:Listroute animated:YES];
}

- (pageViewVC *)viewControllerAtIndex:(NSUInteger)index
{
    if([self.pageImages count] == 0)
    {
        if (([self.pageImagesCopy count] == 0) || (index >= [self.pageImagesCopy count]))
        {
            return nil;
        }
        // Create a new view controller and pass suitable data.
        pageViewVC *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"pageViewVC"];
        pageContentViewController.imageFile = self.pageImagesCopy[index];
        pageContentViewController.pageIndex = index;
        return pageContentViewController;
    }
    else
    {
        if (([self.pageImages count] == 0) || (index >= [self.pageImages count]))
        {
            return nil;
        }
        // Create a new view controller and pass suitable data.
        pageViewVC *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"pageViewVC"];
        pageContentViewController.imageFile = self.pageImages[index];
        pageContentViewController.pageIndex = index;
        return pageContentViewController;
    }
}

#pragma mark - Page View Controller Data Source
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((pageViewVC*) viewController).pageIndex;
    if ((index == 0) || (index == NSNotFound))
    {
        return nil;
    }
    index--;
    return [self viewControllerAtIndex:index];
}
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((pageViewVC*) viewController).pageIndex;
    if (index == NSNotFound)
    {
        return nil;
    }
    index++;
    if (index == [self.pageTitles count])
    {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}
- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    if([self.pageImages count] == 0)
    {
       return [self.pageImagesCopy count];
    }
    else
    {
        return [self.pageImages count];
    }
}
- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}
-(IBAction)BackupSyncBtnPressed:(id)sender
{
    [self performSegueWithIdentifier:@"backupSyncVC" sender:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
-(void)GetRegisteredContacts
{
    resultArray=[[NSMutableArray alloc]init];
    NSString *urlString = [[NSString alloc]initWithFormat:@"http://46.166.173.116/FlippyCloud/webservices/ios/test/flippy_users.php"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod: @"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    NSError *error;
    NSURLResponse *response;
    NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingAllowFragments error:nil];
    if([[jsonDictionary valueForKey:@"success"] isEqualToString:@"1"])
    {
        
        Contact=[[jsonDictionary valueForKey:@"posts"]valueForKey:@"contact"];
        app.RegContactList=[[jsonDictionary valueForKey:@"posts"]valueForKey:@"contact"];
        NSLog(@"app.RegContactList  ::::  %@",app.RegContactList);
        ContactEmails=[[NSMutableArray alloc]init];
        FullNameArr=[[NSMutableArray alloc]init];
        contactno=[[NSMutableArray alloc]init];
        
        selectedContacts=[[NSMutableArray alloc]init];
        SelectMobileNo=[[NSMutableArray alloc]init];
        CNAuthorizationStatus status1 = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        if(status1 == CNAuthorizationStatusDenied || status1 == CNAuthorizationStatusRestricted)
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
                 if(phoneNumber==nil)
                 {
                     phoneNumber=@"";
                 }
                 
                 
                 NSString *TrimedPhone =[[[phoneNumber stringByReplacingOccurrencesOfString:@")" withString:@""] stringByReplacingOccurrencesOfString:@"(" withString:@""]stringByReplacingOccurrencesOfString:@"-" withString:@""];
                 phoneNumber =[[TrimedPhone componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
                               componentsJoinedByString:@""];
                 
                 NSString *FullName=[NSString stringWithFormat:@"%@ %@",FirstnameStr,LastnameStr];
                 NSString *trimmed ;
                 
                 if([[FullName substringToIndex:1] isEqualToString:@" "])
                 {
                     trimmed = [FullName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                     int len = [trimmed length];
                     if(len == 0)
                     {
                         trimmed = FullName;
                     }
                 }
                 else
                 {
                     trimmed =FullName;
                 }
                 
                 [FullNameArr addObject:trimmed];
                 [contactno addObject:phoneNumber];
                 [ContactEmails addObject:CoEmail];
                 NSString *ContactStr=[NSString stringWithFormat:@"%@,%@",trimmed,phoneNumber];
                 [Demo addObject:ContactStr];
                 ContactDic = [NSDictionary dictionaryWithObject:FullNameArr forKey:@"FullName"];
//                 [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(ReloadColl) userInfo:nil repeats:NO];
                 [self ReloadColl];
                 }];
    }
    }
}

-(void)ReloadColl//contactList
{
    
    CollectionName =@"contact";
    NSLog(@"Demo ::::  %@",Demo);
    app.demoList =Demo;
    NSArray *RegContacts;
    NSLog(@"Contact Dic ::::  %@",[ContactDic valueForKey:@"FullName"]);
    for (int i=0; i<contactno.count; i++)
    {
        NSString *a=[contactno objectAtIndex:i];
        NSLog(@"%@",a);
  
        
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF =%@",a];
        RegContacts = [app.RegContactList filteredArrayUsingPredicate:pred];

        
        if(RegContacts.count !=0)
        {
            if(differentIndex)
            {
                if(![differentIndex containsObject:a])
                {
                    [differentIndex addObject:a];
                }

            }

        }
        else
        {
            if(RemainingContacts)
            {
                if(![RemainingContacts containsObject:a])
                {
                    [RemainingContacts addObject:a];
                }
                
            }


        }
        
//        for (int k=0; k<[app.RegContactList count]; k++)
//        {
//            NSLog(@"%@",[app.RegContactList objectAtIndex:k]);
//            if ([[app.RegContactList objectAtIndex:k] containsString:a])
//            {
//                NSLog(@"string contains bla!");
//
//            }
//            else
//            {
//                NSLog(@"string does not contain bla");
//            }
//        }
        
    }
    NSLog(@"differentIndex ::::  %@",differentIndex);
    app.RemainingContList=RemainingContacts;
    app.FilteredContacts = differentIndex;
    
    [indicator stopAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
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
