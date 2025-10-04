# LWWordConverter

[中文版](./README_ZH.md) | English | [Swift Version](./README_SWIFT_VERSION.md)

[![CI Status](https://img.shields.io/travis/luowei/LWWordConverter.svg?style=flat)](https://travis-ci.org/luowei/LWWordConverter)
[![Version](https://img.shields.io/cocoapods/v/LWWordConverter.svg?style=flat)](https://cocoapods.org/pods/LWWordConverter)
[![License](https://img.shields.io/cocoapods/l/LWWordConverter.svg?style=flat)](https://cocoapods.org/pods/LWWordConverter)
[![Platform](https://img.shields.io/cocoapods/p/LWWordConverter.svg?style=flat)](https://cocoapods.org/pods/LWWordConverter)

> **Note:** A Swift version of this library is now available! See [README_SWIFT_VERSION.md](./README_SWIFT_VERSION.md) for details on using `LWWordConverter_swift`.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
  - [Chinese Character Query](#chinese-character-query)
  - [Word Translation](#word-translation)
  - [Text Encryption](#text-encryption)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Usage](#usage)
- [API Reference](#api-reference)
- [Database Information](#database-information)
- [Important Notes](#important-notes)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [Changelog](#changelog)
- [License](#license)

## Overview

LWWordConverter is a comprehensive Chinese character processing library for iOS that provides powerful features for working with Chinese text:

- **Pinyin Query**: Look up pinyin pronunciation for Chinese characters
- **Wubi Input Method**: Query Wubi (五笔) input codes for characters
- **Stroke Order Query**: Get stroke order information (bishun/笔顺) for learning character writing
- **Word Translation**: Translate Chinese text to multiple languages using Bing Translator API
- **Text Encryption/Decryption**: Secure text encryption with customizable steganographic display text

## Features

### Chinese Character Query

Based on SQLCipher encrypted databases, providing comprehensive Chinese character information:

- **Pinyin Query**: Get standard pinyin pronunciation for Chinese characters
- **Wubi Encoding**: Get Wubi (五笔) input method codes for efficient typing
- **Stroke Order**: Get detailed stroke order sequences with visual stroke symbols

**Stroke Symbols:**
- `一`: Horizontal stroke
- `｜`: Vertical stroke
- `ノ`: Left-falling stroke (pie)
- `、`: Right-falling stroke (na)
- `ㄥ`: Turning stroke
- `*`: Other strokes

### Word Translation

Powerful translation capabilities powered by Bing Translator API:

- **Multi-language Support**: Translate between 20+ languages
- **Network Detection**: Automatic network status monitoring
- **Async Processing**: Non-blocking asynchronous operations for smooth UI
- **Error Handling**: Comprehensive error reporting and handling
- **Reliable Results**: Production-ready translation quality

**Supported Languages:**
- Asian: Simplified Chinese (zh-Hans), Traditional Chinese (zh-Hant), Japanese (ja), Korean (ko)
- European: English (en), French (fr), German (de), Spanish (es), Russian (ru)
- And all other languages supported by Bing Translator

### Text Encryption

Innovative steganographic encryption system:

- **Steganographic Display**: Encrypted text appears as any specified plain text
- **Base64 Foundation**: Built on secure Base64 encoding with custom character mapping
- **Preset Templates**: Built-in display texts including Three Kingdoms Kill quotes
- **Easy Detection**: Simple API to detect encrypted text
- **Two Modes**: Emoji mode and San Guo Sha (Three Kingdoms Kill) mode

**How It Works:**
1. Original text is encoded to Base64 using UTF-8
2. Each Base64 character is mapped to 3-byte control characters (invisible)
3. A separator `\006\006\006` is added
4. The steganographic display text is appended (visible part)
5. Decryption extracts control characters and reverses the process

This design allows encrypted messages to hide in plain sight - the visible text can say anything while the hidden message remains encrypted.

## Requirements

- iOS 8.0 or higher
- Xcode 9.0 or higher

## Installation

LWWordConverter is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'LWWordConverter'
```

Then run:

```bash
pod install
```

## Dependencies

- **SQLCipher**: For encrypted database storage
- **LWReachabilityManager**: For network status monitoring

## Quick Start

To run the example project:

1. Clone the repository
2. Navigate to the Example directory
3. Run `pod install`
4. Open `LWWordConverter.xcworkspace`
5. Build and run

```bash
git clone https://github.com/luowei/LWWordConverter.git
cd LWWordConverter/Example
pod install
open LWWordConverter.xcworkspace
```

## Usage

### Overview

LWWordConverter provides two main service classes:
- **LWConverterService**: For Chinese character queries and translation
- **LWEncryptService**: For text encryption and decryption

### 1. Initialize Service

Create an `LWConverterService` instance with paths to the encrypted database files:

```objective-c
// Initialize converter service
NSString *dbPath = [[NSBundle mainBundle] pathForResource:@"zidian" ofType:@"dat"];
NSString *bihuaDBPath = [[NSBundle mainBundle] pathForResource:@"bhwords" ofType:@"dat"];
self.converterService = [LWConverterService serviceWithDBPath:dbPath
                                                  bihuaDBPath:bihuaDBPath];
```

**Parameters:**
- `dbPath`: Path to dictionary database file (contains pinyin and Wubi data)
- `bihuaDBPath`: Path to stroke database file (contains stroke order data)

### 2. Query Pinyin and Wubi

Query pinyin pronunciation and Wubi input codes for Chinese characters (asynchronous):

```objective-c
// Query pinyin and Wubi (asynchronous)
[self.converterService queryWithZi:zi updateUIBlock:^(NSString *pinyin, NSString *wubi) {
    // Handle pinyin result
    if (!pinyin) {
        pinyin = @"";
    }
    pinyinText = [NSString stringWithFormat:@"%@ %@", pinyinText, pinyin];

    // Handle Wubi result
    if (!wubi) {
        wubi = @"";
    }
    wubiText = [NSString stringWithFormat:@"%@  %@", wubiText, wubi];
}];
```

**Returns:**
- `pinyin`: Pinyin pronunciation of the character (without tone markers)
- `wubi`: Wubi input method code

### 3. Query Stroke Order

Get stroke order (bishun) information for Chinese characters to learn proper character writing sequence (asynchronous):

```objective-c
// Query stroke order (asynchronous)
[self.converterService queryBiShunWithZi:zi updateUIBlock:^(NSString *bishun) {
    if (!bishun) {
        bishun = @"";
    }
    bishunText = [NSString stringWithFormat:@"%@    %@", bishunText, bishun];
}];
```

**Stroke Symbol Guide:**
- `一`: Horizontal stroke (heng, code: 1)
- `｜`: Vertical stroke (shu, code: 2)
- `ノ`: Left-falling stroke (pie, code: 3)
- `、`: Right-falling stroke (na, code: 4)
- `ㄥ`: Turning stroke (zhe, code: 5)
- `*`: Other strokes

For example, the character "中" (zhong) has stroke order: `｜一｜一` (vertical, horizontal, vertical, horizontal)

### 4. Translate Text

Translate text to different target languages:

```objective-c
// Translate text
__weak typeof(self) weakSelf = self;
[self.converterService fanyiZi:self.sourceText
                            to:self.translateLanguage
                   updateUIBlock:^(NSString *translation, BOOL isError) {
    if (isError) {
        // Handle error
        NSLog(@"Translation error: %@", translation);
    } else {
        // Use translation result
        NSLog(@"Translation: %@", translation);
    }
}];
```

**Parameters:**
- `sourceText`: Source text to translate
- `translateLanguage`: Target language code (e.g., `en` for English, `ja` for Japanese, `ko` for Korean)
- `translation`: Translation result or error message
- `isError`: Whether an error occurred

**Supported Language Codes:**
- `en`: English
- `zh-Hans`: Simplified Chinese
- `zh-Hant`: Traditional Chinese
- `ja`: Japanese
- `ko`: Korean
- `fr`: French
- `de`: German
- `es`: Spanish
- `ru`: Russian
- And all other languages supported by Bing Translator

### 5. Text Encryption and Decryption

The encryption feature allows you to hide secret messages within innocent-looking text. The encrypted message is invisible to casual observers, but can be easily extracted by anyone who knows to look for it.

#### 5.1 Detect Encrypted Text

Check whether a string contains encrypted data:

```objective-c
// Check if text is encrypted
BOOL isEncrypted = [LWEncryptService isEncryptString:inputText];
```

#### 5.2 Encrypt Text

Hide your secret message within innocent-looking cover text:

```objective-c
// Encrypt text with steganographic display
NSArray *shortcuts = [LWEncryptService getShortcut];
NSUInteger index = arc4random() % shortcuts.count;

// Use random Three Kingdoms Kill quote as display text
NSString *encryptText = [LWEncryptService encryptText:inputText
                                          displayText:shortcuts[index]];

// Copy to clipboard or share
[UIPasteboard generalPasteboard].string = encryptText;
```

**Parameters:**
- `inputText`: Original text to encrypt (your secret message)
- `displayText`: Steganographic display text (what others will see - can be any text)
- **Returns**: Encrypted text that displays as `displayText` but contains hidden `inputText`

**Example:**
```objective-c
NSString *secret = @"Meet me at 3pm";
NSString *encrypted = [LWEncryptService encryptText:secret
                                        displayText:@"Nice weather today"];
// encrypted will look like "Nice weather today" but contains "Meet me at 3pm"
```

#### 5.3 Decrypt Text

Extract the hidden message from encrypted text:

```objective-c
// Get text from clipboard
NSString *pasteText = [UIPasteboard generalPasteboard].string;

// Check if text is encrypted
if ([LWEncryptService isEncryptString:pasteText]) {
    // Decrypt text to reveal hidden message
    NSString *decryptText = [LWEncryptService decryptText:pasteText];
    NSLog(@"Decrypted text: %@", decryptText);
} else {
    NSLog(@"This text is not encrypted");
}
```

**Note:** The decrypted text is the original message that was hidden, not the visible display text.

#### 5.4 Encryption Mode Settings

Configure the encryption mode to customize behavior:

```objective-c
// Set encryption mode
[LWEncryptService saveEncryptMode:EncryptModeEmoji];

// Get current encryption mode
EncryptMode mode = [LWEncryptService getEncryptMode];
```

**Available Encryption Modes:**
- `EncryptModeEmoji`: Emoji mode (value: 0)
- `EncryptModeSanGuoSha`: Three Kingdoms Kill mode (value: 1)

#### 5.5 Get Preset Display Texts

The library includes preset display texts that can be used as cover messages:

```objective-c
// Get built-in Three Kingdoms Kill quotes
NSArray *shortcuts = [LWEncryptService getShortcut];

// Randomly select a quote as display text
NSString *randomShortcut = shortcuts[arc4random() % shortcuts.count];

// Use it for encryption
NSString *encrypted = [LWEncryptService encryptText:secretMessage
                                        displayText:randomShortcut];
```

### 6. Complete Example

Here's a comprehensive example demonstrating all major features:

```objective-c
#import "LWConverterService.h"
#import "LWEncryptService.h"

// ========================================
// 1. Initialize Service
// ========================================
NSString *dbPath = [[NSBundle mainBundle] pathForResource:@"zidian" ofType:@"dat"];
NSString *bihuaDBPath = [[NSBundle mainBundle] pathForResource:@"bhwords" ofType:@"dat"];
self.converterService = [LWConverterService serviceWithDBPath:dbPath
                                                  bihuaDBPath:bihuaDBPath];

// ========================================
// 2. Query Character Information
// ========================================
NSString *zi = @"中";

// Query pinyin and Wubi
[self.converterService queryWithZi:zi updateUIBlock:^(NSString *pinyin, NSString *wubi) {
    NSLog(@"Pinyin: %@", pinyin);  // Output: zhong
    NSLog(@"Wubi: %@", wubi);      // Output: khk
}];

// Query stroke order
[self.converterService queryBiShunWithZi:zi updateUIBlock:^(NSString *bishun) {
    NSLog(@"Stroke order: %@", bishun);  // Output: ｜一｜一
}];

// ========================================
// 3. Translation
// ========================================
[self.converterService fanyiZi:@"你好世界"
                            to:@"en"
                   updateUIBlock:^(NSString *translation, BOOL isError) {
    if (!isError) {
        NSLog(@"Translation: %@", translation);  // Output: Hello World
    }
}];

// ========================================
// 4. Text Encryption & Decryption
// ========================================

// Encrypt text
NSString *secret = @"This is confidential information";
NSString *encrypted = [LWEncryptService encryptText:secret
                                        displayText:@"Nice weather today"];
NSLog(@"Encrypted text: %@", encrypted);
// Displays: Nice weather today (but contains hidden encrypted data)

// Detect encryption
BOOL isEncrypted = [LWEncryptService isEncryptString:encrypted];
NSLog(@"Is encrypted: %@", isEncrypted ? @"YES" : @"NO");  // Output: YES

// Decrypt text
NSString *decrypted = [LWEncryptService decryptText:encrypted];
NSLog(@"Decrypted text: %@", decrypted);
// Output: This is confidential information
```

## Database Information

LWWordConverter uses two SQLCipher encrypted databases for secure data storage:

### 1. Dictionary Database (zidian.dat)

Contains pinyin and Wubi input method data for Chinese characters.

| Property | Value |
|----------|-------|
| **File Name** | zidian.dat |
| **Table Name** | zidian |
| **Schema** | `zi` (character), `pinyin` (pronunciation), `wubi` (Wubi code) |
| **Encryption** | SQLCipher |
| **Password** | luowei.wodedata.com |

### 2. Stroke Database (bhwords.dat)

Contains stroke order information for learning Chinese character writing.

| Property | Value |
|----------|-------|
| **File Name** | bhwords.dat |
| **Table Name** | words_bihua_full |
| **Schema** | `words` (character), `code` (stroke code sequence) |
| **Encryption** | SQLCipher |
| **Password** | luowei.wodedata.com |

### Database Setup

**Important:** These database files must be included in your app bundle:

1. Obtain the database files from the example project
2. Add them to your Xcode project
3. Ensure they are included in the "Copy Bundle Resources" build phase
4. Reference them using `NSBundle` as shown in the usage examples

```objective-c
// Example: Load databases from bundle
NSString *dbPath = [[NSBundle mainBundle] pathForResource:@"zidian" ofType:@"dat"];
NSString *bihuaDBPath = [[NSBundle mainBundle] pathForResource:@"bhwords" ofType:@"dat"];
```

## API Reference

### LWConverterService

The main service class for Chinese character queries and translation.

#### Initialization

```objective-c
+ (LWConverterService *)serviceWithDBPath:(NSString *)dbPath
                              bihuaDBPath:(NSString *)bihuaDBPath;
```

Initialize service with database paths.

**Parameters:**
- `dbPath`: Path to the dictionary database file
- `bihuaDBPath`: Path to the stroke database file

**Returns:** An initialized `LWConverterService` instance

---

#### Query Methods

```objective-c
- (void)queryWithZi:(NSString *)zi
     updateUIBlock:(void (^)(NSString *pinyin, NSString *wubi))updateUIBlock;
```

Query pinyin and Wubi code for a Chinese character (asynchronous).

**Parameters:**
- `zi`: The Chinese character to query
- `updateUIBlock`: Callback block executed on main thread
  - `pinyin`: Pinyin pronunciation (nil if not found)
  - `wubi`: Wubi input code (nil if not found)

---

```objective-c
- (void)queryBiShunWithZi:(NSString *)zi
           updateUIBlock:(void (^)(NSString *bishun))updateUIBlock;
```

Query stroke order for a Chinese character (asynchronous).

**Parameters:**
- `zi`: The Chinese character to query
- `updateUIBlock`: Callback block executed on main thread
  - `bishun`: Stroke order sequence (nil if not found)

---

```objective-c
- (void)fanyiZi:(NSString *)zi
             to:(NSString *)to
    updateUIBlock:(void (^)(NSString *text, BOOL isErrorMsg))updateUIBlock;
```

Translate text to a target language using Bing Translator API (asynchronous).

**Parameters:**
- `zi`: Source text to translate
- `to`: Target language code (e.g., "en", "ja", "ko")
- `updateUIBlock`: Callback block executed on main thread
  - `text`: Translation result or error message
  - `isErrorMsg`: YES if an error occurred, NO otherwise

---

#### Properties

```objective-c
@property (nonatomic) NSInteger networkReachabilityStatus;
```
Network status for translation requests.

```objective-c
@property (nonatomic, strong) NSObject *toLanguage;
```
Target language object.

```objective-c
@property (nonatomic, strong) NSString *dbPath;
```
Path to the dictionary database file.

```objective-c
@property (nonatomic, strong) NSString *bihuaDBPath;
```
Path to the stroke database file.

---

### LWEncryptService

Service class for text encryption and decryption with steganographic display.

#### Class Methods

```objective-c
+ (BOOL)isEncryptString:(NSString *)str;
```

Check if a string contains encrypted data.

**Parameters:**
- `str`: String to check

**Returns:** YES if the string is encrypted, NO otherwise

---

```objective-c
+ (NSString *)encryptText:(NSString *)primevalText
              displayText:(NSString *)displayText;
```

Encrypt text with custom steganographic display text.

**Parameters:**
- `primevalText`: Original text to encrypt
- `displayText`: Display text that will be visible (steganographic cover)

**Returns:** Encrypted string that displays as `displayText` but contains hidden `primevalText`

---

```objective-c
+ (NSString *)decryptText:(NSString *)imitativeText;
```

Decrypt encrypted text to recover the original content.

**Parameters:**
- `imitativeText`: Encrypted string (obtained from `encryptText:displayText:`)

**Returns:** Original decrypted text

---

```objective-c
+ (void)saveEncryptMode:(EncryptMode)encryptMode;
```

Save the encryption mode preference.

**Parameters:**
- `encryptMode`: Encryption mode to use

---

```objective-c
+ (EncryptMode)getEncryptMode;
```

Get the current encryption mode.

**Returns:** Current encryption mode

---

```objective-c
+ (NSArray *)getShortcut;
```

Get array of preset display texts (Three Kingdoms Kill quotes).

**Returns:** Array of strings that can be used as steganographic display text

---

#### Enumerations

```objective-c
typedef NS_OPTIONS(NSUInteger, EncryptMode) {
    EncryptModeEmoji = 0,      // Emoji mode
    EncryptModeSanGuoSha = 1   // Three Kingdoms Kill mode
};
```

Encryption modes for customizing the encryption behavior.

---

## Important Notes

### Database Configuration

- **Required Files**: Both database files (zidian.dat and bhwords.dat) must be included in your app bundle
- **File Paths**: Always verify database file paths exist before initializing the service
- **Encryption**: Databases use SQLCipher encryption with the password `luowei.wodedata.com`

### Network Configuration

- **Translation API**: Translation feature requires internet connectivity
- **Permissions**: Add `NSAppTransportSecurity` settings to Info.plist if needed:
  ```xml
  <key>NSAppTransportSecurity</key>
  <dict>
      <key>NSAllowsArbitraryLoads</key>
      <true/>
  </dict>
  ```
- **Network Detection**: The library automatically monitors network status

### Thread Safety

- **Async Callbacks**: All query methods execute callbacks on the main thread
- **UI Updates**: Safe to update UI directly within callback blocks
- **Background Work**: Database queries run on background threads automatically

### Memory Management

- **Auto Cleanup**: Service instances automatically close database connections on dealloc
- **Reuse Recommended**: Create service instances once and reuse them
- **ARC Compatible**: Fully compatible with Automatic Reference Counting

### Error Handling

- **Nil Checks**: Always check for nil results in callbacks
- **Error Flags**: Translation method provides `isError` flag to distinguish errors from results
- **Graceful Degradation**: Handle missing data gracefully in your UI

## Best Practices

### Performance Optimization Tips

1. **Reuse Service Instances**: Reuse `LWConverterService` instances instead of creating them frequently
2. **Bundle Resources**: Store database files in the app bundle to avoid runtime copying
3. **Batch Query Throttling**: Add appropriate delays for batch queries to avoid excessive resource usage
4. **Translation Caching**: Implement caching for translation results to reduce network requests

### Security Considerations

1. **Database Protection**: The encrypted databases use SQLCipher with password protection
2. **Encryption Usage**: Use the encryption feature for sensitive text that needs to be shared
3. **Network Security**: Translation requests are made over HTTPS via Bing Translator API

## Troubleshooting

### Database Open Failed

**Cause:** Incorrect database file path or file does not exist

**Solution:**
```objective-c
BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:dbPath];
if (!exists) {
    NSLog(@"Database file not found: %@", dbPath);
}
```

### Translation Returns Error

**Cause:** Network connection issues or API limitations

**Solutions:**
- Check network connection status
- Verify device can access Bing Translator service
- Avoid excessive API calls

### Query Returns Empty Result

**Cause:** Character not found in database

**Solutions:**
- Verify input is a valid Chinese character
- Ensure database content is complete
- Handle nil results appropriately

## Contributing

Contributions are welcome! We appreciate your interest in improving LWWordConverter.

### How to Contribute

1. **Fork the Repository**: Create your own fork of the project
2. **Create a Branch**: Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. **Make Changes**: Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. **Push to Branch**: Push to your branch (`git push origin feature/AmazingFeature`)
5. **Open a Pull Request**: Submit a pull request for review

### Reporting Issues

If you have any questions or suggestions, please contact:

1. Submit a [GitHub Issue](https://github.com/luowei/LWWordConverter/issues)
2. Email [luowei@wodedata.com](mailto:luowei@wodedata.com)

## Changelog

### v1.0.0 - Initial Release
- Support for Pinyin, Wubi, and stroke order queries
- Bing Translator API integration for multi-language translation
- Text encryption/decryption with steganographic display
- SQLCipher encrypted database support
- Asynchronous query processing
- Network status monitoring for translation requests

## Author

**luowei** - [luowei@wodedata.com](mailto:luowei@wodedata.com)

## Links

- [GitHub Repository](https://github.com/luowei/LWWordConverter)
- [CocoaPods](https://cocoapods.org/pods/LWWordConverter)
- [Issue Tracker](https://github.com/luowei/LWWordConverter/issues)

## Acknowledgments

Special thanks to the following open source projects that made this library possible:

- [SQLCipher](https://github.com/sqlcipher/sqlcipher) - Providing robust database encryption support
- [LWReachabilityManager](https://github.com/luowei/LWReachabilityManager) - Enabling reliable network status monitoring

## License

LWWordConverter is available under the MIT license. See the LICENSE file for more info.

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

---

## Support

If you find LWWordConverter helpful, please consider:

- Starring the repository on GitHub
- Reporting issues or suggesting improvements
- Contributing code or documentation
- Sharing with other developers

## Disclaimer

This project is provided for educational and research purposes. When using this library:

- Comply with all applicable laws and regulations
- Respect Bing Translator API terms of service
- Use encryption features responsibly
- Ensure you have rights to any database content you use

The authors are not responsible for any misuse of this library.

---

**Made with care by [luowei](https://github.com/luowei)** | **Copyright (c) 2019** | **Licensed under MIT**
