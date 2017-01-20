//
//  CollectionVC.h
//  Flippy Cloud
//
//  Created by iSquare5 on 18/08/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import "ViewController.h"


@interface CollectionVC : ViewController

@property (nonatomic,weak) IBOutlet UIButton *menuBtn,*addBtn,*createBtn,*cancelBtn;
@property (nonatomic,weak) IBOutlet UILabel *headingL;
@property (nonatomic,weak) IBOutlet UIView *collectionCreateView,*mainHeaderView,*mainView;
@property (nonatomic,weak) IBOutlet UITextField *CollectionTxt;
@property (nonatomic,strong) IBOutlet UIButton *openMenu;
@property (nonatomic) UITapGestureRecognizer *tapRecognizer;


//collectionView
@property (nonatomic,weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic,weak) IBOutlet UILabel *collTitleL,*totalImgL;
//--stop

-(IBAction)addBtnPressed:(id)sender;
-(IBAction)CreateCollBtnPressed:(id)sender;
-(IBAction)CancelBtnPressed:(id)sender;
-(IBAction)createBtnPressed:(id)sender;
@end
