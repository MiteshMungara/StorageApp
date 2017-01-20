//
//  UpgradePlanVC.m
//  Flippy Cloud
//
//  Created by isquare3 on 10/17/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//
//If you have more than one in-app purchase, you can define both of
//of them here. So, for example, you could define both kRemoveAdsProductIdentifier
//and kBuyCurrencyProductIdentifier with their respective product ids
//
//for this example, we will only use one product

#define kRemoveAdsProductIdentifierStandardPlan @"999"
#define kRemoveAdsProductIdentifier @"2000"
#define kRemoveAdsProductIdentifierPremiumPlus @"3500"
#define kRemoveAdsProductIdentifierBusiness @"Business"
#import "UpgradePlanVC.h"
#import "Reachability.h"
#import "AppDelegate.h"

@interface UpgradePlanVC ()
{
    AppDelegate *app;
    UIActivityIndicatorView *indicator;
    BOOL areAdsRemoved;
    NSString *CurrentDateStr,*TransationIdStr,*UserIdAppStr,*UserEmailIDAppStr,*UseridStr,*emailidStr,*PlanNameStr,*DurationStr;
    SKReceiptRefreshRequest *_refreshRequest;
    NSString *restore;
}
@end

@implementation UpgradePlanVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initPB];
    NSLog(@"%f",self.view.frame.size.height);
    app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    self.scrollview.contentSize=CGSizeMake(self.view.frame.size.width,(self.view.frame.size.height * 2)-200);
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *success=[prefs valueForKey:@"success"];
    if ([success isEqualToString:@"1"])
    {
        self.RestoreBtn.hidden=YES;
    }
    else
    {
        self.RestoreBtn.hidden=NO;
    }
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}
-(IBAction)BackBtnPressed:(id)sender
{
    app.view=@"upgradeplan";
    [self.navigationController popViewControllerAnimated:YES];
}
-(IBAction)StandardBtnPressed:(id)sender
{
    NSLog(@"premium");
    [self checkPurchasedItems];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSDate *todaysDate;
    todaysDate = [NSDate date];
    NSLog(@"Todays date is %@",[formatter stringFromDate:todaysDate]);
    CurrentDateStr =[NSString stringWithFormat:@"%@",[formatter stringFromDate:todaysDate]];
    
    NSLog(@"User requests to remove ads");
    if([SKPaymentQueue canMakePayments])
    {
        NSLog(@"User can make payments");
        SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:kRemoveAdsProductIdentifierStandardPlan]];
        productsRequest.delegate = self;
        [productsRequest start];
    }
    else
    {
        NSLog(@"User cannot make payments due to parental controls");
    }
}
-(IBAction)PremiumBtnPressed:(id)sender
{
    NSLog(@"premium");
    [self checkPurchasedItems];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSDate *todaysDate;
    todaysDate = [NSDate date];
    NSLog(@"Todays date is %@",[formatter stringFromDate:todaysDate]);
    CurrentDateStr =[NSString stringWithFormat:@"%@",[formatter stringFromDate:todaysDate]];

    NSLog(@"User requests to remove ads");
    if([SKPaymentQueue canMakePayments])
    {
        NSLog(@"User can make payments");
        SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:kRemoveAdsProductIdentifier]];
        productsRequest.delegate = self;
        [productsRequest start];
    }
    else
    {
        NSLog(@"User cannot make payments due to parental controls");
    }
}
-(IBAction)PremiunPlusBtnPressed:(id)sender
{
    NSLog(@"premium+");
    NSLog(@"User requests to remove ads");
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSDate *todaysDate;
    todaysDate = [NSDate date];
    NSLog(@"Todays date is %@",[formatter stringFromDate:todaysDate]);
    CurrentDateStr =[NSString stringWithFormat:@"%@",[formatter stringFromDate:todaysDate]];
    if([SKPaymentQueue canMakePayments])
    {
        NSLog(@"User can make payments");
        SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:kRemoveAdsProductIdentifierPremiumPlus]];
        productsRequest.delegate = self;
        [productsRequest start];
    }
    else
    {
        NSLog(@"User cannot make payments due to parental controls");
    }
}
//-(IBAction)BusinessBtnPressed:(id)sender
//{
//    NSLog(@"Bussiness");
//    NSLog(@"User requests to remove ads");
//    if([SKPaymentQueue canMakePayments])
//    {
//        NSLog(@"User can make payments");
//        SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:kRemoveAdsProductIdentifierBusiness]];
//        productsRequest.delegate = self;
//        [productsRequest start];
//    }
//    else
//    {
//        NSLog(@"User cannot make payments due to parental controls");
//    }
//}
-(void)PlanPurchasing
{
    
        if([[Reachability sharedReachability] internetConnectionStatus] == NotReachable)
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Check Internet Connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
        else
        {
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSString *email=[prefs valueForKey:@"email"];
            NSString *Userid=[prefs valueForKey:@"id"];

            NSString *urlString = [[NSString alloc]initWithFormat:@"%@add_paypal_upgrade_plan.php",app.Service ];
            NSURL *url = [NSURL URLWithString:urlString];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
            NSString *myRequestString =[NSString stringWithFormat:@"{\"transation_date_time\":\"%@\",\"transation_id\":\"%@\",\"userid\":\"%@\",\"emailid\":\"%@\",\"duration\":\"1\",\"userid1\":\"%@\",\"emailid1\":\"%@\",\"planname\":\"%@\"}",CurrentDateStr,TransationIdStr,Userid,email,Userid,email,PlanNameStr];

            NSData *requestData = [NSData dataWithBytes:[myRequestString UTF8String] length:[myRequestString length]];
            [request setHTTPMethod: @"POST"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody: requestData];
            [request setTimeoutInterval:300];
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
                
                
                NSLog(@"add_paypal_upgrade_plan.php   ::::  %@",dictionary);
                
                if (!dictionary)
                {
                    NSLog(@"%s: JSONObjectWithData error: %@; data = %@", __FUNCTION__, parseError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                    return ;
                }
                else
                {
                    NSLog(@"add_paypal_upgrade_plan : %@",dictionary);
                    NSString *success=[dictionary valueForKey:@"Success"];

                    if([success  isEqualToString:@"1"])
                    {
                        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(CheckValidityForPlan) userInfo:nil repeats:NO];
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
                    }
                    else
                    {
                     [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
                    }
                }
            }];
        }
}
-(void)CheckValidityForPlan
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
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY-MM-dd"];
        NSDate *todaysDate;
        todaysDate = [NSDate date];
        NSString  * CurrentDateStr1 =[NSString stringWithFormat:@"%@",[formatter stringFromDate:todaysDate]];
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *email=[prefs valueForKey:@"email"];
        NSString *urlString = [[NSString alloc]initWithFormat:@"%@get_paypal_upgrade_plan.php",app.Service ];
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSString *myRequestString =[NSString stringWithFormat:@"{\"transation_date_time\":\"%@\",\"emailid\":\"%@\"}",CurrentDateStr1,email];
        NSData *requestData = [NSData dataWithBytes:[myRequestString UTF8String] length:[myRequestString length]];
        [request setHTTPMethod: @"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody: requestData];
        [request setTimeoutInterval:300];
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
            
            NSLog(@"get_paypal_upgrade_plan.php   ::::  %@",dictionary);
            
            if (!dictionary)
            {
                NSLog(@"%s: JSONObjectWithData error: %@; data = %@", __FUNCTION__, parseError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                return ;
            }
            else
            {
                //                NSLog(@"%@",dictionary);
                NSLog(@"premium : %@",dictionary);
                NSString *success=[NSString stringWithFormat:@"%@",[dictionary valueForKey:@"success"]];
                if([success isEqualToString:@"1"])
                {
                    [prefs setObject:success forKey:@"success"];
                    [indicator stopAnimating];
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
                }
                else
                {
                    [prefs setObject:success forKey:@"success"];
                    [indicator stopAnimating];
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
                }
                [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
            }
        }];
    }
}

