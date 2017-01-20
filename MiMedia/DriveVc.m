//
//  DriveVc.m
//  Flippy Cloud
//
//  Created by iSquare5 on 22/08/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import "DriveVc.h"
#import "SidebarViewController.h"
#import "DriveSubVC.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import <Contacts/Contacts.h>
#import "AsyncImageView.h"
#import "SubDriveVC.h"
#import <MessageUI/MessageUI.h>

@interface DriveVc ()<MFMessageComposeViewControllerDelegate>
{
    UIView *collView;
    UIVisualEffectView *blurEffectView;
    NSArray *DriveName,*DriveNameCopy,*CollIDArr;
    AppDelegate *app;
    UIActivityIndicatorView *indicator;
    NSMutableArray *contactno,*firstname,*lastname,*emailARR,*phoneno,*ContactEmails,*InvitedEmailArr,*CoverImageARR,*FullNameArr;
    NSString *statusContact,*phoneNumber,*CoEmail,*FirstnameStr,*LastnameStr, *LocalPath,*ContactToSendMsg;
    NSMutableArray *selectedContacts,*SharedEmailIDArr,*LastMsgArr,*SelectMobileNo;
    NSMutableArray *InvitedDriveNameArr,*TotalCount,*DriveStatusArr,*CreatorNameArr,*sharedriveidArr;
   
}

@property (nonatomic, retain) SidebarViewController* sidebarVC;

@end
int postrow1;
int postrow2;
int postrow3;
int postrow4;
@implementation DriveVc

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}
- (void)viewDidLoad
{

    [super viewDidLoad];
    [self initPB];
    [self viewWillAppear:YES];
   
    SharedEmailIDArr =[[NSMutableArray alloc]init];
    TotalCount =[[NSMutableArray alloc]init];
    InvitedDriveNameArr=[[NSMutableArray alloc]init];
 
    app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    self.sidebarVC = [[SidebarViewController alloc] init];
    [self.EmailCollectionView setAllowsMultipleSelection:YES];
    [self.sidebarVC setBgRGB:0x000000];
    self.sidebarVC.view.frame  = self.view.bounds;
    [self.view addSubview:self.sidebarVC.view];
    [self.sidebarVC showHideSidebar];

    selectedContacts = [[NSMutableArray alloc]init];
    SelectMobileNo=[[NSMutableArray alloc]init];
  
    [indicator startAnimating];
   
    UIView *DriveNameTxt = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [self.DriveNameTxt setLeftViewMode:UITextFieldViewModeAlways];
    [self.DriveNameTxt setLeftView:DriveNameTxt];
   
    _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    _tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:_tapRecognizer];
}
-(IBAction)CancelBtnPressed:(id)sender
{
    self.CreateDrive.hidden=YES;
    [blurEffectView removeFromSuperview];
    self.mainHeaderView.hidden=NO;
}
-(void)viewWillAppear:(BOOL)animated
{

    app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    if(app.DriveArrNameCopy == NULL)
    {
        
        [self DriveCount];
    }
    else
    {

        [indicator stopAnimating];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
        self.collectionView.tag=0;
        TotalCount=NULL;
        self.CreateDrive.hidden=YES;
        self.mainView.hidden=YES;
        self.collectionView.hidden=NO;
        [self.collectionView reloadData];
    }
}
-(void)DriveCount
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
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *email=[prefs valueForKey:@"email"];
        NSString *contact = [prefs valueForKey:@"contact"];
        NSString *UserId = [prefs valueForKey:@"id"];
