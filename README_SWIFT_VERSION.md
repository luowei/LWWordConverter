# LWWordConverter Swift Version

[English](#english) | [中文](#中文)

---

## English

### Overview

`LWWordConverter_swift` is the Swift version of the LWWordConverter library, providing a modern Swift API for Chinese character processing. It includes the same powerful features as the Objective-C version but with a more idiomatic Swift interface.

### Features

- Pinyin and Wubi encoding queries for Chinese characters
- Stroke order (bishun) queries
- Text translation via Bing Translator API
- Text encryption/decryption with steganographic display
- Network reachability monitoring

### Requirements

- iOS 13.0 or higher
- Swift 5.0 or higher
- Xcode 11.0 or higher

### Installation

Add the following line to your Podfile:

```ruby
pod 'LWWordConverter_swift'
```

Then run:

```bash
pod install
```

### Dependencies

- SQLCipher (~> 4.0)
- LWReachabilityManager

### Usage

#### 1. Import the Module

```swift
import LWWordConverter_swift
```

#### 2. Initialize Service

```swift
guard let dbPath = Bundle.main.path(forResource: "zidian", ofType: "dat"),
      let bihuaDBPath = Bundle.main.path(forResource: "bhwords", ofType: "dat") else {
    fatalError("Database files not found")
}

let converterService = LWConverterService(dbPath: dbPath, bihuaDBPath: bihuaDBPath)
```

#### 3. Query Pinyin and Wubi

```swift
converterService.query(zi: "中") { pinyin, wubi in
    print("Pinyin: \(pinyin ?? "")")  // Output: zhong
    print("Wubi: \(wubi ?? "")")      // Output: khk
}
```

#### 4. Query Stroke Order

```swift
converterService.queryBiShun(zi: "中") { bishun in
    print("Stroke order: \(bishun ?? "")")  // Output: ｜一｜一
}
```

#### 5. Translation

```swift
converterService.translate(text: "你好世界", to: "en") { translation, isError in
    if !isError {
        print("Translation: \(translation)")  // Output: Hello World
    } else {
        print("Error: \(translation)")
    }
}
```

#### 6. Text Encryption

```swift
// Check if text is encrypted
let isEncrypted = LWEncryptService.isEncryptString("some text")

// Encrypt text
let encrypted = LWEncryptService.encryptText("Secret message", displayText: "Nice weather today")
print("Encrypted: \(encrypted)")

// Decrypt text
if LWEncryptService.isEncryptString(encrypted) {
    let decrypted = LWEncryptService.decryptText(encrypted)
    print("Decrypted: \(decrypted)")  // Output: Secret message
}
```

### Complete Example

```swift
import UIKit
import LWWordConverter_swift

class ViewController: UIViewController {
    var converterService: LWConverterService?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize service
        guard let dbPath = Bundle.main.path(forResource: "zidian", ofType: "dat"),
              let bihuaDBPath = Bundle.main.path(forResource: "bhwords", ofType: "dat") else {
            return
        }

        converterService = LWConverterService(dbPath: dbPath, bihuaDBPath: bihuaDBPath)

        // Query character information
        converterService?.query(zi: "中") { pinyin, wubi in
            print("Pinyin: \(pinyin ?? ""), Wubi: \(wubi ?? "")")
        }

        // Translate text
        converterService?.translate(text: "你好", to: "en") { translation, isError in
            if !isError {
                print("Translation: \(translation)")
            }
        }

        // Encrypt/Decrypt
        let encrypted = LWEncryptService.encryptText("Secret", displayText: "Public")
        let decrypted = LWEncryptService.decryptText(encrypted)
        print("Original: Secret, Decrypted: \(decrypted)")
    }
}
```

### API Differences from Objective-C Version

The Swift version provides a more Swift-friendly API:

| Objective-C | Swift |
|-------------|-------|
| `serviceWithDBPath:bihuaDBPath:` | `init(dbPath:bihuaDBPath:)` |
| `queryWithZi:updateUIBlock:` | `query(zi:completion:)` |
| `queryBiShunWithZi:updateUIBlock:` | `queryBiShun(zi:completion:)` |
| `fanyiZi:to:updateUIBlock:` | `translate(text:to:completion:)` |
| `[LWEncryptService encryptText:displayText:]` | `LWEncryptService.encryptText(_:displayText:)` |
| `[LWEncryptService decryptText:]` | `LWEncryptService.decryptText(_:)` |

### Notes

- All completion handlers are called on the main thread
- The Swift version requires iOS 13.0 or higher (compared to iOS 8.0 for Objective-C version)
- SwiftUI support is available through the `LWWordConverterView` component

### License

LWWordConverter_swift is available under the MIT license. See the LICENSE file for more info.

---

## 中文

### 概述

`LWWordConverter_swift` 是 LWWordConverter 库的 Swift 版本，为中文字符处理提供了现代化的 Swift API。它包含与 Objective-C 版本相同的强大功能，但具有更符合 Swift 习惯的接口。

### 功能特性

- 中文字符的拼音和五笔编码查询
- 笔顺查询
- 通过必应翻译 API 进行文本翻译
- 带隐写显示的文本加密/解密
- 网络可达性监控

### 系统要求

- iOS 13.0 或更高版本
- Swift 5.0 或更高版本
- Xcode 11.0 或更高版本

### 安装

在 Podfile 中添加以下行：

```ruby
pod 'LWWordConverter_swift'
```

然后运行：

```bash
pod install
```

### 依赖项

- SQLCipher (~> 4.0)
- LWReachabilityManager

### 使用方法

#### 1. 导入模块

```swift
import LWWordConverter_swift
```

#### 2. 初始化服务

```swift
guard let dbPath = Bundle.main.path(forResource: "zidian", ofType: "dat"),
      let bihuaDBPath = Bundle.main.path(forResource: "bhwords", ofType: "dat") else {
    fatalError("未找到数据库文件")
}

let converterService = LWConverterService(dbPath: dbPath, bihuaDBPath: bihuaDBPath)
```

#### 3. 查询拼音和五笔

```swift
converterService.query(zi: "中") { pinyin, wubi in
    print("拼音: \(pinyin ?? "")")  // 输出: zhong
    print("五笔: \(wubi ?? "")")    // 输出: khk
}
```

#### 4. 查询笔顺

```swift
converterService.queryBiShun(zi: "中") { bishun in
    print("笔顺: \(bishun ?? "")")  // 输出: ｜一｜一
}
```

#### 5. 翻译

```swift
converterService.translate(text: "你好世界", to: "en") { translation, isError in
    if !isError {
        print("翻译: \(translation)")  // 输出: Hello World
    } else {
        print("错误: \(translation)")
    }
}
```

#### 6. 文本加密

```swift
// 检查文本是否已加密
let isEncrypted = LWEncryptService.isEncryptString("某些文本")

// 加密文本
let encrypted = LWEncryptService.encryptText("秘密消息", displayText: "今天天气不错")
print("加密后: \(encrypted)")

// 解密文本
if LWEncryptService.isEncryptString(encrypted) {
    let decrypted = LWEncryptService.decryptText(encrypted)
    print("解密后: \(decrypted)")  // 输出: 秘密消息
}
```

### 完整示例

```swift
import UIKit
import LWWordConverter_swift

class ViewController: UIViewController {
    var converterService: LWConverterService?

    override func viewDidLoad() {
        super.viewDidLoad()

        // 初始化服务
        guard let dbPath = Bundle.main.path(forResource: "zidian", ofType: "dat"),
              let bihuaDBPath = Bundle.main.path(forResource: "bhwords", ofType: "dat") else {
            return
        }

        converterService = LWConverterService(dbPath: dbPath, bihuaDBPath: bihuaDBPath)

        // 查询字符信息
        converterService?.query(zi: "中") { pinyin, wubi in
            print("拼音: \(pinyin ?? ""), 五笔: \(wubi ?? "")")
        }

        // 翻译文本
        converterService?.translate(text: "你好", to: "en") { translation, isError in
            if !isError {
                print("翻译: \(translation)")
            }
        }

        // 加密/解密
        let encrypted = LWEncryptService.encryptText("秘密", displayText: "公开")
        let decrypted = LWEncryptService.decryptText(encrypted)
        print("原文: 秘密, 解密: \(decrypted)")
    }
}
```

### 与 Objective-C 版本的 API 差异

Swift 版本提供了更符合 Swift 习惯的 API：

| Objective-C | Swift |
|-------------|-------|
| `serviceWithDBPath:bihuaDBPath:` | `init(dbPath:bihuaDBPath:)` |
| `queryWithZi:updateUIBlock:` | `query(zi:completion:)` |
| `queryBiShunWithZi:updateUIBlock:` | `queryBiShun(zi:completion:)` |
| `fanyiZi:to:updateUIBlock:` | `translate(text:to:completion:)` |
| `[LWEncryptService encryptText:displayText:]` | `LWEncryptService.encryptText(_:displayText:)` |
| `[LWEncryptService decryptText:]` | `LWEncryptService.decryptText(_:)` |

### 注意事项

- 所有完成处理程序都在主线程上调用
- Swift 版本要求 iOS 13.0 或更高版本（相比 Objective-C 版本的 iOS 8.0）
- 通过 `LWWordConverterView` 组件提供 SwiftUI 支持

### 许可证

LWWordConverter_swift 采用 MIT 许可证。详见 LICENSE 文件。