-(void) initPB{
    indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width)/2, ([UIScreen mainScreen].bounds.size.height)/2 , 70.0, 70.0);
    indicator.layer.cornerRadius = 17;
    indicator.backgroundColor = [UIColor whiteColor];
    indicator.center = self.view.center;
    [self.view addSubview:indicator];
    [indicator bringSubviewToFront:self.view];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
}

-(void)requestDidFinish:(SKRequest *)request
{
    if([request isKindOfClass:[SKReceiptRefreshRequest class]])
    {
        NSLog(@"Got a new receipt... %@",request.description);
        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    }
}
-(void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"%@",error.description);
}
- (IBAction)tapsRemoveAds
{
}
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    SKProduct *validProduct = nil;
    int count = (int)[response.products count];
    if(count > 0){
        validProduct = [response.products objectAtIndex:0];
        NSLog(@"Products Available!");
        NSLog(@"Title %@",[NSString stringWithFormat:
                           @"Product Title: %@",validProduct.localizedTitle]);
        NSLog(@"Desc %@",[NSString stringWithFormat:
                          @"Product Desc: %@",validProduct.localizedDescription]);
        NSLog(@"Price %@",[NSString stringWithFormat:
                           @"Product Desc: %@",validProduct.localizedDescription]);
        NSString *plan =[NSString stringWithFormat:@"%@",validProduct.localizedTitle];
        
        if([plan isEqualToString:@"Flippy Cloud Premium Plan"])
        {
            PlanNameStr = @"500 GB";
        }
        else if ([plan isEqualToString:@"Flippy Cloud Standard Plan"])
        {
            PlanNameStr = @"200 GB";
        }
        else
        {
            PlanNameStr = @"1 TB";
        }
        
        if([validProduct.localizedTitle isEqualToString:@"Flippy Cloud Premium Plan"])
        {
            NSLog(@"2000 ");
            TransationIdStr = [NSString stringWithFormat:@"2000"];
        }
        else if ([plan isEqualToString:@"Flippy Cloud Standard Plan"])
        {
            NSLog(@"999 ");
            TransationIdStr = [NSString stringWithFormat:@"999"];
        }

        else
        {
            NSLog(@"3500 ");
            TransationIdStr = [NSString stringWithFormat:@"3500"];
        }
        [self purchase:validProduct];
    }
    else if(!validProduct){
        NSLog(@"No products available");
        UIAlertView *tmp = [[UIAlertView alloc]
                            initWithTitle:@"Not Available"
                            message:@"No products to purchase"
                            delegate:self
                            cancelButtonTitle:nil
                            otherButtonTitles:@"Ok", nil];
        [tmp show];
    }
}
- (void)purchase:(SKProduct *)product
{
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (IBAction) restore{
    //    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    //    NSData *receipt = [NSData dataWithContentsOfURL:receiptURL];
    //    if (!receipt) {
    //        SKReceiptRefreshRequest * request = [[SKReceiptRefreshRequest alloc] init];
    //        request.delegate = self;
    //        [request start];
    //    }
    // //   [self registerAsPurchaseObserver];
    //    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    //    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    restore =@"restore";
    _refreshRequest = [[SKReceiptRefreshRequest alloc] init];
    _refreshRequest.delegate = self;
    [_refreshRequest start];
}

-(void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    NSLog(@"restoreCompletedTransactionsFailedWithError %@",error);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Restore Process Failed..." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}
- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"%@",queue );
    NSLog(@"Restored Transactions are once again in Queue for purchasing %@",[queue transactions]);
    NSMutableArray *purchasedItemIDs = [[NSMutableArray alloc] init];
    NSLog(@"received restored transactions: %lu", (unsigned long)queue.transactions.count);
    for (SKPaymentTransaction *transaction in queue.transactions) {
        NSString *productID = transaction.payment.productIdentifier;
        [purchasedItemIDs addObject:productID];
        NSLog (@"product id is %@" , productID);
    }
//    if([restore isEqualToString:@"restore"])
//    {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Restore Completed" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alert show];
//        
//    }

}
//- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
//{
//    NSLog(@"received restored transactions: %lu", (unsigned long)queue.transactions.count);
//    for(SKPaymentTransaction *transaction in queue.transactions){
//        if(transaction.transactionState == SKPaymentTransactionStateRestored){
//            //called when the user successfully restores a purchase
//            NSLog(@"Transaction state -> Restored");
//            
//            //if you have more than one in-app purchase product,
//            //you restore the correct product for the identifier.
//            //For example, you could use
//            //if(productID == kRemoveAdsProductIdentifier)
//            //to get the product identifier for the
//            //restored purchases, you can use
//            //
//            //NSString *productID = transaction.payment.productIdentifier;
////            [self doRemoveAds];
//            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
//            break;
//        }
//    }   
//}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for(SKPaymentTransaction *transaction in transactions)
    {
        switch(transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchasing: NSLog(@"Transaction state -> Purchasing");
               break;
            case SKPaymentTransactionStatePurchased:
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                NSLog(@"Transaction state -> Purchased successfully");
                self.RestoreBtn.hidden=NO;
                [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(PlanPurchasing) userInfo:nil repeats:NO];
                break;

            case SKPaymentTransactionStateRestored:
                NSLog(@"Transaction state -> Restored");
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            
            case SKPaymentTransactionStateFailed:
                if(transaction.error.code == SKErrorPaymentCancelled){
                    NSLog(@"Transaction state -> Cancelled");
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
        }
    }
}
-(void)ShowMSG
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info"
                                                    message:@"Transaction Restored Successfully"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}