//      NSString *urlString = [[NSString alloc]initWithFormat:@"http://46.166.173.116/FlippyCloud/webservices/all_drive_ios.php"];
        NSString *urlString = [[NSString alloc]initWithFormat:@"http://46.166.173.116/FlippyCloud/webservices/ios/test/all_drive_ios.php"];
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSString *myRequestString =[NSString stringWithFormat:@"{\"email\":\"%@\",\"contact\":\"%@\",\"user_id\":\"%@\"}",email,contact,UserId];
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
            
            
                NSLog(@"all_drive_ios.php  ::::  %@",dictionary);
            

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
                        TotalCount =[[dictionary valueForKey:@"posts"]valueForKey:@"drive_name"];
                        CollIDArr =[[dictionary valueForKey:@"posts"]valueForKey:@"id"];
                        InvitedEmailArr = [[dictionary valueForKey:@"posts"] valueForKey:@"invite_email"];
                        CoverImageARR = [[dictionary valueForKey:@"posts"]valueForKey:@"images"];//valueForKey:@"images"];
                        DriveStatusArr=[[dictionary valueForKey:@"posts"]valueForKey:@"drive_status"];
                        CreatorNameArr =[[dictionary valueForKey:@"posts"]valueForKey:@"creater"];
                        SharedEmailIDArr=[[dictionary valueForKey:@"posts"]valueForKey:@"share_drive_id"];
                        LastMsgArr=[[dictionary valueForKey:@"posts"]valueForKey:@"last_comment"];

                        app.DriveArrNameCopy =[NSMutableArray arrayWithArray:TotalCount];
                        app.DriveIdArrCopy =[[NSMutableArray alloc]init];
                        app.InviteEmailArrCopy =[[NSMutableArray alloc]init];
                        app.DriveCoverImageArrCopy =[[NSMutableArray alloc]init];
                        app.DriveStatusArrCopy=[[NSMutableArray alloc]init];
                        app.DriveIdArrCopy = [CollIDArr copy];
                        app.DriveStatusArrCopy = [DriveStatusArr copy];
                        app.InviteEmailArrCopy = [InvitedEmailArr copy];
                        app.DriveCoverImageArrCopy = [CoverImageARR copy];
                        app.CreatorNameCopyArr=[CreatorNameArr copy];
                        app.ShareDriveIdArrCopy=[SharedEmailIDArr copy];
                        app.DriveLastMsgArr=[LastMsgArr copy];
                        
 
                        self.collectionView.tag=0;
                        self.CreateDrive.hidden=YES;
                        self.mainView.hidden=YES;
                        self.collectionView.hidden=NO;
                        [self.collectionView reloadData];
                        self.DriveNameTxt.text=@"";
                        [indicator stopAnimating];
                        [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
                    }
                    else
                    {
                        [indicator stopAnimating];
                        [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
                        self.mainView.hidden=NO;
                        self.CreateDrive.hidden=YES;
                        self.mainHeaderView.hidden=NO;
                    }
                }
        }];
    }
}
-(IBAction)addBtnPressed:(id)sender
{
    self.CreateDrive.hidden=NO;
    self.mainHeaderView.hidden=YES;
}
-(IBAction)CreateCollBtnPressed:(id)sender
{
    self.CreateDrive.hidden=NO;
}
-(IBAction)createBtnPressed:(id)sender
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
        self.EmailSharingView.hidden=NO;
        ContactEmails=[[NSMutableArray alloc]init];
        [self.EmailsSharingTV allowsMultipleSelection];
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(GettingEmilsFromAddressBook) userInfo:nil repeats:NO];
        self.collectionView.tag=1;
    }
}
-(IBAction)TableBackBtnPressed:(id)sender
{
    self.EmailSharingView.hidden=YES;
    self.collectionView.tag=0;
    [self.collectionView reloadData];
}
-(IBAction)TableDoneBtnPressed:(id)sender
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
                            [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(CreationDrive) userInfo:nil repeats:NO];
                        }
                        else
                        {
                            [indicator startAnimating];
                            [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(CreationDrive) userInfo:nil repeats:NO];
                        }
                    }
                }
                else
                {
                    [self showSMS:selectedFile];
                }
    }
}
-(void)GettingEmilsFromAddressBook
{
    //åååååååååååååååååååååå   contact getting start   ååååååååååååååååååå
    contactno = [[NSMutableArray alloc]init];
    FullNameArr = [[NSMutableArray alloc]init];
    firstname = [[NSMutableArray alloc]init];
    lastname= [[NSMutableArray alloc]init];
    emailARR = [[NSMutableArray alloc]init];
    phoneno =[[NSMutableArray alloc]init];
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
             
             
             NSString *FullName=[NSString stringWithFormat:@"%@ %@",FirstnameStr,LastnameStr];
             
             [FullNameArr addObject:FullName];
             [contactno addObject:phoneNumber];
             [ContactEmails addObject:CoEmail];
             [self.EmailCollectionView reloadData];

         }];
    }
    //åååååååååååååååååååååå  contact getting stop  åååååååååååååååååååååå
}
-(void)CreationDrive
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
    
    NSString *myRequestString;
    if(selectedContacts.count ==0)
    {
            myRequestString =[NSString stringWithFormat:@"{\"drive_name\":\"%@\",\"email\":\"%@\",\"contact\":\"%@\",\"invite_email\":[]}",self.DriveNameTxt.text,email,contact];
    }
    else
    {
        myRequestString =[NSString stringWithFormat:@"{\"drive_name\":\"%@\",\"email\":\"%@\",\"contact\":\"%@\",\"invite_email\":[%@]}",self.DriveNameTxt.text,email,contact,SharedEmail];
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
        
        
        
           NSLog(@"drive.php  ::::  %@",dictionary);
        if (!dictionary)
        {
            NSLog(@"%s: JSONObjectWithData error: %@; data = %@", __FUNCTION__, parseError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            return ;
        }
        else
        {
            TotalCount =[[dictionary valueForKey:@"posts"]valueForKey:@"drive_name"];
            CollIDArr =[[dictionary valueForKey:@"posts"]valueForKey:@"id"];
                  [prefs setObject:TotalCount forKey:@"drive_name"];
            NSString *success=[dictionary valueForKey:@"success"];
            if([success isEqualToString:@"1"])
            {
                self.EmailSharingView.hidden=YES;
                self.CreateDrive.hidden=YES;
                self.mainView.hidden=YES;
                self.collectionView.tag=0;
                self.collectionView.hidden=NO;
                self.mainHeaderView.hidden=NO;
                app.DriveArrNameCopy=NULL;
                [self viewWillAppear:YES];
                [blurEffectView removeFromSuperview];
                [indicator stopAnimating];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
            }
            else
            {
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Something Wrong." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [av show];
                [indicator stopAnimating];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
                self.mainView.hidden=NO;
                self.CreateDrive.hidden=NO;
                self.mainHeaderView.hidden=YES;
            }
        }
    }];
}


