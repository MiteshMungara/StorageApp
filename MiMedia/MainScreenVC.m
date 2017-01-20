//
//  MainScreenVC.m
//  Flippy Cloud
//
//  Created by iSquare5 on 14/09/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import "MainScreenVC.h"
#import "MiLoginVC.h"
#import "MiSignupVC.h"
#import "AppDelegate.h"

@interface MainScreenVC ()
{
    AppDelegate *app;
}
@end

@implementation MainScreenVC
- (void)viewDidLoad
{
    [super viewDidLoad];
    app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
}
-(IBAction)LoginBtnPressed:(id)sender
{
    UINavigationController *navigationController = (UINavigationController *)app.window.rootViewController;
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    MiLoginVC *Listroute = (MiLoginVC *)[mainStoryboard instantiateViewControllerWithIdentifier: @"MiLoginVC"];
    [navigationController pushViewController:Listroute animated:YES];
}
-(IBAction)SignupBtnressed:(id)sender
{
    UINavigationController *navigationController = (UINavigationController *)app.window.rootViewController;
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    MiSignupVC *Listroute = (MiSignupVC *)[mainStoryboard instantiateViewControllerWithIdentifier: @"MiSignupVC"];
    [navigationController pushViewController:Listroute animated:YES];
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
