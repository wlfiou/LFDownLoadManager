//
//  LFPlayVC.m
//  LFDownloadDemo
//
//  Created by 王鹭飞 on 2018/12/24.
//  Copyright © 2018 王鹭飞. All rights reserved.
//

#import "LFPlayVC.h"
#import "SRVideoPlayer/SRVideoPlayer.h"
#import "LFDownLoadManager/LFDownLoadModel.h"
#import "LFDownLoadManager/LFUtil.h"
@interface LFPlayVC ()<SRVideoPlayerDelegate>
@property(nonatomic,strong)SRVideoPlayer *videoPlayer;

@end

@implementation LFPlayVC
-(void)playVideo:(NSString *)fileFullPath{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 400)];
    [self.view addSubview:backView];
    _videoPlayer = [SRVideoPlayer playerWithVideoURL:[[NSURL alloc] initFileURLWithPath:fileFullPath]
                                          playerView:backView
                                     playerSuperView:backView.superview];
    _videoPlayer.videoName = @"Here Is The Video Name";
    _videoPlayer.playerEndAction = SRVideoPlayerEndActionLoop;
    _videoPlayer.delegate = self;
    [_videoPlayer play];
}
-(void)videoPlayerDestroyed{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)setModel:(LFDownLoadModel *)model{
    _model = model;
    [self playVideo:[[LFUtil downloadPathDirectory] stringByAppendingPathComponent:_model.localPath]];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
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
