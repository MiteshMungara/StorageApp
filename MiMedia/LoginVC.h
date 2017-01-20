//
//  LoginVC.h
//  MiMedia
//
//  Created by iSquare5 on 08/08/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@class GIDSignInButton;

@interface LoginVC : UIViewController
{
     CGFloat animateDistance;
}
@property (weak, nonatomic) IBOutlet FBLoginView *loginButton;
@property(weak, nonatomic) IBOutlet GIDSignInButton *signInButton;
@property (nonatomic) UITapGestureRecognizer *tapRecognizer;
@property (strong , nonatomic) IBOutlet UIView *BGView,*contantView;
@property (nonatomic,strong) IBOutlet UITextField *PhoneTxt;
@property (nonatomic,strong) IBOutlet UIButton *DontBtn;


-(IBAction)DoneBtnPressed:(id)sender;


-(IBAction)SignupBTNPressed:(id)sender;
-(IBAction)LoginMIBtnPressed:(id)sender;

@end
