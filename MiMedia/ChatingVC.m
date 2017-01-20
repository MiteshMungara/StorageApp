//
//  ChatingVC.m
//  Flippy Cloud
//
//  Created by isquare3 on 11/9/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import "ChatingVC.h"
#import "DriveSubVC.h"
#import "AppDelegate.h"
#import "Reachability.h"

@interface ChatingVC ()
{
    AppDelegate *app;
    NSMutableArray *ChatStrsArr;
    NSString *Messagetext;
    NSMutableArray *commentArr,*emailArr;
}
@end

@implementation ChatingVC
//@synthesize chatTableV;

- (void)viewDidLoad
{

    [super viewDidLoad];
//    commentArr = [[NSMutableArray alloc]init];
//    emailArr = [[NSMutableArray alloc]init];
//    app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
//    
//    
//    NSLog(@"%@",app.SharedDriveIdStr);
//    
//    
//    screenBounds = [[UIScreen mainScreen] bounds];
//    [self initPB];
//    [indicator startAnimating];
//    CGFloat width = [UIScreen mainScreen].bounds.size.width;
//    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(GetComment) userInfo:nil repeats:NO];
//    
//    self.chatTableV.frame = CGRectMake(0, self.view.frame.origin.y + 100, width,(self.view.frame.size.height -100)-commentView.frame.size.height);
//    [self setUpTextFieldforIphone];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillChangeOpen:)
//                                                 name:UIKeyboardWillShowNotification
//                                               object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillHide:)
//                                                 name:UIKeyboardWillHideNotification
//                                               object:nil];
//
//    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
//    [self.chatTableV addGestureRecognizer:gestureRecognizer];
    
}
//- (void)handleSingleTap:(UITapGestureRecognizer *) sender
//{
//    self.chatTableV.frame = CGRectMake(0, self.view.frame.origin.y + 100, self.view.frame.size.width,(self.view.frame.size.height + 80));
//    [self.view endEditing:YES];
//}
//
//-(void)GetComment
//{
//    if([[Reachability sharedReachability] internetConnectionStatus] == NotReachable){
//        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Check Internet Connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [indicator stopAnimating];
//        [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
//        [av show];
//    }
//    else
//    {
//        NSString *urlString = [[NSString alloc]initWithFormat:@"%@get_comment.php",app.Service ];
//        NSURL *url = [NSURL URLWithString:urlString];
//        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//        
//        NSString *myRequestString;
//        if([app.SharedDriveIdStr isEqualToString:@"null"])
//        {
//            myRequestString =[NSString stringWithFormat:@"{\"drive_id\":\"%@\"}",app.CollIdarr];
//        }
//        else
//        {
//            myRequestString =[NSString stringWithFormat:@"{\"drive_id\":\"%@\"}",app.SharedDriveIdStr];
//        }
//        
//
//        NSData *requestData = [NSData dataWithBytes:[myRequestString UTF8String] length:[myRequestString length]];
//        [request setHTTPMethod: @"POST"];
//        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//        [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
//        [request setHTTPBody: requestData];
//        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
//         {
//             if (!data)
//             {
//                 NSLog(@"%s: sendAynchronousRequest error: %@", __FUNCTION__, connectionError);
//                 return;
//             }
//             else if ([response isKindOfClass:[NSHTTPURLResponse class]])
//             {
//                 NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
//                 if (statusCode != 200)
//                 {
//                     NSLog(@"%s: sendAsynchronousRequest status code != 200: response = %@", __FUNCTION__, response);
//                     return;
//                 }
//             }
//             NSError *parseError = nil;
//             NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
//             NSLog(@"get_comment.php  ::::  %@",dictionary);
//             if (!dictionary)
//             {
//                 NSLog(@"%s: JSONObjectWithData error: %@; data = %@", __FUNCTION__, parseError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
//                 return ;
//             }
//             else
//             {
//                 NSString *success=[dictionary valueForKey:@"success"];
//                 if([success isEqualToString:@"1"])
//                 {
//                     NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//                     commentArr = [NSMutableArray arrayWithArray:[[dictionary valueForKey:@"posts"]valueForKey:@"comment"]];
//                     emailArr = [NSMutableArray arrayWithArray:[[dictionary valueForKey:@"posts"]valueForKey:@"user"]];
//                     
//
//                     [prefs setObject:commentArr forKey:@"commentArr"];
//                     [prefs setObject:emailArr forKey:@"emailArr"];
//                     [self.chatTableV reloadData];
//                     [indicator stopAnimating];
//                     [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
//                 }
//                 else
//                 {
//                     [indicator stopAnimating];
//                     [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
//                 }
//             }
//         }];
//    }
//}
//-(IBAction)BackBtnPressed:(id)sender
//{
//    UINavigationController *navigationController = (UINavigationController *)app.window.rootViewController;
//    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
//    DriveSubVC *Main = (DriveSubVC *)[mainStoryboard instantiateViewControllerWithIdentifier: @"DriveSubVC"];
//    [navigationController pushViewController:Main animated:NO];
//}
//
//#pragma mark - Table View ChatView
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return commentArr.count;
//}
//
////Delete Button  on swipe of cell in table view codding here
////- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
////    return YES;
////}
////- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
////    if (editingStyle == UITableViewCellEditingStyleDelete) {
////        NSLog(@"add code here for when you hit delete");
////    }
////}
////--------------------
//
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSString *cellText =[NSString stringWithFormat:@"%@",[commentArr objectAtIndex:indexPath.row]];
//    UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:15.0];
//    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
//    CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
//    return labelSize.height + 30;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString* cellIdentifier = @"messagingCell";
//    UITableViewCell * cell =  [chatTableV dequeueReusableCellWithIdentifier:cellIdentifier];
//    if (cell == nil)
//    {
//        cell =  [chatTableV dequeueReusableCellWithIdentifier:cellIdentifier];
//        cell.backgroundColor = [UIColor clearColor];
//    }
//    cell.textLabel.text =[NSString stringWithFormat:@"%@",[emailArr objectAtIndex:indexPath.row]];
//    cell.detailTextLabel.text=[NSString stringWithFormat:@"%@",[commentArr objectAtIndex:indexPath.row]];
//    cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
//    cell.detailTextLabel.numberOfLines = 0;
//    cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
//    
//    return cell;
//}
////*************
//
//-(IBAction)sendBtnClickedOfCV:(id)sender
//{
//
//    if((messageTf.text=@""))
//    {
//        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"You can not send blank message." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [av show];
//        [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
//        
//    }
//    else
//    {
//    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(SendComment) userInfo:nil repeats:NO];
//    }
//
//}
//-(void)SendComment
//{
//    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
//    if([[Reachability sharedReachability] internetConnectionStatus] == NotReachable)
//    {
//        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Check Internet Connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [av show];
//        [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
//    }
//    else
//    {
//        if ([messageTf.text isEqual:@"Write a message..."])
//        {
//            Messagetext = nil;
//        }
//        else
//        {
//            Messagetext = messageTf.text;
//        }
//        if ([Messagetext length] == 0)
//        {
//            return;
//        }
//        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//        NSString *email=[prefs valueForKey:@"email"];
//        NSString *urlString = [[NSString alloc]initWithFormat:@"%@set_comment.php",app.Service ];
//        NSURL *url = [NSURL URLWithString:urlString];
//        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//        
//        NSString *myRequestString;
//        if([app.SharedDriveIdStr isEqualToString:@"null"])
//        {
//             myRequestString =[NSString stringWithFormat:@"{\"drive_id\":\"%@\",\"user\":\"%@\",\"comment\":\"%@\"}",app.CollIdarr,email,Messagetext];
//        }
//        else
//        {
//             myRequestString =[NSString stringWithFormat:@"{\"drive_id\":\"%@\",\"user\":\"%@\",\"comment\":\"%@\"}",app.SharedDriveIdStr,email,Messagetext];
//        }
//        
//       
//        NSData *requestData = [NSData dataWithBytes:[myRequestString UTF8String] length:[myRequestString length]];
//        [request setHTTPMethod: @"POST"];
//        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//        [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
//        [request setHTTPBody: requestData];
//        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
//         {
//             NSError *parseError = nil;
//             NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
//                          NSLog(@"set_comment.php  ::::  %@",dictionary);
//             if (!dictionary)
//             {
//                 NSLog(@"%s: JSONObjectWithData error: %@; data = %@", __FUNCTION__, parseError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
//                 return ;
//             }
//             else
//             {
//             }
//             [commentArr addObject:Messagetext];
//             [emailArr addObject:email];
//
//             [self TableView_Reload_Bottom];
//             messageTf.text=nil;
//             [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
//         }];
//    }
//}
//
//#pragma mark - frame textview
//-(void)setUpTextFieldforIphone
//{
//    commentView.frame=CGRectMake(0, screenBounds.size.height-50, screenBounds.size.width, 50);
//    messageTf = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(8, 10, screenBounds.size.width-65, 35)];
//    messageTf.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
//    messageTf.minNumberOfLines = 1;
//    messageTf.maxNumberOfLines = 6;
//    messageTf.returnKeyType = UIReturnKeyDefault;
//    messageTf.font = [UIFont systemFontOfSize:16.0f];
//    messageTf.delegate = self;
//    messageTf.backgroundColor = [UIColor whiteColor];
//    [messageTf setKeyboardType:UIKeyboardTypeAlphabet];
//    [self commentsTextVPlaceholder];
//    [commentView addSubview:messageTf];
//}
//
//#pragma mark - Textview Placeholder
//-(void)commentsTextVPlaceholder
//{
//    [messageTf setText:@"Write a message..."];
//    [messageTf setFont:[UIFont fontWithName:@"HelveticaNeue" size:16]];
//    [messageTf setTextColor:[UIColor lightGrayColor]];
//    [messageTf scrollRangeToVisible:NSMakeRange(0, 0)];
//}
//- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
//{
//    float diff = (growingTextView.frame.size.height - height);
//    CGRect r = commentView.frame;
//    r.size.height -= diff;
//    r.origin.y += diff;
//    commentView.frame = r;
//}
//#pragma mark - Keybord Method
//- (void)keyboardWillChangeOpen:(NSNotification *)note
//{
//    if ([messageTf.text isEqual:@"Write a message..."])
//    {
//        messageTf.text = @"";
//        messageTf.textColor = [UIColor blackColor];
//    }
//    // get keyboard size and loctaion
//    CGRect keyboardBounds;
//    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
//    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
//    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
//    // Need to translate the bounds to account for rotation.
//    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
//
//    // get a rect for the textView frame
//    CGRect containerFrame = commentView.frame;
//    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
//    CGRect tableviewframe=chatTableV.frame;
//    screenBounds = [[UIScreen mainScreen] bounds];
//    tableviewframe.size.height = screenBounds.size.height - 360;
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationBeginsFromCurrentState:YES];
//    [UIView setAnimationDuration:[duration doubleValue]];
//    [UIView setAnimationCurve:[curve intValue]];
//    commentView.frame = containerFrame;
//    chatTableV.frame=tableviewframe;
//    [UIView commitAnimations];
//}
//
//- (void)keyboardWillHide:(NSNotification *)note
//{
//    self.chatTableV.frame = CGRectMake(0, self.view.frame.origin.y + 100, self.view.frame.size.width,(self.view.frame.size.height - 100));
//    if(messageTf.text.length == 0){
//        [self commentsTextVPlaceholder];
//    }
//    //TextView
//    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
//    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
//    CGRect keyboardBounds;
//    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
//    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
//
//    // get a rect for the textView frame
//    CGRect containerFrame = commentView.frame;
//    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
//    CGRect tableviewframe=chatTableV.frame;
//
//    //tableviewframe.size.height+=260;
//    screenBounds = [[UIScreen mainScreen] bounds];
//    tableviewframe.size.height = screenBounds.size.height-150;
//
//    // animations settings
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationBeginsFromCurrentState:YES];
//    [UIView setAnimationDuration:[duration doubleValue]];
//    [UIView setAnimationCurve:[curve intValue]];
//
//    //set views with new info
//    chatTableV.frame=tableviewframe;
//    commentView.frame = containerFrame;
//
//    //commit animations
//    [UIView commitAnimations];
//}
//-(void) initPB
//{
//    indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
//    indicator.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width)/2, ([UIScreen mainScreen].bounds.size.height)/2 , 70.0, 70.0);
//    indicator.layer.cornerRadius = 17;
//    indicator.backgroundColor = [UIColor blackColor];
//    indicator.center = self.view.center;
//    [self.view addSubview:indicator];
//    [indicator bringSubviewToFront:self.view];
//    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
//}
//
//-(void)TableView_Reload_Bottom
//{
//    if (commentArr.count>0)
//    {
//        [chatTableV reloadData];
//        NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:([commentArr count] - 1) inSection:0];
//        [chatTableV scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//        [chatTableV beginUpdates];
//        [chatTableV reloadRowsAtIndexPaths:[NSArray arrayWithObjects:scrollIndexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
//        [chatTableV endUpdates];
//    }
//}

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
