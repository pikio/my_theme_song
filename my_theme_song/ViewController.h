//
//  ViewController.h
//  my_theme_song
//
//  Created by 加藤 豊 on 2015/03/21.
//  Copyright (c) 2015年 Yutaka Kato. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CoreMotion/CoreMotion.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController<MPMediaPickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *themeSongLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UIImageView *artworkImage;
@property (weak, nonatomic) IBOutlet UILabel *activityLabel;
@property (weak, nonatomic) IBOutlet UILabel *activityDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *activityDate2Label;
- (IBAction)startButton:(id)sender;
- (IBAction)propertiesButton2:(id)sender;

@end

