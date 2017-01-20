//
//  BackupRestoreVc.m
//  Flippy Cloud
//
//  Created by iSquare5 on 29/08/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import "BackupRestoreVc.h"
#import "AppDelegate.h"
#import "SidebarViewController.h"
#import <Contacts/Contacts.h>

@interface BackupRestoreVc ()
{
    AppDelegate *app;
    NSString *status,*phoneNumber,*CoEmail,*FirstnameStr,*LastnameStr;
    NSMutableArray *contactno,*firstname,*lastname,*emailARR,*phoneno;
}
@property (nonatomic, retain) SidebarViewController* sidebarVC;

@end

@implementation BackupRestoreVc

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    self.sidebarVC = [[SidebarViewController alloc] init];
    [self.sidebarVC setBgRGB:0x000000];
    self.sidebarVC.view.frame  = self.view.bounds;
    [self.view addSubview:self.sidebarVC.view];
    [self.sidebarVC showHideSidebar];
    self.scrollView.contentSize=CGSizeMake(self.view.frame.size.width,self.view.frame.size.height + 120);
    app.view =@"backUP";
    NSMutableArray *dataArry= [[NSMutableArray alloc] init];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *email=[prefs valueForKey:@"email"];
    NSString *contact=[prefs valueForKey:@"contact"];
    NSString *urlString = [[NSString alloc]initWithFormat:@"%@directory_size.php",app.Service ];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *myRequestString =[NSString stringWithFormat:@"{\"email\":\"%@\",\"contact\":\"%@\"}",email,contact];
    NSData *requestData = [NSData dataWithBytes:[myRequestString UTF8String] length:[myRequestString length]];
    [request setHTTPMethod: @"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody: requestData];
    NSError *error;
    NSURLResponse *response;
    NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingAllowFragments error:nil];
    NSLog(@" directory_size.php :%@",jsonDictionary);
    NSString *audio=[NSString stringWithFormat:@"%@",[[[jsonDictionary valueForKey:@"posts"]valueForKey:@"audio"]objectAtIndex:0]];
    NSString *video=[NSString stringWithFormat:@"%@",[[[jsonDictionary valueForKey:@"posts"]valueForKey:@"video"]objectAtIndex:0]];
    NSString *images=[NSString stringWithFormat:@"%@",[[[jsonDictionary valueForKey:@"posts"] valueForKey:@"images"]objectAtIndex:0]];
    NSString *file=[NSString stringWithFormat:@"%@", [[[jsonDictionary valueForKey:@"posts"] valueForKey:@"file"]objectAtIndex:0]];
    NSString *audioCount=[NSString stringWithFormat:@"%@",  [[[jsonDictionary valueForKey:@"posts" ] valueForKey:@"audio_count"]objectAtIndex:0]];
    NSString *videoCount=[NSString stringWithFormat:@"%@", [[[jsonDictionary valueForKey:@"posts" ] valueForKey:@"video_count"]objectAtIndex:0]];
    NSString *imagesCount=[NSString stringWithFormat:@"%@",  [[[jsonDictionary valueForKey:@"posts" ] valueForKey:@"images_count"]objectAtIndex:0]];
    NSString *fileCount=[NSString stringWithFormat:@"%@",  [[[jsonDictionary valueForKey:@"posts" ] valueForKey:@"file_count"]objectAtIndex:0]];
    NSArray *data=[[NSArray alloc]initWithObjects:audio,video,images,file, nil];
    [dataArry addObjectsFromArray:data];
    self.ImageLbl.text=[NSString stringWithFormat:@"%@",imagesCount];
    self.videoLbl.text=[NSString stringWithFormat:@"%@",videoCount];
    self.FileLbl.text=[NSString stringWithFormat:@"%@",fileCount];
    self.audioLbl.text=[NSString stringWithFormat:@"%@",audioCount];
    [self.piechartView renderInLayer:self.piechartView dataArray:dataArry];
}
-(IBAction)contactBtnPressed:(id)sender
{
    if([self.contactBtn isSelected])
    {
       [sender setSelected:NO];
        NSLog(@"off");
    }
    else
    {
        [sender setSelected:YES];
        status =@"on";
        contactno = [[NSMutableArray alloc]init];
        firstname = [[NSMutableArray alloc]init];
        lastname= [[NSMutableArray alloc]init];
        emailARR = [[NSMutableArray alloc]init];
        phoneno =[[NSMutableArray alloc]init];
        CNAuthorizationStatus status1 = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        if( status1 == CNAuthorizationStatusDenied || status1 == CNAuthorizationStatusRestricted)
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
                 CoEmail = [contact.emailAddresses valueForKey:@"value"];
                 [contactno addObject:contact];
            }];
        }
    }
}
-(IBAction)audioBtnPressed:(id)sender
{
    if([self.audioBtn isSelected])
    {
        [sender setSelected:NO];
    }
    else
    {
        [sender setSelected:YES];
    }
}
-(IBAction)videoBtnPressed:(id)sender
{
    if([self.videoBtn isSelected])
    {
        [sender setSelected:NO];
    }
    else
    {
        [sender setSelected:YES];
    }
}
-(IBAction)imagesBtnPressed:(id)sender
{
    if([self.imageBtn isSelected])
    {
        [sender setSelected:NO];
    }
    else
    {
        [sender setSelected:YES];
    }
}
-(IBAction)filesBtnPressed:(id)sender
{
    if([self.filesBtn isSelected])
    {
        [sender setSelected:NO];
    }
    else
    {
        [sender setSelected:YES];
    }
}
-(IBAction)syncBtnPressed:(id)sender
{
}
- (void)didReceiveMemoryWarning
{
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
