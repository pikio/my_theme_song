//
//  ViewController.m
//  my_theme_song
//
//  Created by 加藤 豊 on 2015/03/21.
//  Copyright (c) 2015年 Yutaka Kato. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property MPMusicPlayerController* player;
@property CMPedometer* pedometer;
@property NSTimer* timer;
@property CMMotionActivityManager* activityManager;
@property int countUp;

@end

@implementation ViewController

const int PAUSE_COUNT_VALUE = 2;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.themeSongLabel.textAlignment = NSTextAlignmentCenter;
    self.artistLabel.textAlignment = NSTextAlignmentCenter;
    self.activityLabel.textAlignment = NSTextAlignmentCenter;
    
    self.activityDateLabel.textAlignment = NSTextAlignmentCenter;
    self.activityDate2Label.textAlignment = NSTextAlignmentCenter;
    
    self.player = [MPMusicPlayerController applicationMusicPlayer];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
    //設定を読み込む
    NSString *persistentId = [ud stringForKey:@"PersistentId"];
    if(persistentId != nil){
        MPMediaQuery *query = [MPMediaQuery albumsQuery];
        [query addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:persistentId forProperty: MPMediaItemPropertyPersistentID]];
        NSArray *albumlists = query.collections;
        for(MPMediaItemCollection *albumlist in albumlists){
            [self.player setQueueWithItemCollection:albumlist];
            
            MPMediaItem *item = [albumlist representativeItem];
            self.themeSongLabel.text = [item valueForProperty: MPMediaItemPropertyTitle];
            self.artistLabel.text = [item valueForProperty: MPMediaItemPropertyArtist];
            MPMediaItemArtwork *artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
            UIImage *image = [artwork imageWithSize:artwork.bounds.size];
            self.artworkImage.image = image;
            
            AVAudioSession *session = [AVAudioSession sharedInstance];
            //ロック時も再生のカテゴリを指定
            [session setCategory:AVAudioSessionCategoryPlayback error:nil];
            //オーディオセッションを有効化
            [session setActive:YES error:nil];
        }
    }
    
    self.pedometer = [[CMPedometer alloc]init];
    BOOL check = [self confirmCMPedometer];
    if(check){
        [self startPedometer];
    }
    
    if([CMMotionActivityManager isActivityAvailable]){
        self.activityManager = [[CMMotionActivityManager alloc] init];
        
        [self.activityManager startActivityUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMMotionActivity *activity){
            if(activity.stationary){
                self.activityLabel.text = @"停止中";
                [self.player pause];
            }
            else{
                if(activity.confidence == CMMotionActivityConfidenceMedium
                || activity.confidence == CMMotionActivityConfidenceHigh){
                }
                
                if(activity.walking){
                    self.activityLabel.text = @"歩いてる";
                    if(! self.checkMusicPlay){
                        [self.player play];
                    }
                    self.countUp = 0;
                }
                else if(activity.running){
                    self.activityLabel.text = @"走ってる";
                    if(! self.checkMusicPlay){
                        [self.player play];
                    }
                    self.countUp = 0;
                }
                else if(activity.automotive){
                    self.activityLabel.text = @"自動車";
                    if(! self.checkMusicPlay){
                        [self.player play];
                    }
                    self.countUp = 0;
                }
                else if(activity.unknown){
                    self.activityLabel.text = @"不明";
                }
            }
            
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *startDateString = [dateFormatter stringFromDate:activity.startDate];
            self.activityDateLabel.text = startDateString;
        }];
        
    }
    
    self.countUp = 0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerMusicStop:) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startButton:(id)sender {
}

- (IBAction)propertiesButton:(id)sender {
    MPMediaPickerController *picker = [[MPMediaPickerController alloc] init];
    picker.delegate = self;
    picker.allowsPickingMultipleItems = NO;
    [self presentViewController:picker animated:YES completion:nil];
}

-(void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    [self.player setQueueWithItemCollection:mediaItemCollection];
    //[self.player play];
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
    
    MPMediaItem *item = [mediaItemCollection representativeItem];
    self.themeSongLabel.text = [item valueForProperty: MPMediaItemPropertyTitle];
    self.artistLabel.text = [item valueForProperty: MPMediaItemPropertyArtist];
    MPMediaItemArtwork *artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
    UIImage *image = [artwork imageWithSize:artwork.bounds.size];
    self.artworkImage.image = image;
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    //ロック時も再生のカテゴリを指定
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    //オーディオセッションを有効化
    [session setActive:YES error:nil];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
    [ud setObject:[item valueForProperty:MPMediaItemPropertyPersistentID] forKey:@"PersistentId"];
    
}

-(void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker{
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)confirmCMPedometer {
    if([CMPedometer isStepCountingAvailable]
       && [CMPedometer isDistanceAvailable]
       && [CMPedometer isFloorCountingAvailable])
    {
        return YES;
    } else {
        return NO;
    }
}

/**
 歩行動作を計測する処理
 */
- (void)startPedometer {
    
    [self.pedometer startPedometerUpdatesFromDate:[NSDate date]
                                withHandler:^(CMPedometerData *pedometerData, NSError *error) {
                                    dispatch_async(dispatch_get_main_queue(), ^{

                                        self.countUp = 0;
                                        
                                        
                                        // 日時取得のためにFormatを設定
                                        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
                                        [outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                                        // 開始日時
                                        NSString* startDate = [outputFormatter stringFromDate:pedometerData.startDate];
                                        //終了日時
                                        NSString *endDate = [outputFormatter stringFromDate:pedometerData.endDate];
                                        
                                        self.activityDate2Label.text = endDate;

                                    });
                                    
                                }];
}

-(void) timerMusicStop:(NSTimer*)timer{
    if(self.checkMusicPlay){
        self.countUp++;
        
        if(self.countUp > PAUSE_COUNT_VALUE){
            //[self.player pause];
        }
    }
}

-(BOOL) checkMusicPlay{
    MPMusicPlaybackState isPlay = [self.player playbackState];
    if(isPlay == MPMusicPlaybackStatePlaying){
        return YES;
    }
    else{
        return NO;
    }
}


@end
