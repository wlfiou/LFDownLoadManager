//
//  LFDownloadBtn.m
//  LFDownloadDemo
//
//  Created by 王鹭飞 on 2018/12/11.
//  Copyright © 2018 王鹭飞. All rights reserved.
//

#import "LFDownloadBtn.h"
#import "LFUtil.h"
@interface LFDownloadBtn(){
    id _target;
    SEL _action;
}
@property (nonatomic, weak) UILabel *proLabel;    // 进度标签
@property (nonatomic, weak) UIImageView *imgView; // 状态视图
@end

@implementation LFDownloadBtn
-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        // 百分比标签
        UILabel *proLabel = [[UILabel alloc] initWithFrame:self.bounds];
        proLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        proLabel.textColor = [UIColor colorWithRed:0/255.0 green:191/255.0 blue:255/255.0 alpha:1];
        proLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:proLabel];
        _proLabel = proLabel;
        
        // 状态视图
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:self.bounds];
        imgView.backgroundColor = [UIColor whiteColor];
        imgView.image = [UIImage imageNamed:@"com_download_default"];
        [self addSubview:imgView];
        _imgView = imgView;
    }
    return self;
}
-(void)setProgress:(CGFloat)progress
{
    _progress = progress;
    _proLabel.text = [NSString stringWithFormat:@"%d%%",(int)floor(progress*100)];
    [self setNeedsDisplay];
}
-(void)setModel:(LFDownLoadModel *)model{
    _model = model;
    self.state = model.state;
}
- (void)setState:(LFDownloadState)state
{
    _imgView.hidden = state == LFDownloadStateDownloading;
    _proLabel.hidden = !_imgView.hidden;
    
    switch (state) {
        case LFDownloadStateDefault:
            _imgView.image =[UIImage imageNamed:@"com_download_default"]  ;
            break;
            
        case LFDownloadStateDownloading:
            
            break;
            
        case LFDownloadStateWaiting:
            _imgView.image =[UIImage imageNamed:@"com_download_waiting"];
            break;
            
        case LFDownloadStatePaused:
            _imgView.image =[UIImage imageNamed:@"com_download_pause"];
            break;
            
        case LFDownloadStateFinish:
            _imgView.image =[UIImage imageNamed:@"com_download_finish"];
            break;
            
        case LFDownloadStateError:
            _imgView.image =[UIImage imageNamed:@"com_download_error"];
            break;
            
        default:
            break;
    }
    
    _state = state;
}
-(void)drawRect:(CGRect)rect{
    CGFloat lineWidth = 3.f;
    UIBezierPath *path = [[UIBezierPath alloc]init];
    path.lineWidth = lineWidth;
    [_proLabel.textColor set];
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineJoinRound;
    CGFloat radius = (MIN(rect.size.width, rect.size.height)-lineWidth)/2;
    [path addArcWithCenter:(CGPoint){rect.size.width * 0.5, rect.size.height * 0.5} radius:radius startAngle:M_PI*1.5 endAngle:M_PI*1.5+M_PI*2*_progress clockwise:YES];
    [path stroke];
}
-(void)addTarget:(id)target anction:(SEL)action
{
    _target = target;
    _action = action;
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    IMP imp = [_target methodForSelector:_action];
    void(*fun)(id,SEL,id) = (void *)imp;
    fun(_target,_action,self);
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