-(void)checkPurchasedItems
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

//Then this delegate Function Will be fired
// called when a transaction has failed

- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
     if (transaction.error.code == SKErrorClientInvalid) {
//            [self showAlert:@"In-App Purchase" withMessage:INVALID_CLIENT];
        }
        else if (transaction.error.code == SKErrorPaymentInvalid) {
            //[self showAlert:@"In-App Purchase" withMessage:PAYMENT_INVALID];
        }
        else if (transaction.error.code == SKErrorPaymentNotAllowed) {
            //[self showAlert:@"In-App Purchase" withMessage:PAYMENT_NOT_ALLOWED];
        }
        else if (transaction.error.code == SKErrorPaymentCancelled) {
            // [self showAlert:@"In-App Purchase" withMessage:@"This device is not allowed to make the payment."];
            NSLog(@"User Cancellation.");
        }
        else {
            // SKErrorUnknown
            NSLog(@"Unknown Reason.");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Transaction Status" message:@"Transaction Failed due to unknown reason" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
    else {
    }
}
- (void)provideContent:(NSString *)productId
{
    if ([productId isEqualToString:kRemoveAdsProductIdentifier])
    {
        // enable the pro features
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isStorePurchased"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else if([productId isEqualToString:kRemoveAdsProductIdentifierPremiumPlus])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isStoreSubscribed"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
}
-(IBAction)PurchasePlanBtnPressed:(id)sender
{
}
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
