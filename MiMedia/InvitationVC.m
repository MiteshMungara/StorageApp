//
//  InvitationVC.m
//  Flippy Cloud
//
//  Created by isquare3 on 16/01/17.
//  Copyright © 2017 MitSoft. All rights reserved.
//

#import "InvitationVC.h"
#import "AppDelegate.h"
#import "SubDriveVC.h"
#import "Reachability.h"
#import <MessageUI/MessageUI.h>
@interface InvitationVC ()<MFMessageComposeViewControllerDelegate>
{
    UITableViewCell * Tcell;
    AppDelegate *app;
    NSString *ContactToSendMsg;
    NSMutableArray *SelectMobileNo;
    UIActivityIndicatorView *indicator;
}

@end

@implementation InvitationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    self.InviteBtn.hidden=YES;
    self.EmailTableView.allowsMultipleSelection=YES;
    
    [app.RemainingContList removeObject:@""];
    [self.EmailTableView reloadData];
    SelectMobileNo = [[NSMutableArray alloc]init];

}

/*#pragma mark - Table View ChatView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
        return app.RemainingContList.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
        return 60;
 
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
        static NSString* cellIdentifier = @"EmailTableView";
        Tcell =  [self.EmailTableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (Tcell == nil)
        {
            Tcell =  [self.EmailTableView dequeueReusableCellWithIdentifier:cellIdentifier];
            Tcell.backgroundColor = [UIColor clearColor];
        }
        UILabel *ContactEmail=(UILabel *)[Tcell viewWithTag:2];
        UILabel *ContactFirstChar=(UILabel *)[Tcell viewWithTag:1];
        UILabel *fullName=(UILabel *)[Tcell viewWithTag:3];
        NSString *Contact=[app.RemainingContList objectAtIndex:indexPath.row];
    
    for (int k=0; k<[app.demoList count]; k++)
    {
        NSLog(@"%@",[app.demoList objectAtIndex:k]);
        if ([[app.demoList objectAtIndex:k] containsString:Contact])
        {
            NSLog(@"string contains bla!");
            NSString *Demostr=[app.demoList objectAtIndex:k];
            NSArray *items = [Demostr componentsSeparatedByString:@","];
            fullName.text=[items objectAtIndex:0];
            ContactFirstChar.text=[NSString stringWithFormat:@"%@",[[items objectAtIndex:0] substringToIndex:1]];
        }
        else
        {
            NSLog(@"string does not contain bla");
        }
    }
    ContactEmail.text=[NSString stringWithFormat:@"%@",Contact];
   return Tcell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.InviteBtn.hidden=NO;
            ContactToSendMsg=[NSString stringWithFormat:@"%@",[app.RegContactList objectAtIndex:indexPath.row]];
            [SelectMobileNo addObject:ContactToSendMsg];
}

-(void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{

    [SelectMobileNo removeObject:[NSString stringWithFormat:@"%@",[app.RegContactList objectAtIndex:indexPath.row]]];
}*/
// ------  collection view start   -------
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
     return app.RemainingContList.count;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
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
    UILabel *ContactEmail=(UILabel *)[cell viewWithTag:2];
    UILabel *ContactFirstChar=(UILabel *)[cell viewWithTag:1];
    UILabel *fullName=(UILabel *)[cell viewWithTag:3];
    NSString *Contact=[app.RemainingContList objectAtIndex:indexPath.row];
    
    for (int k=0; k<[app.demoList count]; k++)
    {
        NSLog(@"%@",[app.demoList objectAtIndex:k]);
        if ([[app.demoList objectAtIndex:k] containsString:Contact])
        {
            NSLog(@"string contains bla!");
            NSString *Demostr=[app.demoList objectAtIndex:k];
            NSArray *items = [Demostr componentsSeparatedByString:@","];
            fullName.text=[items objectAtIndex:0];
            ContactFirstChar.text=[NSString stringWithFormat:@"%@",[[items objectAtIndex:0] substringToIndex:1]];
        }
        else
        {
            NSLog(@"string does not contain bla");
        }
    }
    ContactEmail.text=[NSString stringWithFormat:@"%@",Contact];
    return cell;
}
-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
        UICollectionViewCell* cell=[collectionView cellForItemAtIndexPath:indexPath];
        cell.contentView.backgroundColor = [UIColor lightGrayColor];
        self.InviteBtn.hidden=NO;
        ContactToSendMsg=[NSString stringWithFormat:@"%@",[app.RemainingContList objectAtIndex:indexPath.row]];
        [SelectMobileNo addObject:ContactToSendMsg];
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell=[collectionView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = nil;

    [SelectMobileNo removeObject:[NSString stringWithFormat:@"%@",[app.RemainingContList objectAtIndex:indexPath.row]]];
    if(SelectMobileNo.count == 0)
    {
        self.InviteBtn.hidden=YES;
    }
    else
    {
        self.InviteBtn.hidden=NO;
    }
}
-(IBAction)BackBtnPressed:(id)sender
{
    UINavigationController *navigationController = (UINavigationController *)app.window.rootViewController;
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    SubDriveVC *Listroute = (SubDriveVC *)[mainStoryboard instantiateViewControllerWithIdentifier: @"SubDriveVC"];
    [navigationController pushViewController:Listroute animated:YES];
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
        NSLog(@"%@",SelectMobileNo);
        [self showSMS:selectedFile];
    }
}
- (void)showSMS:(NSString*)file
{
//    if(![MFMessageComposeViewController canSendText])
//    {
//        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [warningAlert show];
//        return;
//    }
//    NSArray *recipents = [[NSArray alloc]initWithArray:SelectMobileNo];
    NSString *message = [NSString stringWithFormat:@" %@ ", file];
//
//    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
//    messageController.messageComposeDelegate = self;
//    [messageController setRecipients:recipents];
//    [messageController setBody:message];
//    [self presentViewController:messageController animated:YES completion:nil];
    
    
    MFMessageComposeViewController *messageVC = [[MFMessageComposeViewController alloc] init];
    messageVC.messageComposeDelegate = self;
    messageVC.recipients = [NSArray arrayWithObject:@"9913906093"];
    messageVC.body = @"blha blah,,,,";
    UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"SMS fired" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [warningAlert show];
  [self presentModalViewController:messageVC animated:YES];
//    [self presentViewController:messageVC animated:YES completion:nil];
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
//    [self.EmailTableView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
    [indicator stopAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
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
