//
//  UpgradePlanVC.h
//  Flippy Cloud
//
//  Created by isquare3 on 10/17/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
@interface UpgradePlanVC : UIViewController  <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (nonatomic,weak) IBOutlet UIScrollView *scrollview;

@property(strong,nonatomic) SKProduct *product;
@property(strong,nonatomic) NSString *productID;
@property (strong,nonatomic) IBOutlet UIButton *RestoreBtn,*PremiumBtn,*PremiumPlusBtn;

-(IBAction)BackBtnPressed:(id)sender;
-(IBAction)PremiumBtnPressed:(id)sender;
-(IBAction)PremiunPlusBtnPressed:(id)sender;

//-(IBAction)BusinessBtnPressed:(id)sender;

- (IBAction)restore;
- (IBAction)tapsRemoveAds;

-(IBAction)PurchasePlanBtnPressed:(id)sender;

@end
