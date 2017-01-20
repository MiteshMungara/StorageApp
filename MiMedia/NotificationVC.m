//
//  NotificationVC.m
//  Flippy Cloud
//
//  Created by isquare3 on 11/9/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import "NotificationVC.h"
#import "AppDelegate.h"
#import "SidebarViewController.h"
#import "Reachability.h"

@interface NotificationVC () <UITableViewDataSource,UITableViewDelegate>
{
    AppDelegate *app;
    UIActivityIndicatorView *indicator;
    NSArray  *MsgArr,*DateArr;
    UILabel *MessageLabel;
    UILabel *subtitle;
    NSMutableArray *heightarr;
}

@property (nonatomic, retain) SidebarViewController* sidebarVC;

@end

@implementation NotificationVC

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    self.sidebarVC = [[SidebarViewController alloc] init];
    [self.sidebarVC setBgRGB:0x000000];
    self.sidebarVC.view.frame  = self.view.bounds;
    [self.view addSubview:self.sidebarVC.view];
    [self.sidebarVC showHideSidebar];
    [self initPB];
    if([[Reachability sharedReachability] internetConnectionStatus] == NotReachable){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Check Internet Connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [indicator stopAnimating];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
        [av show];
    }
    else
    {
        [indicator startAnimating];
        [self getNotification];
    }
}
- (IBAction)show:(id)sender
{
    [self.sidebarVC showHideSidebar];
}
- (void)panDetected:(UIPanGestureRecognizer*)recoginzer
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

-(void)getNotification
{

    NSString *urlString = [[NSString alloc]initWithFormat:@"%@message.php",app.Service ];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
   [request setHTTPMethod: @"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
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
        
        NSLog(@"message.php   ::::  %@",dictionary);
        if (!dictionary)
        {
            NSLog(@"%s: JSONObjectWithData error: %@; data = %@", __FUNCTION__, parseError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            return ;
        }
        else
        {
            if([[dictionary valueForKey:@"success"] isEqualToString:@"1"])
            {
                MsgArr=[[dictionary valueForKey:@"post"]valueForKey:@"message"];
                DateArr=[[dictionary valueForKey:@"post"]valueForKey:@"date"];
                heightarr = [[NSMutableArray alloc]init];
                for (int i=0; i<MsgArr.count; i++) {
                    [heightarr addObject:@""];
                }
                self.chatTableV.dataSource=self;
                self.chatTableV.delegate = self;
                [self.chatTableV reloadData];
                self.EmptyNotification.hidden=YES;
                [indicator stopAnimating];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
            }
            else
            {
                self.EmptyNotification.hidden=NO;
                [indicator stopAnimating];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
            }
        }
    }];
}
#pragma mark - Table View ChatView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return MsgArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *heightstr = [NSString stringWithFormat:@"%@",[heightarr objectAtIndex:indexPath.row]];
    if (![heightstr isEqualToString:@""]) {
        int height = [heightstr intValue];
        height = height;
        return height;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"messagingCell";
    UITableViewCell * cell =  [self.chatTableV dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell =  [self.chatTableV dequeueReusableCellWithIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
    }

    MessageLabel = (UILabel *)[cell viewWithTag:1];
    MessageLabel.text = [NSString stringWithFormat:@"%@",[MsgArr objectAtIndex:indexPath.row]];
    MessageLabel.numberOfLines = 0;
    MessageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    CGSize maximumLabelSize = CGSizeMake(MessageLabel.frame.size.width, CGFLOAT_MAX);
    CGSize expectSize = [MessageLabel sizeThatFits:maximumLabelSize];
    MessageLabel.frame = CGRectMake(MessageLabel.frame.origin.x, MessageLabel.frame.origin.y, MessageLabel.frame.size.width, expectSize.height);

    subtitle = (UILabel *)[cell viewWithTag:2];
    subtitle.text = [NSString stringWithFormat:@"%@",[DateArr objectAtIndex:indexPath.row]];
    int height = round(MessageLabel.frame.origin.y) + round(MessageLabel.frame.size.height)+15;
    [heightarr replaceObjectAtIndex:indexPath.row withObject:[NSString stringWithFormat:@"%d",height]];
    return cell;
}
-(void)TableView_Reload_Bottom
{
    if (MsgArr.count>0)
    {
        [self.chatTableV reloadData];
        NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:([MsgArr count] - 1) inSection:0];
        [self.chatTableV scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        [self.chatTableV beginUpdates];
        [self.chatTableV reloadRowsAtIndexPaths:[NSArray arrayWithObjects:scrollIndexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
        [self.chatTableV endUpdates];
    }
}
//*************


- (void)didReceiveMemoryWarning {
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
