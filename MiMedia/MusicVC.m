//
//  MusicVC.m
//  Flippy Cloud
//
//  Created by iSquare5 on 13/08/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import "MusicVC.h"
#import "SidebarViewController.h"
#import "IQMediaPickerController.h"
#import "IQFileManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "Base64.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import <AVFoundation/AVFoundation.h>
#import "AsyncImageView.h"
#import "STKAudioPlayer.h"

@interface MusicVC ()<IQMediaPickerControllerDelegate,MPMediaPickerControllerDelegate,UINavigationControllerDelegate,AVAudioRecorderDelegate, AVAudioPlayerDelegate>

{
    AppDelegate *app;
    MPMediaItem *item ;
    NSArray *newMediaItem,*audioArr,*audioArrCopy,*ThumbArrCopy;
    MPMediaItemCollection *collection;
    NSDictionary *mediaInfo;
    MPMusicPlayerController *musicPlayer;
    IQMediaPickerControllerMediaType mediaType;
    AVAudioPlayer *backgroundMusicPlayer;
    UIActivityIndicatorView *indicator;
    NSURL *urlToplay;
    AVAudioPlayer *player;
    AVAudioPlayer *mixplayer;

}
@property (nonatomic, retain) SidebarViewController* sidebarVC;
@property BOOL scrubbing;
@end
Boolean StartMusic;
Boolean StopMusic;
Boolean MusicOver;
int count;
STKAudioPlayer *AudioPlayer;
NSTimer *SongTimer;

@implementation MusicVC
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initPB];
    [indicator startAnimating];
    AudioPlayer =[[STKAudioPlayer alloc]init];
    count = 0;
    StartMusic =NO;
    StopMusic =NO;
    MusicOver =NO;
    [self viewWillDisappear:YES];
    player = [[AVAudioPlayer alloc]init];
    [self.MediaControlBtn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"PlaySong.png"]] forState:UIControlStateNormal];//play
    [self SetSongTimer];
    app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    self.sidebarVC = [[SidebarViewController alloc] init];
    [self.sidebarVC setBgRGB:0x000000];
    self.sidebarVC.view.frame  = self.view.bounds;
    [self.view addSubview:self.sidebarVC.view];
    [self.sidebarVC showHideSidebar];
    [self.myProgress setThumbImage:[UIImage imageNamed:@"20.png"] forState:UIControlStateNormal];
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(MusicVC) userInfo:nil repeats:NO];
}

-(void)MusicVC
{
    if([[Reachability sharedReachability] internetConnectionStatus] == NotReachable){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Check Internet Connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
    else
    {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *contact=[prefs valueForKey:@"contact"];
//      NSString *urlString = [[NSString  alloc]initWithFormat:@"%@contact_audio.php",app.Service ];http://46.166.173.116/FlippyCloud/webservices/ios/test/
              NSString *urlString = [[NSString alloc]initWithFormat:@"http://46.166.173.116/FlippyCloud/webservices/ios/test/contact_audio.php"];
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSString *myRequestString =[NSString stringWithFormat:@"{\"contact\":\"%@\"}",contact];
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
            
            NSLog(@"contact_audio.php   ::::  %@",dictionary);
            
            
            if (!dictionary)
            {
                NSLog(@"%s: JSONObjectWithData error: %@; data = %@", __FUNCTION__, parseError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                return ;
            }
            else
            {
                if([[dictionary valueForKey:@"success"] isEqualToString:@"1"])
                {
                    audioArrCopy=[[[[dictionary valueForKey:@"posts"]valueForKey:@"audio"]valueForKey:@"audio"]objectAtIndex:0];
                                  ThumbArrCopy=[[[[dictionary valueForKey:@"posts"]valueForKey:@"thumb"]valueForKey:@"thumb"]objectAtIndex:0];
                    
                    self.collectionView.hidden=NO;
                    self.introView.hidden=YES;
                    [self.collectionView reloadData];
                }
                [indicator stopAnimating];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
            }
        }];
    }
}

- (IBAction)showMediaPicker:(id)sender
{
    IQMediaPickerController *controller = [[IQMediaPickerController alloc] init];
    controller.delegate = self;
    [controller setMediaType:IQMediaPickerControllerMediaTypeAudio];
    controller.allowsPickingMultipleItems =YES;
    [self presentViewController:controller animated:YES completion:nil];
}
- (void)mediaPickerController:(IQMediaPickerController*)controller didFinishMediaWithInfo:(NSDictionary *)info;
{
    mediaInfo = [info copy];
    self.introView.hidden=YES;
    self.collectionView.hidden=NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [indicator startAnimating];
        self.status.hidden=YES;
        [self SendMusic];
    });
}
-(void)SendMusic
{
    NSString *key = @"IQMediaTypeAudio";
    NSURL *url = [[[mediaInfo objectForKey:key] objectAtIndex:0] objectForKey:IQMediaURL];
    if(url != NULL)
    {
        NSError* err = nil;
        NSData *data123 = [NSData dataWithContentsOfURL:url options: NSDataReadingUncached error: &err];
        NSString  *base64String = [data123 base64EncodedStringWithOptions:0];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *contact=[prefs valueForKey:@"contact"];
        NSString *urlString = [[NSString alloc]initWithFormat:@"%@add_music.php",app.Service ];
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSString *myRequestString =[NSString stringWithFormat:@"{\"contact\":\"%@\",\"audio_name\":\"%@\"}",contact,base64String];
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
            NSLog(@"add_music.php   ::::  %@",dictionary);
            
            if (!dictionary)
            {
                NSLog(@"%s: JSONObjectWithData error: %@; data = %@", __FUNCTION__, parseError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                return ;
            }
            else
            {
                if([[dictionary valueForKey:@"success"] isEqualToString:@"1"])
                {
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Completed!" message:@"Audio Uploaded." preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                    [alertController addAction:ok];
                    [self presentViewController:alertController animated:YES completion:nil];
                    self.status.hidden=YES;
                    audioArrCopy=[[dictionary valueForKey:@"posts"]valueForKey:@"audio"];
                    [prefs setObject:audioArr forKey:@"audio"];
                    self.collectionView.hidden=NO;
                    self.introView.hidden=YES;
                    self.status.hidden=YES;
                    [indicator stopAnimating];
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
                    [self.collectionView reloadData];
                }
                else
                {
                    self.status.hidden=YES;
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error!" message:@"Something Wrong in Database." preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                    [alertController addAction:ok];
                    [self presentViewController:alertController animated:YES completion:nil];
                    [indicator stopAnimating];
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
                }
            }
        }];
    }
    [self.collectionView reloadData];
}
- (void)mediaPickerControllerDidCancel:(IQMediaPickerController *)controller;
{
}

