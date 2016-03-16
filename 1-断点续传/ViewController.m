//
//  ViewController.m
//  1-断点续传
//
//  Created by lgh on 16/1/28.
//  Copyright (c) 2016年 lgh. All rights reserved.
//

#import "ViewController.h"

#define QQ_URL @"http://dlsw.baidu.com/sw-search-sp/soft/2a/25677/QQ_V4.0.5.1446465388.dmg"

#define SAVE_PATH [NSHomeDirectory() stringByAppendingString:@"/Library/QQ.dmg"]    // 保存文件的路径

@interface ViewController () <NSURLConnectionDataDelegate>  //!< 遵守URLConnection的协议;

// 下载百分比label:
@property (weak, nonatomic) IBOutlet UILabel *label;

// 下载进度条:
@property (weak, nonatomic) IBOutlet UIProgressView *processView;

@property (nonatomic, strong) NSFileHandle *fileHandle;  //!< 文件对象;

@property (nonatomic, strong) NSURLConnection *connnection;  //!< 链接对象;

@property (nonatomic, assign) long long lastLength;  //!< 已经下载的长度;

@property (nonatomic, strong) NSMutableData *data;  //!< 保存请求数据;

@property (nonatomic, assign) long long totalLength; //!< 这次需要下载的总长度;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSLog(@"%@", SAVE_PATH);
}

// 开始下载:
- (IBAction)clickStart:(id)sender {

    // 创建请求对象:
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:QQ_URL]];
    
    // 判断文件是否存在:
    if ([[NSFileManager defaultManager] fileExistsAtPath:SAVE_PATH] == NO) {
        // 文件不存在:
        // 创建空文件:
        [[NSFileManager defaultManager] createFileAtPath:SAVE_PATH contents:nil attributes:nil];
    }
    // 打开文件:
    self.fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:SAVE_PATH];
    [self.fileHandle seekToEndOfFile];  //!< 光标定位到文件末尾;
    self.lastLength = self.fileHandle.offsetInFile; // 光标在文件的偏移量， （即上一次已经下载的长度）;
    
    // 请求头， 告诉服务器从文件的哪个点开始下载:
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-", self.lastLength] forHTTPHeaderField:@"RANGE"];
    
    //发送请求:
    // 存储链接对象到self.connection:
    self.connnection = [NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark - NSURLConnectionDelegate 协议方法
// 开始接收数据:
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.data.length = 0;
    
    //记录这次需要下载的长度:
    self.totalLength = response.expectedContentLength;
    NSLog(@"%lld", self.totalLength);  // 这次需要下载的长度;
//    response.suggestedFilename
    // 修改进度条:
    self.processView.progress = (self.data.length + self.lastLength) * 1.0 / (self.totalLength + self.lastLength);
    // 修改label:
    self.label.text = [NSString stringWithFormat:@"%d%%", (int)(self.processView.progress * 100)];
}
// 接收数据:
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.data appendData:data];
    // 修改进度条:
    self.processView.progress = (self.data.length + self.lastLength) * 1.0 / (self.totalLength + self.lastLength);
    // 修改label:
    self.label.text = [NSString stringWithFormat:@"%d%%", (int)(self.processView.progress * 100)];
}

// 接收完毕:
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self.fileHandle writeData:self.data];
    [self.fileHandle closeFile];
    [self showMessage:@"下载完成"];
}
// 暂停下载:
- (IBAction)clickPause:(id)sender {
    // 取消链接:
    [self.connnection cancel];
    // 把self.data写到文件里面:
    [self.fileHandle writeData:self.data];
    [self.fileHandle closeFile];
}

// 删除文件:
- (IBAction)clickDelete:(id)sender {

    //NSFileManager : 文件管理单例: 创建文件，文件夹，判断文件/文件夹是否存在，拷贝，移动，删除文件/文件夹.....
    // 删除文件:
    if ([[NSFileManager defaultManager] fileExistsAtPath:SAVE_PATH] == YES) {
        BOOL ret =[[NSFileManager defaultManager] removeItemAtPath:SAVE_PATH error:nil];
        if (ret == YES) {
            [self showMessage:@"删除文件成功"];
        }
    }else{
        [self showMessage:@"没有该文件"];
    }
}

// 弹出提示框的方法:
- (void)showMessage:(NSString *)message
{
    UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [a show];
}

#pragma mark - Getter
- (NSMutableData *)data
{
    if (_data == nil) {
        _data = [[NSMutableData alloc] init];
    }
    return _data;
}

@end


















