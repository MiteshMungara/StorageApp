//
//  UploadSettingVC.m
//  Flippy Cloud
//
//  Created by iSquare5 on 22/08/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import "UploadSettingVC.h"
#import "SidebarViewController.h"
@interface UploadSettingVC ()
@property (nonatomic, retain) SidebarViewController* sidebarVC;
@end
@implementation UploadSettingVC

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.sidebarVC = [[SidebarViewController alloc] init];
    [self.sidebarVC setBgRGB:0x000000];
    self.sidebarVC.view.frame  = self.view.bounds;
    [self.view addSubview:self.sidebarVC.view];
    [self.sidebarVC showHideSidebar];
}
-(IBAction)AutoSCHBtnPressed:(id)sender
{
    if(self.AutoSCH.on)
    {
        NSLog(@"on");
    }
    else
    {
        NSLog(@"off");        
    }
}
-(IBAction)SyncSCHBtnPressed:(id)sender
{
    if(self.SyncSCH.on)
    {
        NSLog(@"on");
    }
    else
    {
        NSLog(@"off");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
