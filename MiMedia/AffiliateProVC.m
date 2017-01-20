//
//  AffiliateProVC.m
//  Flippy Cloud
//
//  Created by isquare3 on 12/8/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import "AffiliateProVC.h"

@interface AffiliateProVC ()

@end

@implementation AffiliateProVC

- (void)viewDidLoad {
    [super viewDidLoad];

    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://46.166.173.116/FlippyCloud/affiliate/Login.aspx"]];
    
//  NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:URL];
    [self.ReadFileView loadRequest:urlRequest];
    [self.view addSubview:self.ReadFileView];
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
