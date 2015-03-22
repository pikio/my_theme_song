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
@property int countUp;

@end

@implementation ViewController

const int PAUSE_COUNT_VALUE = 5;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.themeSongLabel.textAlignment = NSTextAlignmentCenter;
    self.artistLabel.textAlignment = NSTextAlignmentCenter;
    
    self.player = [MPMusicPlayerController applicationMusicPlayer];
    
    self.pedometer = [[CMPedometer alloc]init];
    BOOL check = [self confirmCMPedometer];
    if(check){
        [self startPedometer];
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
                                        if(! self.checkMusicPlay){
                                            [self.player play];
                                        }
                                        self.countUp = 0;
                                    });
                                    
                                }];
}

-(void) timerMusicStop:(NSTimer*)timer{
    if(self.checkMusicPlay){
        self.countUp++;
        
        if(self.countUp > PAUSE_COUNT_VALUE){
            [self.player pause];
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
