//
//  ReadFileVC.m
//  Flippy Cloud
//
//  Created by isquare3 on 12/6/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import "ReadFileVC.h"
#import "AppDelegate.h"

@interface ReadFileVC ()
{
    AppDelegate *app;
        UIActivityIndicatorView *indicator;
}

@end

@implementation ReadFileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
        [self initPB];
    self.FileNameLbl.text =[NSString stringWithFormat:@"%@",app.ReadingFileNameStr];
//    [indicator startAnimating];
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(LoadFile) userInfo:nil repeats:NO];
    
    

}
-(void) initPB{
    indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    indicator.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width)/2, (self.ReadFileView.frame.size.height)/2 , 70.0, 70.0);
    indicator.layer.cornerRadius = 17;
    indicator.backgroundColor = [UIColor blackColor];
    indicator.center = self.view.center;
    [self.ReadFileView addSubview:indicator];
    [indicator bringSubviewToFront:self.view];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
}

-(void)LoadFile
{
//    [indicator startAnimating];
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",app.ReadFileUrlStr]];
    
    //    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:URL];
    [self.ReadFileView loadRequest:urlRequest];
    [self.view addSubview:self.ReadFileView];

    [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(StopIndicator) userInfo:nil repeats:NO];

}
-(void)StopIndicator
{
    [indicator stopAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
}
-(IBAction)BackBtnPressed:(id)sender
{
        [self.navigationController popViewControllerAnimated:YES];
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
