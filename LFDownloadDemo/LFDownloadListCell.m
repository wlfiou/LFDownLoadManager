//
//  LFDownloadListCell.m
//  LFDownloadDemo
//
//  Created by 王鹭飞 on 2018/12/11.
//  Copyright © 2018 王鹭飞. All rights reserved.
//

#import "LFDownloadListCell.h"
#import "LFDownloadBtn.h"
#import "category/UIColor+LF.h"
#import "LFUtil.h"

@interface LFDownloadListCell ()
@property (nonatomic, weak) UILabel *titleLabel;            // 标题
@property (nonatomic, weak) UILabel *speedLabel;            // 进度标签
@property (nonatomic, weak) UILabel *fileSizeLabel;         // 文件大小标签
@property (nonatomic, weak) LFDownloadBtn *downloadBtn;  // 下载按钮

@end

@implementation LFDownloadListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // 底图
        CGFloat margin = 8.f;
        CGFloat backViewH = 70;
        // 下载按钮
        CGFloat btnW = 50.f;
        LFDownloadBtn *downloadBtn = [[LFDownloadBtn alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - btnW - 2*margin, (backViewH - btnW) * 0.5, btnW, btnW)];
        [downloadBtn addTarget:self anction:@selector(downBtnOnClick:)];
        [self.contentView addSubview:downloadBtn];
        _downloadBtn = downloadBtn;
        
        // 标题
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(margin, 0, [UIScreen mainScreen].bounds.size.width - margin * 4 - btnW, backViewH * 0.6)];
        titleLabel.font = [UIFont boldSystemFontOfSize:18.f];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.layer.masksToBounds = YES;
        [self.contentView addSubview:titleLabel];
        _titleLabel = titleLabel;
        
        // 进度标签
        UILabel *speedLable = [[UILabel alloc] initWithFrame:CGRectMake(margin, CGRectGetMaxY(titleLabel.frame), titleLabel.frame.size.width * 0.4, backViewH * 0.4)];
        speedLable.font = [UIFont systemFontOfSize:14.f];
        speedLable.textColor = [UIColor blackColor];
        speedLable.textAlignment = NSTextAlignmentRight;
        speedLable.backgroundColor = [UIColor clearColor];
        speedLable.layer.masksToBounds = YES;
        [self.contentView addSubview:speedLable];
        _speedLabel = speedLable;
        
        // 文件大小标签
        UILabel *fileSizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(speedLable.frame), CGRectGetMaxY(titleLabel.frame), titleLabel.frame.size.width - speedLable.frame.size.width, backViewH * 0.4)];
        fileSizeLabel.font = [UIFont systemFontOfSize:14.f];
        fileSizeLabel.textColor = [UIColor blackColor];
        fileSizeLabel.textAlignment = NSTextAlignmentRight;
        fileSizeLabel.backgroundColor = [UIColor clearColor];
        fileSizeLabel.layer.masksToBounds = YES;
        [self.contentView addSubview:fileSizeLabel];
        _fileSizeLabel = fileSizeLabel;
    }
    
    return self;
}
-(void)setFrame:(CGRect)frame{
    frame.origin.x += 8;
    frame.origin.y += 8;
    frame.size.height -= 8;
    frame.size.width -= 16;
    [super setFrame:frame];
}
-(void)setModel:(LFDownLoadModel *)model{
    _model = model;
    _titleLabel.text = model.fileName;
    [self updateViewWithModel:model];
}
- (void)updateViewWithModel:(LFDownLoadModel *)model
{
    _downloadBtn.progress = model.progress;
    _downloadBtn.model = model;
    [self reloadLabelWithModel:model];
}

// 刷新标签
- (void)reloadLabelWithModel:(LFDownLoadModel *)model
{
    NSString *totalSize = [LFUtil stringFromByteCount:model.totalFileSize];
    NSString *tmpSize = [LFUtil stringFromByteCount:model.tmpFileSize];
    
    if (model.state == LFDownloadStateFinish) {
        _fileSizeLabel.text = [NSString stringWithFormat:@"%@", totalSize];
        
    }else {
        _fileSizeLabel.text = [NSString stringWithFormat:@"%@ / %@", tmpSize, totalSize];
    }
    _fileSizeLabel.hidden = model.totalFileSize == 0;
    
    if (model.speed > 0) {
        _speedLabel.text = [NSString stringWithFormat:@"%@ / s", [LFUtil stringFromByteCount:model.speed]];
    }
    _speedLabel.hidden = !(model.state == LFDownloadStateDownloading && model.totalFileSize > 0);
}
-(void)downBtnOnClick:(LFDownloadBtn *)btn{
    if (self.model.state == LFDownloadStateDefault ||self.model.state == LFDownloadStatePaused || self.model.state == LFDownloadStateError) {
        [[LFDownLoadManager manager] startDownLoadTask:_model];
    }else if (self.model.state == LFDownloadStateDownloading || self.model.state == LFDownloadStateWaiting){
        [[LFDownLoadManager manager] pauseDownLoadTast:_model];
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
