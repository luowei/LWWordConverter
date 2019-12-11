//
// Created by Luo Wei on 2017/4/25.
// Copyright (c) 2017 luowei. All rights reserved.
//

#import <Foundation/Foundation.h>

//加密结果的套路
typedef NS_OPTIONS(NSUInteger, EncryptMode) {
    EncryptModeEmoji = 0,      //表情包套路
    EncryptModeSanGuoSha = 1   //三国杀套路
};


@interface LWEncryptService : NSObject

//判断某段文本是否包含加密字符
+ (BOOL)isEncryptString:(NSString *)str;

//把原始文本插入转译到新的文本 "你好"->"（你好）再见" 括号内文本不可见
+ (NSString *)encryptText:(NSString *)primevalText displayText:(NSString *)displayText;

//把加密文本过滤提取，并转译到原始文本 "（你好）再见"->"你好"
+ (NSString *)decryptText:(NSString *)imitativeText;

//选择一种加密的套路
+ (void)saveEncryptMode:(EncryptMode)encryptMode;

//获取当前选择的加密套路
+ (EncryptMode)getEncryptMode;


+ (NSArray *)getShortcut;
@end