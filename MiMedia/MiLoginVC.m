//
//  MiLoginVC.m
//  MiMedia
//
//  Created by iSquare5 on 09/08/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import "MiLoginVC.h"
#import "HomeVC.h"
#import "BackupRestoreVc.h"
#import "IntroVC.h"
#import "Reachability.h"
@interface MiLoginVC ()
{
    UIActivityIndicatorView *indicator;

}

@end

@implementation MiLoginVC
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initPB];
    app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    UIView *email = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [self.userNameTxt setLeftViewMode:UITextFieldViewModeAlways];
    [self.userNameTxt setLeftView:email];
    UIView *pass = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [self.PassTxt setLeftViewMode:UITextFieldViewModeAlways];
    [self.PassTxt setLeftView:pass];
    UIView *forpass = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [self.forPassTxt setLeftViewMode:UITextFieldViewModeAlways];
    [self.forPassTxt setLeftView:forpass];
    _tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:_tapRecognizer];
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
-(IBAction)LoginBtnPressed:(id)sender
{
    [indicator startAnimating];
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(LoginButton) userInfo:nil repeats:NO];
}
-(void)LoginButton
{
    if([[Reachability sharedReachability] internetConnectionStatus] == NotReachable)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Check Internet Connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
    else
    {
        NSString *DeviceType=@"iphone";
        
        NSString *urlString = [[NSString alloc]initWithFormat:@"%@login.php",app.Service];
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSString *myRequestString =[NSString stringWithFormat:@"{\"email\":\"%@\",\"password\":\"%@\",\"type\":\"%@\",\"token\":\"%@\"}",self.userNameTxt.text,self.PassTxt.text,DeviceType,app.deviceTokenStr];
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
            
            NSLog(@"login.php   ::::  %@",dictionary);
            
            
            if (!dictionary)
            {
                NSLog(@"%s: JSONObjectWithData error: %@; data = %@", __FUNCTION__, parseError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                return ;
            }
            else
            {
//              NSLog(@"%@",dictionary);
                NSString *success=[NSString stringWithFormat:@"%@",[dictionary valueForKey:@"success"]];
                int successRes =[success intValue];
                if(successRes == 1)
                {
                    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                    NSString *UserId =[[[dictionary valueForKey:@"post"]valueForKey:@"id"]objectAtIndex:0];
                    NSString *email =[[[dictionary valueForKey:@"post"]valueForKey:@"email"]objectAtIndex:0];
                    NSString *phone =[[[dictionary valueForKey:@"post"]valueForKey:@"contact"]objectAtIndex:0];
                    NSString *f_name =[[[dictionary valueForKey:@"post"]valueForKey:@"f_name"]objectAtIndex:0];
                    NSString *l_name =[[[dictionary valueForKey:@"post"]valueForKey:@"l_name"]objectAtIndex:0];
                     NSString *Oldpass =[[[dictionary valueForKey:@"post"]valueForKey:@"password"]objectAtIndex:0];
                   
                    [prefs setObject:email forKey:@"email"];
                    [prefs setObject:phone forKey:@"contact"];
                    [prefs setObject:UserId forKey:@"id"];
                    [prefs setObject:f_name forKey:@"f_name"];
                    [prefs setObject:l_name forKey:@"l_name"];
                    [prefs setObject:Oldpass forKey:@"password"];
                    
                    [indicator startAnimating];
                    UINavigationController *navigationController = (UINavigationController *)app.window.rootViewController;
                    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                    IntroVC *MainPage = (IntroVC*)[mainStoryboard instantiateViewControllerWithIdentifier: @"IntroVC"];
                    [navigationController pushViewController:MainPage animated:YES];
                }
                else
                {
                    [indicator stopAnimating];
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error!" message:@"Something Wrong or not Registered User." preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                         {
                                             [self clear];
                                         }];
                    [alertController addAction:ok];
                    [self presentViewController:alertController animated:YES completion:nil];
                }
            }
        }];
     }
}
-(void)clear
{
    self.PassTxt.text=@"";
}
-(IBAction)BackBtnPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(IBAction)TermsBtnPressed:(id)sender
{
//    NSURL *url = [NSURL URLWithString:@"http://www.mimedia.com/termsandconditions/"];
//    if ([[UIApplication sharedApplication] canOpenURL:url])
//    {
//        [[UIApplication sharedApplication] openURL:url];
//    }
}
-(IBAction)PolicyBtnPressed:(id)sender
{
//    NSURL *url = [NSURL URLWithString:@"http://www.mimedia.com/privacy/"];
//    if ([[UIApplication sharedApplication] canOpenURL:url])
//    {
//        [[UIApplication sharedApplication] openURL:url];
//    }
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
-(IBAction)forgotBtnPressed:(id)sender
{
    self.ForgotPassView.hidden=NO;
}
-(IBAction)forBackBtnPressed:(id)sender
{
    self.ForgotPassView.hidden=YES;
}
-(IBAction)resetPassBtnPressed:(id)sender
{
    [indicator startAnimating];
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(ResetButton) userInfo:nil repeats:NO];
}
-(void)ResetButton
{
    if([[Reachability sharedReachability] internetConnectionStatus] == NotReachable)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Check Internet Connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
    else
    {
            NSString *urlString = [[NSString alloc]initWithFormat:@"%@send_mail.php",app.Service ];
            NSURL *url = [NSURL URLWithString:urlString];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            NSString *myRequestString =[NSString stringWithFormat:@"{\"email\":\"%@\"}",self.forPassTxt.text];
            NSData *requestData = [NSData dataWithBytes:[myRequestString UTF8String] length:[myRequestString length]];
            [request setHTTPMethod: @"POST"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody: requestData];
            NSError *error;
            NSURLResponse *response;
            NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingAllowFragments error:nil];
            NSString *message=[[jsonDictionary valueForKey:@"post"]valueForKey:@"message"];
                if([message isEqualToString:@"Email Sent"])
                {
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Success!" message:@"Email Sent Successfully." preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                {
                                    [self clear];
                                }];
                    [alertController addAction:ok];
                    [self presentViewController:alertController animated:YES completion:nil];
                    self.ForgotPassView.hidden=YES;
                    [indicator stopAnimating];
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = false;
            }
            else
            {
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"something wrong!" message:@"Please Register First." preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                {
                                    [self clear];
                                }];
                    [alertController addAction:ok];
                    [self presentViewController:alertController animated:YES completion:nil];
                    [indicator stopAnimating];
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = false;
            }
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void )prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
