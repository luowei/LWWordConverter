//
// Created by luowei on 2017/3/28.
// Copyright (c) 2017 luowei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>


@interface LWConverterService : NSObject

@property (nonatomic) NSInteger networkReachabilityStatus;

@property (nonatomic, strong) NSObject *toLanguage;

@property(nonatomic, strong) NSString *dbPath;
@property(nonatomic, strong) NSString *bihuaDBPath;

+(LWConverterService *)serviceWithDBPath:(NSString *)dbPath bihuaDBPath:(NSString *)bihuaDBPath;

//根据参数zi查找五笔与拼音;
-(void)queryWithZi:(NSString *)zi updateUIBlock:(void (^)(NSString *pinyin,NSString *wubi))updateUIBlock;

//根据参数zi查找笔顺
- (void)queryBiShunWithZi:(NSString *)zi updateUIBlock:(void (^)(NSString *))updateUIBlock;

//百度翻译文字
- (void)fanyiZi:(NSString *)zi to:(NSString *)to updateUIBlock:(void (^)(NSString *text,BOOL isErrorMsg))updateUIBlock;

@end
