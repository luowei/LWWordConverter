# LWWordConverter

[![CI Status](https://img.shields.io/travis/luowei/LWWordConverter.svg?style=flat)](https://travis-ci.org/luowei/LWWordConverter)
[![Version](https://img.shields.io/cocoapods/v/LWWordConverter.svg?style=flat)](https://cocoapods.org/pods/LWWordConverter)
[![License](https://img.shields.io/cocoapods/l/LWWordConverter.svg?style=flat)](https://cocoapods.org/pods/LWWordConverter)
[![Platform](https://img.shields.io/cocoapods/p/LWWordConverter.svg?style=flat)](https://cocoapods.org/pods/LWWordConverter)

## 简介

LWWordConverter 是一个功能强大的中文文字处理工具库，提供多种文字转换和处理功能，包括：

- **拼音查询**：查询汉字的拼音读音
- **五笔编码查询**：查询汉字的五笔输入法编码
- **笔顺查询**：查询汉字的笔画顺序
- **在线翻译**：基于必应翻译API的多语言翻译功能
- **文本加密/解密**：隐蔽的文本加密方案，支持自定义显示文本

## 主要特性

### 1. 汉字信息查询

基于 SQLCipher 加密数据库，提供完整的汉字信息查询功能：

- **拼音查询**：获取汉字的标准拼音
- **五笔编码**：获取汉字的五笔输入法编码
- **笔顺信息**：获取汉字的笔画顺序（横、竖、撇、捺、折）

### 2. 在线翻译

- 基于必应翻译 API
- 支持多种语言互译
- 自动网络状态检测
- 异步处理，不阻塞主线程

### 3. 文本加密

- 基于 Base64 和自定义编码的文本加密方案
- 支持隐蔽显示：加密文本可以显示为任意指定的明文
- 内置三国杀台词作为预设显示文本
- 轻松识别和解密加密文本

## 系统要求

- iOS 8.0 或更高版本
- Xcode 9.0 或更高版本

## 安装

LWWordConverter 可以通过 [CocoaPods](https://cocoapods.org) 安装。只需在你的 Podfile 中添加以下内容：

```ruby
pod 'LWWordConverter'
```

然后执行：

```bash
pod install
```

## 依赖库

- **SQLCipher**：用于加密数据库存储
- **LWReachabilityManager**：用于网络状态监测

## 使用方法

### 1. 初始化服务

首先需要创建一个 `LWConverterService` 实例，并提供两个加密数据库文件的路径：

```objective-c
// 初始化转换服务
self.converterService = [LWConverterService serviceWithDBPath:dbPath
                                                  bihuaDBPath:bihuaDBPath];
```

**参数说明：**
- `dbPath`：字典数据库文件路径（包含拼音和五笔数据）
- `bihuaDBPath`：笔画数据库文件路径（包含笔顺数据）

### 2. 查询拼音和五笔

使用异步方法查询单个汉字的拼音和五笔编码：

```objective-c
// 查询拼音和五笔（异步）
[self.converterService queryWithZi:zi updateUIBlock:^(NSString *pinyin, NSString *wubi) {
    // 处理拼音
    if (!pinyin) {
        pinyin = @"";
    }
    pinyinText = [NSString stringWithFormat:@"%@ %@", pinyinText, pinyin];

    // 处理五笔
    if (!wubi) {
        wubi = @"";
    }
    wubiText = [NSString stringWithFormat:@"%@  %@", wubiText, wubi];
}];
```

**返回结果：**
- `pinyin`：汉字的拼音读音（去除格式标记）
- `wubi`：汉字的五笔编码

### 3. 查询笔顺

查询单个汉字的笔画顺序：

```objective-c
// 查询笔顺（异步）
[self.converterService queryBiShunWithZi:zi updateUIBlock:^(NSString *bishun) {
    if (!bishun) {
        bishun = @"";
    }
    bishunText = [NSString stringWithFormat:@"%@    %@", bishunText, bishun];
}];
```

**笔顺符号说明：**
- `一`：横（代码：1）
- `｜`：竖（代码：2）
- `ノ`：撇（代码：3）
- `、`：捺（代码：4）
- `ㄥ`：折（代码：5）
- `*`：其他笔画

### 4. 在线翻译

将文本翻译成目标语言：

```objective-c
// 翻译文本
__weak typeof(self) weakSelf = self;
[self.converterService fanyiZi:self.sourceText
                            to:self.translateLanguage
                   updateUIBlock:^(NSString *translation, BOOL isError) {
    if (isError) {
        // 处理错误情况
        NSLog(@"翻译出错：%@", translation);
    } else {
        // 使用翻译结果
        NSLog(@"翻译结果：%@", translation);
    }
}];
```

**参数说明：**
- `sourceText`：要翻译的源文本
- `translateLanguage`：目标语言代码（如：`en` 英语，`ja` 日语，`ko` 韩语等）
- `translation`：翻译结果或错误信息
- `isError`：是否发生错误

**支持的语言代码：**
- `en`：英语
- `zh-Hans`：简体中文
- `zh-Hant`：繁体中文
- `ja`：日语
- `ko`：韩语
- `fr`：法语
- `de`：德语
- `es`：西班牙语
- `ru`：俄语
- 等等（支持必应翻译的所有语言）

### 5. 文本加密和解密

LWWordConverter 提供了一种隐蔽的文本加密方案，可以让加密文本显示为任意指定的明文。

#### 5.1 检测加密文本

```objective-c
// 检测文本是否为加密文本
BOOL isEncrypted = [LWEncryptService isEncryptString:inputText];
```

#### 5.2 加密文本

```objective-c
// 加密文本
NSArray *shortcuts = [LWEncryptService getShortcut];
NSUInteger index = arc4random() % shortcuts.count;

// 使用随机的三国杀台词作为显示文本
NSString *encryptText = [LWEncryptService encryptText:inputText
                                          displayText:shortcuts[index]];

// encryptText 可以复制到剪贴板或分享
[UIPasteboard generalPasteboard].string = encryptText;
```

**参数说明：**
- `inputText`：要加密的原始文本
- `displayText`：加密后显示的伪装文本（可以是任意文本）
- 返回值：加密后的文本（包含隐藏的原文和显示的伪装文本）

#### 5.3 解密文本

```objective-c
// 从剪贴板获取文本
NSString *pasteText = [UIPasteboard generalPasteboard].string;

// 检测是否为加密文本
if ([LWEncryptService isEncryptString:pasteText]) {
    // 解密文本
    NSString *decryptText = [LWEncryptService decryptText:pasteText];
    NSLog(@"解密后的文本：%@", decryptText);
}
```

#### 5.4 加密模式设置

```objective-c
// 设置加密模式
[LWEncryptService saveEncryptMode:EncryptModeEmoji];

// 获取当前加密模式
EncryptMode mode = [LWEncryptService getEncryptMode];
```

**加密模式：**
- `EncryptModeEmoji`：表情包模式（0）
- `EncryptModeSanGuoSha`：三国杀模式（1）

#### 5.5 获取预设显示文本

```objective-c
// 获取内置的三国杀台词列表
NSArray *shortcuts = [LWEncryptService getShortcut];

// 随机选择一个台词作为显示文本
NSString *randomShortcut = shortcuts[arc4random() % shortcuts.count];
```

### 6. 完整示例

```objective-c
#import "LWConverterService.h"
#import "LWEncryptService.h"

// 初始化服务
NSString *dbPath = [[NSBundle mainBundle] pathForResource:@"zidian" ofType:@"dat"];
NSString *bihuaDBPath = [[NSBundle mainBundle] pathForResource:@"bhwords" ofType:@"dat"];
self.converterService = [LWConverterService serviceWithDBPath:dbPath bihuaDBPath:bihuaDBPath];

// 查询汉字"中"的信息
NSString *zi = @"中";

// 查询拼音和五笔
[self.converterService queryWithZi:zi updateUIBlock:^(NSString *pinyin, NSString *wubi) {
    NSLog(@"拼音：%@", pinyin);  // 输出：zhong
    NSLog(@"五笔：%@", wubi);    // 输出：khk
}];

// 查询笔顺
[self.converterService queryBiShunWithZi:zi updateUIBlock:^(NSString *bishun) {
    NSLog(@"笔顺：%@", bishun);  // 输出：｜一｜一
}];

// 翻译文本
[self.converterService fanyiZi:@"你好世界" to:@"en" updateUIBlock:^(NSString *translation, BOOL isError) {
    if (!isError) {
        NSLog(@"翻译：%@", translation);  // 输出：Hello World
    }
}];

// 加密文本
NSString *secret = @"这是一段机密文本";
NSString *encrypted = [LWEncryptService encryptText:secret displayText:@"今天天气真好"];
NSLog(@"加密文本：%@", encrypted);  // 显示：今天天气真好（实际包含加密数据）

// 解密文本
NSString *decrypted = [LWEncryptService decryptText:encrypted];
NSLog(@"解密文本：%@", decrypted);  // 输出：这是一段机密文本
```

## 运行示例项目

要运行示例项目，请按以下步骤操作：

1. 克隆仓库到本地
2. 进入 Example 目录
3. 运行 `pod install`
4. 打开 `LWWordConverter.xcworkspace`
5. 编译运行

```bash
git clone https://github.com/luowei/LWWordConverter.git
cd LWWordConverter/Example
pod install
open LWWordConverter.xcworkspace
```

## 数据库说明

LWWordConverter 使用两个 SQLCipher 加密数据库：

1. **字典数据库**（zidian.dat）
   - 表名：`zidian`
   - 字段：`zi`（汉字）、`pinyin`（拼音）、`wubi`（五笔）
   - 密码：`luowei.wodedata.com`

2. **笔画数据库**（bhwords.dat）
   - 表名：`words_bihua_full`
   - 字段：`words`（汉字）、`code`（笔画编码）
   - 密码：`luowei.wodedata.com`

**注意：** 这两个数据库文件需要你自行准备或从示例项目中获取。

## 加密原理

文本加密采用以下方案：

1. 将原始文本使用 UTF-8 编码转换为 Base64 字符串
2. 将 Base64 字符串的每个字符映射为 3 字节的控制字符
3. 添加分隔符 `\006\006\006`
4. 附加用于显示的伪装文本
5. 解密时，提取分隔符前的控制字符，反向映射为 Base64，再解码为原始文本

这种方案的优点：
- 加密文本看起来像普通文本
- 可以自定义显示内容，提高隐蔽性
- 解密过程简单快速
- 使用不可见的控制字符存储实际数据

## API 参考

### LWConverterService

#### 初始化方法

```objective-c
+ (LWConverterService *)serviceWithDBPath:(NSString *)dbPath
                              bihuaDBPath:(NSString *)bihuaDBPath;
```

#### 查询方法

```objective-c
// 查询拼音和五笔
- (void)queryWithZi:(NSString *)zi
     updateUIBlock:(void (^)(NSString *pinyin, NSString *wubi))updateUIBlock;

// 查询笔顺
- (void)queryBiShunWithZi:(NSString *)zi
           updateUIBlock:(void (^)(NSString *bishun))updateUIBlock;

// 翻译文本
- (void)fanyiZi:(NSString *)zi
             to:(NSString *)to
    updateUIBlock:(void (^)(NSString *text, BOOL isErrorMsg))updateUIBlock;
```

#### 属性

```objective-c
@property (nonatomic) NSInteger networkReachabilityStatus;  // 网络状态
@property (nonatomic, strong) NSObject *toLanguage;         // 目标语言
@property (nonatomic, strong) NSString *dbPath;             // 字典数据库路径
@property (nonatomic, strong) NSString *bihuaDBPath;        // 笔画数据库路径
```

### LWEncryptService

#### 类方法

```objective-c
// 检测是否为加密文本
+ (BOOL)isEncryptString:(NSString *)str;

// 加密文本
+ (NSString *)encryptText:(NSString *)primevalText
              displayText:(NSString *)displayText;

// 解密文本
+ (NSString *)decryptText:(NSString *)imitativeText;

// 保存加密模式
+ (void)saveEncryptMode:(EncryptMode)encryptMode;

// 获取加密模式
+ (EncryptMode)getEncryptMode;

// 获取预设显示文本列表
+ (NSArray *)getShortcut;
```

#### 加密模式枚举

```objective-c
typedef NS_OPTIONS(NSUInteger, EncryptMode) {
    EncryptModeEmoji = 0,      // 表情包模式
    EncryptModeSanGuoSha = 1   // 三国杀模式
};
```

## 注意事项

1. **数据库文件**：使用前需要准备好加密的数据库文件，并正确设置路径
2. **网络权限**：翻译功能需要网络访问权限，请在 Info.plist 中配置相应权限
3. **线程安全**：查询方法已经在内部处理了线程切换，回调会在主线程执行
4. **内存管理**：服务实例会在 dealloc 时自动关闭数据库连接
5. **错误处理**：所有异步方法都提供了错误回调，请妥善处理错误情况

## 性能优化建议

1. 复用 `LWConverterService` 实例，避免频繁创建
2. 数据库文件建议放在应用 Bundle 中，避免运行时复制
3. 批量查询时建议添加适当延迟，避免过度占用资源
4. 翻译功能会发起网络请求，建议添加缓存机制

## 常见问题

### 1. 数据库打开失败

**原因：** 数据库文件路径错误或文件不存在

**解决方案：**
```objective-c
BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:dbPath];
if (!exists) {
    NSLog(@"数据库文件不存在：%@", dbPath);
}
```

### 2. 翻译返回错误

**原因：** 网络连接问题或 API 限制

**解决方案：**
- 检查网络连接状态
- 确认设备可以访问必应翻译服务
- 避免频繁调用 API

### 3. 查询结果为空

**原因：** 数据库中没有该字的记录

**解决方案：**
- 检查输入的字符是否为有效的汉字
- 确认数据库内容完整
- 对空结果进行适当处理

## 更新日志

### v1.0.0
- 初始版本发布
- 支持拼音、五笔、笔顺查询
- 支持必应翻译 API
- 支持文本加密/解密功能

## 许可证

LWWordConverter 使用 MIT 许可证。详情请参阅 [LICENSE](LICENSE) 文件。

```
Copyright (c) 2019 luowei <luowei@wodedata.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```

## 作者

**luowei** - [luowei@wodedata.com](mailto:luowei@wodedata.com)

## 相关链接

- [GitHub 仓库](https://github.com/luowei/LWWordConverter)
- [CocoaPods](https://cocoapods.org/pods/LWWordConverter)
- [问题反馈](https://github.com/luowei/LWWordConverter/issues)

## 贡献

欢迎提交 Issue 和 Pull Request！

如果你有任何问题或建议，请通过以下方式联系：

1. 提交 [GitHub Issue](https://github.com/luowei/LWWordConverter/issues)
2. 发送邮件至 [luowei@wodedata.com](mailto:luowei@wodedata.com)

## 致谢

感谢以下开源项目：

- [SQLCipher](https://github.com/sqlcipher/sqlcipher) - 提供数据库加密支持
- [LWReachabilityManager](https://github.com/luowei/LWReachabilityManager) - 提供网络状态监测

---

**注意：** 本项目仅供学习和研究使用，请遵守相关法律法规和服务条款。
