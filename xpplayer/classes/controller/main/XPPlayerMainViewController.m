//
//  XPPlayerMainViewController.m
//  xpplayer
//
//  Created by iprincewang on 2018/11/13.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "XPPlayerMainViewController.h"
#import <FFmpeg/FFmpeg.h>

@interface XPPlayerMainViewController ()

@end

@implementation XPPlayerMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"主页";
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString* fileName = @"";
    [self openVideo:fileName];
}

#pragma mark -- ffmpeg
-(void)openVideo:(NSString *)fileName
{
    //声明变量名
    AVFormatContext* formatCtx;
    AVCodec* codec;
    AVCodecParserContext* parser;
    AVCodecParameters* codecParser;
    AVCodecContext* codecCtx = NULL;
    AVFrame* frame;
    int videostream;
    double fps;
    FILE* f;
    uint8_t* data;
    size_t data_size;
    
    //打开视频文件
    if (avformat_open_input(&formatCtx, fileName.UTF8String, NULL, NULL) != 0) {
        NSLog(@"打开文件[%@]失败...",fileName);
        return;
    }
    
    //检查数据流
    if (avformat_find_stream_info(formatCtx, NULL) < 0) {
        NSLog(@"检查数据流失败...");
        return;
    }
    
    //根据数据流，找到都一个视频流
    if ((videostream = av_find_best_stream(formatCtx, AVMEDIA_TYPE_VIDEO, -1, -1, &codec, 0)) < 0) {
        NSLog(@"没有找到第一个视频流...");
        return;
    }

    AVStream* stream = formatCtx->streams[videostream];
    codecParser = stream->codecpar;
    
#if DEBUG
    //打印视频流信息
    av_dump_format(formatCtx, videostream, fileName.UTF8String, 0);
#endif
    
    //查找视频帧率
    if (stream->avg_frame_rate.den && stream->avg_frame_rate.num) {
        fps = av_q2d(stream->avg_frame_rate);
    }
    else {
        fps = 30;
    }
    
    //查找解码器
    codec = avcodec_find_decoder(codecParser->codec_id);
    if (codec == NULL) {
        NSLog(@"没有找到解码器...");
        return;
    }
    
    //打开解码器
    codecCtx = avcodec_alloc_context3(codec);
    if (avcodec_open2(codecCtx, codec, NULL) < 0) {
        NSLog(@"打开解码器失败...");
        return;
    }
    
    frame = av_frame_alloc();
    
    int outputWidth, outputHeight;
    outputWidth = codecCtx->width;
    outputHeight = codecCtx->height;
    
    int outputWidth1, outputHeight1;
    outputWidth1 = codecParser->width;
    outputHeight1 = codecParser->height;
}

@end
