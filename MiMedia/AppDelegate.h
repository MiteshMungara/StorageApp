//
//  AppDelegate.h
//  MiMedia
//
//  Created by iSquare5 on 08/08/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic,retain) NSString *photoORvideoStr,*CollRow,*ImageBase,*LikedStatusForDelete,*deviceTokenStr;
@property (nonatomic,retain) NSString *videoSaveOrNotStr,*superCollName;
@property (nonatomic,strong) NSString *imagepath,*view,*selImage,*SelImgId,*favSelId,*ManuallySelImageStr, *SetThumbImageV ,*FavSelImageStr,*setThumbFavStr;
@property (nonatomic,strong) UIImage *ManuallySelImage;
@property (nonatomic,strong) NSURL *FavImageUrl,*url,*CollImgURL;
@property (nonatomic,strong) NSDictionary *json,*CollJson;
@property (nonatomic,strong) NSArray *jsonArr,*CollIdarr;
@property (nonatomic,strong) NSMutableArray *CollTitle;
@property (nonatomic,strong) NSURL *Service;

@property(strong,nonatomic)NSMutableArray *imagesAllBackArr, *thumAllBackArr, *LikeStatusAllArr, *favoriteAllArr;
@property(strong,nonatomic)NSMutableArray *videosAllBackArr, *videothumAllBackArr;
@property(strong,nonatomic)NSMutableArray *FavAllBackArr, *FavAllThumbBackArr, *FavAllIdArr,*FavAllBackLikedArr;
@property(strong,nonatomic) NSString *originalImagetempStr , *thumbletempStr ,*likestatusStr , *indexStr, *CheckLikePageString,*FavIndexPathStr;
@property(strong,nonatomic) NSString *maxImageCounter,*maxVideoCounter,*planstatusStr,*manuallyPhotosStatusStr,*superDriveName;
@property(strong,nonatomic) NSString *PlanStatusStr,*CurrentversionSTR,*PlanNameStr;

@property(strong,nonatomic)NSMutableArray *VidesAllBackArr,*VidesImageAllBackArr;
@property(strong,nonatomic) NSMutableArray *DriveArrNameCopy,*DriveIdArrCopy,*InviteEmailArrCopy,*DriveCoverImageArrCopy,*DriveStatusArrCopy;

@property(strong,nonatomic) NSMutableArray *CollectionNameArrCopy,*CollectionIdArrCopy,*CollectionCoverImageArrCopy;
@property(strong,nonatomic) NSMutableArray *CollectonAllImagesArr,*DriveAllImagesArr,*MemberListArr,*MemberList,*CreatorNameCopyArr,*ShareDriveIdArrCopy,*ChatCountArr,*DriveVideosImageCopyArr,*DriveVideosUrlCopyArr,*DriveLastMsgArr;
@property(strong,nonatomic) NSMutableArray *RegContactList,*RemainingContList,*demoList,*FilteredContacts;
@property(strong,nonatomic) NSString *SharedDriveOrNot,*DriveStatusStr,*DriveSelectedImageStatusStr,*SharedDriveIdStr,*ReadFileUrlStr,*ReadingFileNameStr,*DriveIntroInfo;
@property(strong,nonatomic)NSString *DateStr,*CurrentDateStr,*pointsCount;
@property(strong,nonatomic)NSString *AffStatus,*AppTotalPoints,*AppTodayPoint,*SettingProfilePic,*SettingDriveName;









@end

