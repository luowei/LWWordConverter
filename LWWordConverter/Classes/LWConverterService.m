//
// Created by luowei on 2017/3/28.
// Copyright (c) 2017 luowei. All rights reserved.
//

#import "LWConverterService.h"
#import "sqlite3.h"
#import "AFNetworking.h"
//#import "LWLogger.h"

#define Fanyi_URLString @"https://fanyi-api.baidu.com/api/trans/vip/translate"
#define BaiduFanyi_Appid @"20170309000041858"
#define BaiduFanyi_SecretKey @"yeLdUw6n25kZYL_wcPhs"

@implementation LWConverterService {
    sqlite3 *dbSqlite;
    sqlite3 *dbBihuaSqlite;
}

+(LWConverterService *)serviceWithDBPath:(NSString *)dbPath bihuaDBPath:(NSString *)bihuaDBPath {
    BOOL exsit = [[NSFileManager defaultManager] fileExistsAtPath:dbPath];
    exsit = [[NSFileManager defaultManager] fileExistsAtPath:bihuaDBPath];
    if(!exsit){
        return nil;
    }
    LWConverterService *service = [[LWConverterService alloc] initWithDBPath:dbPath bihuaDBPath:bihuaDBPath];
    return service;
}

- (instancetype)initWithDBPath:(NSString *)dbPath bihuaDBPath:(NSString *)bihuaDBPath {
    self = [super init];
    if (self) {
        self.dbPath = dbPath;
        self.bihuaDBPath = bihuaDBPath;
        //打开数据库
        [self openDatabase];
        [self openBihuaDatabase];

        //监听网络状态
        __weak typeof(self) weakSelf = self;
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            weakSelf.networkReachabilityStatus = status;
        }];
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];

        self.toLanguage = @"en"; //默认翻译为英文
    }

    return self;
}

- (BOOL)openDatabase {

//    NSString *dbPath = [LWHelper copy2DocumentsWithFileName:@"zidian.dat"];
    int result = sqlite3_open([self.dbPath UTF8String], &dbSqlite);
    if (SQLITE_OK != result) {
        NSLog(@"打开 Zidian DB失败 = %d", result);
        sqlite3_close(dbSqlite);
        return NO;
    }

    //验证密码
    const char* key = [@"luowei.wodedata.com" UTF8String];
    sqlite3_key(dbSqlite, key, (int)strlen(key));
    int res = sqlite3_exec(dbSqlite, (const char*) "SELECT count(*) FROM sqlite_master;", NULL, NULL, NULL);
    if (res == SQLITE_OK) {
        NSLog(@"password is correct, or, database has been initialized");
    } else {
        NSLog(@"incorrect password! errCode:%d",result);
        return NO;
    }

    return YES;
}
- (BOOL)openBihuaDatabase {

    //NSString *dbPath = [LWHelper copy2DocumentsWithFileName:@"bhwords.dat"];
    int result = sqlite3_open([self.bihuaDBPath UTF8String], &dbBihuaSqlite);
    if (SQLITE_OK != result) {
        NSLog(@"打开 BihuaWords DB失败 = %d", result);
        sqlite3_close(dbBihuaSqlite);
        return NO;
    }

    //验证密码
    const char* key = [@"luowei.wodedata.com" UTF8String];
    sqlite3_key(dbBihuaSqlite, key, (int)strlen(key));
    int res = sqlite3_exec(dbBihuaSqlite, (const char*) "SELECT count(*) FROM sqlite_master;", NULL, NULL, NULL);
    if (res == SQLITE_OK) {
        NSLog(@"password is correct, or, database has been initialized");
    } else {
        NSLog(@"incorrect password! errCode:%d",result);
        return NO;
    }

    return YES;
}

- (void)dealloc {
    sqlite3_close(dbSqlite);
    dbSqlite = nil;
    sqlite3_close(dbBihuaSqlite);
    dbBihuaSqlite = nil;
}

#pragma mark - 查找五笔与拼音

//根据参数zi查找五笔与拼音
- (void)queryWithZi:(NSString *)zi updateUIBlock:(void (^)(NSString *pinyin, NSString *wubi))updateUIBlock {
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSMutableDictionary *dict = [self queryWithZi:zi];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSString *pinyin = dict[@"pinyin"];
//            NSString *wubi = dict[@"wubi"];
//            updateUIBlock(pinyin, wubi);
//        });
//    });

    NSMutableDictionary *dict = [self queryWithZi:zi];
    NSString *pinyin = dict[@"pinyin"];
    NSString *wubi = dict[@"wubi"];
    updateUIBlock(pinyin, wubi);
}

