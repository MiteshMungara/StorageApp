//
//  LoginVC.m
//  MiMedia
//
//  Created by iSquare5 on 08/08/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import "LoginVC.h"
#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <GoogleSignIn/GoogleSignIn.h>
#import "BackupRestoreVc.h"

@interface LoginVC ()<FBLoginViewDelegate,GIDSignInDelegate,GIDSignInUIDelegate>
{
    AppDelegate *app;
    NSString *FirstName,*LastName,*EmailAdd;
}
-(void)toggleHiddenState:(BOOL)shouldHide;

@end

@implementation LoginVC
static NSString * const kClientID = @"495842855206-lqa6u6pa2srp5ddpg7bbctmmufjqf4lu.apps.googleusercontent.com";
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}
-(void)viewDidLoad
{
    [super viewDidLoad];
    app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    [self toggleHiddenState:YES];
    self.loginButton.delegate = self;
    self.loginButton.readPermissions = @[@"public_profile",@"email"];
    _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    _tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:_tapRecognizer];
    [self viewDidAppear:YES];
}
-(void)toggleHiddenState:(BOOL)shouldHide
{
}
-(void)loginViewShowingLoggedInUser:(FBLoginView *)loginView
{
    NSLog(@"You are logged in.");
    [self toggleHiddenState:NO];
}
-(void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
{
    FirstName=[user objectForKey:@"first_name"];
    LastName=[user objectForKey:@"last_name"];
    EmailAdd=[user objectForKey:@"email"];
    if(user != NULL)
    {
        self.BGView.hidden=NO;
    }
}
-(IBAction)DoneBtnPressed:(id)sender
{
    NSString *password=@"";
    NSString *promocode=@"";
    NSString *DeviceType=@"iphone";
    NSString *urlString = [[NSString alloc]initWithFormat:@"%@register.php",app.Service ];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *myRequestString =[NSString stringWithFormat:@"{\"f_name\":\"%@\",\"l_name\":\"%@\",\"email\":\"%@\",\"contact\":\"%@\",\"password\":\"%@\",\"promo_code\":\"%@\",\"devicetype\":\"%@\",\"token\":\"%@\"}",FirstName,LastName,EmailAdd,self.PhoneTxt.text,password,promocode,DeviceType,app.deviceTokenStr];
    NSData *requestData = [NSData dataWithBytes:[myRequestString UTF8String] length:[myRequestString length]];
    [request setHTTPMethod: @"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody: requestData];
    NSError *error;
    NSURLResponse *response;
    NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingAllowFragments error:nil];
    NSLog(@"register :  %@",jsonDictionary);
    NSString *successStr=[jsonDictionary valueForKey:@"success"];
    NSInteger success =[successStr intValue];
    if(success == 1)
    {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *email =[[[jsonDictionary valueForKey:@"post"]valueForKey:@"email"]objectAtIndex:0];
        NSString *phone =[[[jsonDictionary valueForKey:@"post"]valueForKey:@"contact"]objectAtIndex:0];
        NSString *UserId =[[[jsonDictionary valueForKey:@"post"]valueForKey:@"id"]objectAtIndex:0];
        NSString *f_name =[[[jsonDictionary valueForKey:@"post"]valueForKey:@"f_name"]objectAtIndex:0];//f_name
        [prefs setObject:email forKey:@"email"];
        [prefs setObject:phone forKey:@"contact"];
        [prefs setObject:UserId forKey:@"id"];
        [prefs setObject:f_name forKey:@"f_name"];
        self.BGView.hidden=YES;
        UINavigationController *navigationController = (UINavigationController *)app.window.rootViewController;
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        BackupRestoreVc *Listroute = (BackupRestoreVc *)[mainStoryboard instantiateViewControllerWithIdentifier: @"BackupRestoreVc"];
        [navigationController pushViewController:Listroute animated:YES];
    }
    else
    {
        self.BGView.hidden=YES;
        NSString *urlString = [[NSString alloc]initWithFormat:@"%@login.php",app.Service];
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSString *myRequestString =[NSString stringWithFormat:@"{\"email\":\"%@\",\"contact\":\"%@\"}",EmailAdd,self.PhoneTxt.text];
        NSData *requestData = [NSData dataWithBytes:[myRequestString UTF8String] length:[myRequestString length]];
        [request setHTTPMethod: @"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody: requestData];
        NSError *error;
        NSURLResponse *response;
        NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingAllowFragments error:nil];
        NSString *successStr=[jsonDictionary valueForKey:@"success"];
        NSInteger success=[successStr intValue];
        NSLog(@"login :  %@",jsonDictionary);
        if(success == 1)
        {
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSString *email =[[[jsonDictionary valueForKey:@"post"]valueForKey:@"email"]objectAtIndex:0];
            NSString *phone =[[[jsonDictionary valueForKey:@"post"]valueForKey:@"contact"]objectAtIndex:0];
            NSString *UserId =[[[jsonDictionary valueForKey:@"post"]valueForKey:@"id"]objectAtIndex:0];
            NSString *f_name =[[[jsonDictionary valueForKey:@"post"]valueForKey:@"f_name"]objectAtIndex:0];//f_name
            [prefs setObject:email forKey:@"email"];
            [prefs setObject:phone forKey:@"contact"];
            [prefs setObject:UserId forKey:@"id"];
            [prefs setObject:f_name forKey:@"f_name"];
            self.BGView.hidden=YES;
            UINavigationController *navigationController = (UINavigationController *)app.window.rootViewController;
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            BackupRestoreVc *Listroute = (BackupRestoreVc *)[mainStoryboard instantiateViewControllerWithIdentifier: @"BackupRestoreVc"];
            [navigationController pushViewController:Listroute animated:YES];
        }
        else
        {
            self.PhoneTxt.text=@"";
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Fails!" message:@"Email or Contact already exists." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
}
-(void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView{
    NSLog(@"You are logged out");
    [self toggleHiddenState:YES];
}
-(void)loginView:(FBLoginView *)loginView handleError:(NSError *)error
{
}


//*************************************** #fbOver 

- (void)viewWillAppear:(BOOL)animated
{
    [GIDSignIn sharedInstance].clientID = kClientID;
    [GIDSignIn sharedInstance].delegate = self;
    [GIDSignIn sharedInstance].uiDelegate = self;
    [super viewWillAppear:animated];
}
- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    // Perform any operations on signed in user here.
//    NSString *userId = user.userID;                  // For client-side use only!
//    NSString *idToken = user.authentication.idToken; // Safe to send to the server

    NSString *name = user.profile.name;
    NSArray *items = [name componentsSeparatedByString:@" "];   //take one array for splitting the string
    FirstName= [items objectAtIndex:0];
    LastName= [items objectAtIndex:1];
    EmailAdd= user.profile.email;
//    NSLog(@"%@",user.profile);
//    NSLog(@"%@",fname);
//    NSLog(@"%@",lname);
//    NSLog(@"%@",email);
    if(name != NULL)
    {
        self.BGView.hidden=NO;
    }
    // ...
}

-(IBAction)SignupBTNPressed:(id)sender
{
         [self  performSegueWithIdentifier:@"signupVC" sender:nil];
    
}
-(IBAction)LoginMIBtnPressed:(id)sender
{
 [self  performSegueWithIdentifier:@"LoginVC" sender:nil];
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