// ------  collection view start   -------
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return audioArrCopy.count;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5,5,5,5);
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier=@"Cell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    UILabel *music=(UILabel *)[cell viewWithTag:100];
    NSString *audioName=[[audioArrCopy objectAtIndex:indexPath.row] lastPathComponent];
    music.text=[NSString stringWithFormat:@"%@",audioName];
    
    NSString *string = [NSString stringWithFormat:@"%@",[ThumbArrCopy objectAtIndex:indexPath.row]];
    NSString* urlTextEscaped = [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    UIImageView *ArtistPic =(UIImageView *)[cell viewWithTag:101];
    ArtistPic.imageURL=[NSURL URLWithString:urlTextEscaped];
    return cell;
}
-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *audioName=[[audioArrCopy objectAtIndex:indexPath.row] lastPathComponent];
    self.PlayerTitleSongName.text = [NSString stringWithFormat:@"%@",audioName];
    [self.MediaControlBtn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"pauseSong.png"]] forState:UIControlStateNormal];
    NSString *string = [NSString stringWithFormat:@"%@",[ThumbArrCopy objectAtIndex:indexPath.row]];
    [self.myProgressView setProgress:0 animated:YES];
    NSString* urlTextEscaped = [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    self.ArtistPicView.imageURL=[NSURL URLWithString:urlTextEscaped];
    count = (int)indexPath.row -1 ;
    [self PlayThisSong:indexPath.row];
    
}
-(IBAction)StopBut:(id)sender
{
    MusicOver =NO;
    StopMusic =YES;
    [AudioPlayer stop];
}
-(IBAction)StartBut:(id)sender
{
    if(!AudioPlayer)
    {
        return;
    }
    if(AudioPlayer.state ==STKAudioPlayerStatePaused)
    {
        [AudioPlayer resume];
        NSLog(@"play");
        [self.MediaControlBtn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"pauseSong.png"]] forState:UIControlStateNormal];//pause
    }
    else
    {
        [AudioPlayer pause];
        [self.MediaControlBtn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"PlaySong.png"]] forState:UIControlStateNormal];//play
    }
}
-(void)PlayThisSong:(int)Songspot
{
    NSString *string = [NSString stringWithFormat:@"%@",[audioArrCopy objectAtIndex:Songspot]];
    NSString* urlTextEscaped = [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    urlToplay = [NSURL URLWithString: urlTextEscaped];
    NSLog(@"%@",urlToplay);
    [AudioPlayer playURL:urlToplay];
    Songspot++;
    StopMusic =NO;
}
-(void)SetSongTimer
{
   SongTimer =[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(tick) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:SongTimer forMode:NSRunLoopCommonModes];
}
-(void)tick
{
    if(!AudioPlayer)
    {
        self.TotalTime.text=@"";
        self.DurationTime.text=@"";
        return;
    }
    NSLog(@"%f",AudioPlayer.duration);
    if(AudioPlayer.duration !=0)
    {
        MusicOver = YES;
        self.TotalTime.text=[NSString stringWithFormat:@"%@",[self formatetimefromsecond:
                                                              AudioPlayer.duration]];
        self.DurationTime.text =[NSString stringWithFormat:@"%@",[self  formatetimefromsecond:AudioPlayer.progress]];
        self.myProgress.maximumValue=AudioPlayer.duration;
        self.myProgress.minimumValue=0;
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self
                                                    selector:@selector(updateTime:)
                                                    userInfo:nil
                                                     repeats:YES];
    }
    else
    {
        if (MusicOver ==YES && StopMusic ==NO)
        {
            MusicOver = NO;
            count++;
            if(count==[audioArrCopy  count])
            {
                [self PlayThisSong:count];
            }
            self.TotalTime.text=@"";
        }
        NSLog(@"%@",AudioPlayer.state==STKAudioPlayerStateRunning ? @"buffering":@"runing");
        self.DurationTime.text=AudioPlayer.state==STKAudioPlayerStateRunning ? @"Buffering":@"";
    }
}
-(void)moreProgress
{
    self.myProgressView.progress += 1.0/1800.0;
}
-(NSString *)formatetimefromsecond:(int)totalSecond
{
    int second= totalSecond % 60;
    int minute =(totalSecond  /60) %60;
    int hour =totalSecond /3600;
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hour,minute,second];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (IBAction)show:(id)sender
{
    [self.sidebarVC showHideSidebar];
}
- (void)panDetected:(UIPanGestureRecognizer*)recoginzer
{
    [self.sidebarVC panDetected:recoginzer];
}
- (void)updateTime:(NSTimer *)timer
{
    if (!self.scrubbing)
    {
        self.myProgress.value = AudioPlayer.progress;
    }
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
-(void)viewWillDisappear:(BOOL)animated
{
    StopMusic =YES;
    [AudioPlayer stop];
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
