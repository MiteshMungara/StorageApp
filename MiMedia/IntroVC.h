//
//  IntroVC.h
//  MiMedia
//
//  Created by iSquare5 on 08/08/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntroVC : UIViewController<UIPageViewControllerDataSource>


@property (nonatomic,strong) IBOutlet UIView *PagingV;

@property (nonatomic,strong) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) UIPageControl *pageControl;

@property (nonatomic,strong) IBOutlet UIButton *openMenu;

@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageImages,*pageImagesCopy;


-(IBAction)BackupSyncBtnPressed:(id)sender;
-(IBAction)PlusBtnPressed:(id)sender;






@end