- (NSMutableDictionary *)queryWithZi:(NSString *)zi {
    NSMutableDictionary *convertDict = @{}.mutableCopy;
    NSString *param = [zi stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT pinyin,wubi FROM zidian where zi = '%@' LIMIT 1", param];
    sqlite3_stmt *statement;

    if (sqlite3_prepare_v2(dbSqlite, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSString *pinyinStr = [[NSString alloc] initWithUTF8String:(char *) sqlite3_column_text(statement, 0)];
            NSString *wubiStr = [[NSString alloc] initWithUTF8String:(char *) sqlite3_column_text(statement, 1)];

            NSString *pinyinTrimText = [pinyinStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^(#)([\\w\\W]*)(#)$" options:NSRegularExpressionCaseInsensitive error:nil];
            NSString *pinyin = [regex stringByReplacingMatchesInString:pinyinTrimText options:0 range:NSMakeRange(0, [pinyinTrimText length]) withTemplate:@"$2"];

            convertDict[@"pinyin"] = pinyin;
            convertDict[@"wubi"] = wubiStr;
        }
        sqlite3_finalize(statement);
    }
    return convertDict;
}


//根据参数zi查找笔顺
- (void)queryBiShunWithZi:(NSString *)zi updateUIBlock:(void (^)(NSString *))updateUIBlock {
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSString *bishun = [self queryBiShunWithZi:zi];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            updateUIBlock(bishun);
//        });
//    });

    NSString *bishun = [self queryBiShunWithZi:zi];
    updateUIBlock(bishun);
}

- (NSString *)queryBiShunWithZi:(NSString *)zi {
//    NSMutableDictionary *convertDict = @{}.mutableCopy;
    NSString *param = [zi stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT code FROM words_bihua_full where words = '%@' LIMIT 1", param];
    sqlite3_stmt *statement;

    NSString *code = @"";
    if (sqlite3_prepare_v2(dbBihuaSqlite, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            code = [[NSString alloc] initWithUTF8String:(char *) sqlite3_column_text(statement, 0)];
        }
        sqlite3_finalize(statement);
    }

    __block NSString *bishun = @"";
    [self enumerateCharacters:code usingBlock:^(NSString *character, NSInteger idx, bool *stop) {
        if([character isEqualToString:@"1"]){
            bishun = [NSString stringWithFormat:@"%@%@",bishun,@"一"];
        }else if([character isEqualToString:@"2"]){
            bishun = [NSString stringWithFormat:@"%@%@",bishun,@"｜"];
        }else if([character isEqualToString:@"3"]){
            bishun = [NSString stringWithFormat:@"%@%@",bishun,@"ノ"];
        }else if([character isEqualToString:@"4"]){
            bishun = [NSString stringWithFormat:@"%@%@",bishun,@"、"];
        }else if([character isEqualToString:@"5"]){
            bishun = [NSString stringWithFormat:@"%@%@",bishun,@"ㄥ"];
        }else if([character isEqualToString:@"_"]){
            bishun = [NSString stringWithFormat:@"%@%@",bishun,@"*"];
        }
    }];

    return bishun;
}

#pragma mark - 百度翻译

//百度翻译文字
- (void)fanyiZi:(NSString *)zi to:(NSString *)to updateUIBlock:(void (^)(NSString *text,BOOL isErrorMsg))updateUIBlock{

    if(to && ![self isBlankString:to]){
        self.toLanguage = to;
    }
    __block NSString *translation = @"";
    //检查网络
    if (self.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        translation = NSLocalizedString(@"Check Network Connection", nil);
    }

    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];

    NSURL *URL = [NSURL URLWithString:Fanyi_URLString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];

    NSString *salt = [[NSUUID UUID].UUIDString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSString *beforeSign = [NSString stringWithFormat:@"%@%@%@%@", BaiduFanyi_Appid, zi, salt, BaiduFanyi_SecretKey];
    NSString *sign = [self md5HexDigest:beforeSign];
    NSString *postString = [NSString stringWithFormat:@"sign=%@&appid=%@&q=%@&salt=%@&from=auto&to=%@",sign,BaiduFanyi_Appid,zi,salt,self.toLanguage];

    NSMutableCharacterSet *chars = NSCharacterSet.URLQueryAllowedCharacterSet.mutableCopy;
    //[chars removeCharactersInRange:NSMakeRange('&', 1)]; // %26
    NSString *encodeStr = [postString stringByAddingPercentEncodingWithAllowedCharacters:chars];

    //NSString *encodeStr = [postString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    [request setHTTPBody:[encodeStr dataUsingEncoding:NSUTF8StringEncoding]];

//    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
//            LWLog(@"=====Error: %@", error);
        } else {
//            LWLog(@"=====responseObject:%@",responseObject);
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *data = responseObject;
                BOOL isError = data[@"error_code"] && ![@"52000" isEqualToString:data[@"error_code"]];
                if (isError) {
                    translation = data[@"error_msg"];
                } else {
                    NSArray *resutlArr = data[@"trans_result"];
                    translation = resutlArr.firstObject[@"dst"];
                }

                if ([NSThread isMainThread]) {
                    updateUIBlock(translation, isError); //更新UI
                } else {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        updateUIBlock(translation, isError);  //更新UI
                    });
                }

            }


        }
    }];
    [dataTask resume];
}


//生成32位的16进制小写的md5串
- (NSString *)md5HexDigest:(NSString *)str {
    const char *original_str = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, (CC_LONG)strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        //%02X是格式控制符：‘x’表示以16进制输出，‘02’表示不足两位，前面补0；
        [hash appendFormat:@"%02X", result[i]];
    }
    NSString *mdfiveString = [hash lowercaseString];
    return mdfiveString;
}

- (void)enumerateCharacters:(NSString *)string usingBlock:(void (^)(NSString *character, NSInteger idx, bool *stop))block {
    bool _stop = NO;
    for (NSInteger i = 0; i < [string length] && !_stop; i++) {
        NSString *character = [string substringWithRange:NSMakeRange(i, 1)];
        block(character, i, &_stop);
    }
}

-(BOOL)isBlankString:(NSString *)string {
    if([string length] == 0) { //string is empty or nil
        return YES;
    }
    return ![[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length];
}


@end