// ------  collection view start   -------
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.collectionView.tag==1)
    {
        return ContactEmails.count;
    }
    else
    {
        if(TotalCount == NULL)
        {

            return app.DriveArrNameCopy.count;
        }
        else
        {

            return TotalCount.count;
        }
    }
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
//    NSLog(@"asdasd");
    return UIEdgeInsetsMake(0, 0, 0, 0);
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
    
    UIButton *nextButton=(UIButton *)[cell viewWithTag:201];
    [nextButton addTarget:self action:@selector(NextBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    nextButton.layer.cornerRadius=nextButton.frame.size.width/2;
    [nextButton setBackgroundColor:[UIColor whiteColor]];
    nextButton.hidden=YES;
    UILabel *sharedEmailLbl26 = (UILabel *)[cell viewWithTag:26];
    
    UIImageView *imageV36 = (UIImageView *)[cell viewWithTag:36];
   
    if (self.collectionView.tag==1)
    {
        UILabel *label= (UILabel *)[cell viewWithTag:102];
        label.text=[ContactEmails objectAtIndex:indexPath.row];
//        UILabel *Namelabel= (UILabel *)[cell viewWithTag:1];
//        NSString *EmailAdd=[NSString stringWithFormat:@"%@",[ContactEmails objectAtIndex:indexPath.row]];
//        Namelabel.text =[NSString stringWithFormat:@"%@",[EmailAdd substringToIndex:1]];
        NSString *EmailAdd=[NSString stringWithFormat:@"%@",[ContactEmails objectAtIndex:indexPath.row]];
        UILabel *ContactEmail=(UILabel *)[cell viewWithTag:2];
        UILabel *ContactFirstChar=(UILabel *)[cell viewWithTag:1];
        
        if ([EmailAdd isEqualToString:@""])
        {
            ContactFirstChar.text=[NSString stringWithFormat:@"%@",[[FullNameArr objectAtIndex:indexPath.row] substringToIndex:1]];
            ContactEmail.text=[contactno objectAtIndex:indexPath.row];
        }
        else
        {
            ContactFirstChar.text=[NSString stringWithFormat:@"%@",[EmailAdd substringToIndex:1]];
            ContactEmail.text=[ContactEmails objectAtIndex:indexPath.row];
        }
        UILabel *fullName=(UILabel *)[cell viewWithTag:3];
        fullName.text=[FullNameArr objectAtIndex:indexPath.row];

    }
    else
    {
        
        
        if (TotalCount == NULL)
        {
            UIImageView *CoverImage=(UIImageView *)[ cell viewWithTag:100];
            CoverImage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            UIImageView *CoverBlurImage=(UIImageView *)[ cell viewWithTag:101];
            UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
            blurEffectView.frame = self.view.bounds;
            blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [CoverBlurImage addSubview:blurEffectView];
            
            NSString *CoverImageStr=[NSString stringWithFormat:@"%@",[app.DriveCoverImageArrCopy objectAtIndex:indexPath.row]];
            if([CoverImageStr isEqualToString:@"<null>"] || [CoverImageStr isEqualToString:@"(\n)"])
            {
                CoverImage.image=[UIImage imageNamed:@"img.png"];
                CoverBlurImage.image=[UIImage imageNamed:@""];
            }
            else
            {
                CoverImage.imageURL=[NSURL URLWithString:[NSString stringWithFormat:@"%@", [app.DriveCoverImageArrCopy objectAtIndex:indexPath.row]]];
                CoverBlurImage.imageURL=[NSURL URLWithString:[NSString stringWithFormat:@"%@", [app.DriveCoverImageArrCopy objectAtIndex:indexPath.row]]];
            }
            if ([app.view isEqualToString:@"next"])
            {
                
            }
            else
            {
                UILabel *distance = (UILabel *)[cell viewWithTag:1];
                distance.text=[app.DriveArrNameCopy objectAtIndex:indexPath.row];

                UILabel *lastMsg = (UILabel *)[cell viewWithTag:2];
                lastMsg.text=[app.DriveLastMsgArr objectAtIndex:indexPath.row];
                UILabel *sharedEmailLbl21 = (UILabel *)[cell viewWithTag:21];
                
                UIImageView *imageV31 = (UIImageView *)[cell viewWithTag:31];
                sharedEmailLbl21.hidden=YES;
                imageV31.hidden=YES;
                NSString *email=[NSString stringWithFormat:@"%@",[app.CreatorNameCopyArr objectAtIndex:indexPath.row] ];
                    sharedEmailLbl21.text =[NSString stringWithFormat:@"%@",[email substringToIndex:1]];
                    imageV31.image=[UIImage imageNamed:@"Creator.png"];
                    imageV31.hidden=NO;
                    sharedEmailLbl21.hidden=NO;
            }
            
        }
        else
        {
            UIImageView *CoverImage=(UIImageView *)[ cell viewWithTag:100];
            CoverImage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            UIImageView *CoverBlurImage=(UIImageView *)[ cell viewWithTag:101];
            
            UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
            blurEffectView.frame = self.view.bounds;
            blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [CoverBlurImage addSubview:blurEffectView];
            
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
            
            
            if ([app.view isEqualToString:@"next"])
            {
                
            }
            else
            {

                UILabel *distance = (UILabel *)[cell viewWithTag:1];
                distance.text=[TotalCount objectAtIndex:indexPath.row];
                
                UILabel *lastMsg = (UILabel *)[cell viewWithTag:2];
                lastMsg.text=[LastMsgArr objectAtIndex:indexPath.row];
              
                UILabel *sharedEmailLbl21 = (UILabel *)[cell viewWithTag:21];
                UIImageView *imageV31 = (UIImageView *)[cell viewWithTag:31];
                
                    sharedEmailLbl21.hidden=YES;
                    imageV31.hidden=YES;
                NSString *email=[NSString stringWithFormat:@"%@",[app.CreatorNameCopyArr objectAtIndex:indexPath.row] ];
                sharedEmailLbl21.text =[NSString stringWithFormat:@"%@",[email substringToIndex:1]];
                imageV31.image=[UIImage imageNamed:@"Creator.png"];
                imageV31.hidden=NO;
                sharedEmailLbl21.hidden=NO;
            }
        }
    }
    return cell;
}
-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    app.view=@"";
   if (self.collectionView.tag==1)
    {
        UICollectionViewCell* cell=[collectionView cellForItemAtIndexPath:indexPath];
        cell.contentView.backgroundColor = [UIColor lightGrayColor];

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
    else
    {
        if (DriveStatusArr == NULL)
        {
            app.SharedDriveIdStr=[app.ShareDriveIdArrCopy objectAtIndex:indexPath.row];
            app.DriveStatusStr=[app.DriveStatusArrCopy objectAtIndex:indexPath.row];
            app.superDriveName=[app.DriveArrNameCopy objectAtIndex:indexPath.row];
            app.CollIdarr=[app.DriveIdArrCopy objectAtIndex:indexPath.row];
            app.MemberListArr=[app.InviteEmailArrCopy objectAtIndex:indexPath.row];
        }
        else
        {
            app.DriveStatusStr=[DriveStatusArr objectAtIndex:indexPath.row];
            app.superDriveName=[TotalCount objectAtIndex:indexPath.row];
            app.CollIdarr=[CollIDArr objectAtIndex:indexPath.row];
            app.MemberListArr=[InvitedEmailArr objectAtIndex:indexPath.row];
            app.SharedDriveIdStr=[app.ShareDriveIdArrCopy objectAtIndex:indexPath.row];
        }
        if([app.DriveStatusStr isEqualToString:@"Shared"])
        {
            app.DriveStatusStr=[NSString stringWithFormat:@"1"];
            [self performSegueWithIdentifier:@"SubDriveVC" sender:self];
        }
        else
        {
            [self performSegueWithIdentifier:@"SubDriveVC" sender:self];
        }
    }
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell=[collectionView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = nil;
    [selectedContacts removeObject:[NSString stringWithFormat:@"%@",[ContactEmails objectAtIndex:indexPath.row]]];
    [SelectMobileNo removeObject:[NSString stringWithFormat:@"%@",[contactno objectAtIndex:indexPath.row]]];
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
//    [self.EmailCollectionView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)NextBtnPressed:(UIButton*)sender
{
    app.view=@"next";
    NSIndexPath *indexPath;
    indexPath = [self.collectionView indexPathForItemAtPoint:[self.collectionView convertPoint:sender.center fromView:sender.superview]];
    
    app.MemberListArr=[[app.InviteEmailArrCopy objectAtIndex:indexPath.row] copy];
    static NSString *identifier=@"Cell";
    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    app.view=@"contact";
    
    [self performSegueWithIdentifier:@"DriveSubVC" sender:self];
    
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
//-*-*-*-*-     stop


-(IBAction)SharedNotificationBtnPressed:(id)sender
{
    [self performSegueWithIdentifier:@"SharedDriveVC" sender:self];

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
