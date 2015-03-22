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

@interface ViewController : UIViewController<MPMediaPickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *themeSongLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UIImageView *artworkImage;
- (IBAction)startButton:(id)sender;
- (IBAction)propertiesButton:(id)sender;

@end

