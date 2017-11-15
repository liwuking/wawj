//
//  LameTool.m
//  wawj
//
//  Created by ruiyou on 2017/11/14.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "LameTool.h"
#import "lame.h"

@implementation LameTool

+ (NSString *)audioToMP3: (NSString *)sourcePath isDeleteSourchFile: (BOOL)isDelete andSourcePath:(LameToolWithSourcePath)sourthPath{
//    NSString *inPath = sourcePath;
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:sourcePath]){
        NSLog(@"file path error!");
        return @"";
    }
    NSString *outPath = [[sourcePath stringByDeletingPathExtension] stringByAppendingString:@".mp3"];
//    @try {
//        int read, write;
//
//        FILE *pcm = fopen([sourcePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
//        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
//        FILE *mp3 = fopen([outPath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
//
//        const int PCM_SIZE = 8192;
//        const int MP3_SIZE = 8192;
//        short int pcm_buffer[PCM_SIZE*2];
//        unsigned char mp3_buffer[MP3_SIZE];
//
//        lame_t lame = lame_init();
//        lame_set_in_samplerate(lame, 11025.0);
//        lame_set_VBR(lame, vbr_default);
//        lame_init_params(lame);
//
//        do {
//            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
//
//            if (read == 0)
//                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
//            else
//                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
//
//            fwrite(mp3_buffer, write, 1, mp3);
//
//        } while (read != 0);
//
//        lame_close(lame);
//        fclose(mp3);
//        fclose(pcm);
//    }
    @try {
        int read, write;
        
        FILE *pcm = fopen([sourcePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([outPath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_num_channels(lame,1);//设置1为单通道，默认为2双通道
        lame_set_in_samplerate(lame, 44100.0);
        lame_set_VBR(lame, vbr_default);
        
        lame_set_brate(lame,8);
        
        lame_set_mode(lame,3);
        
        lame_set_quality(lame,2);
        
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }

    @catch (NSException *exception) {
         sourthPath(nil);
        NSLog(@"%@",[exception description]);
    }
    @finally {
        
        if (isDelete) {
            NSError *error;
            [fm removeItemAtPath:sourcePath error:&error];
            if (error == nil){
                NSLog(@"source file is deleted!");
            }
        }
        
        
        sourthPath(outPath);
        
        
//        self.audioFileSavePath = mp3FilePath;
//        NSLog(@"MP3生成成功: %@",self.audioFileSavePath);
    }
}

@end
