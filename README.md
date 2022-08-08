# LWWordConverter

[![CI Status](https://img.shields.io/travis/luowei/LWWordConverter.svg?style=flat)](https://travis-ci.org/luowei/LWWordConverter)
[![Version](https://img.shields.io/cocoapods/v/LWWordConverter.svg?style=flat)](https://cocoapods.org/pods/LWWordConverter)
[![License](https://img.shields.io/cocoapods/l/LWWordConverter.svg?style=flat)](https://cocoapods.org/pods/LWWordConverter)
[![Platform](https://img.shields.io/cocoapods/p/LWWordConverter.svg?style=flat)](https://cocoapods.org/pods/LWWordConverter)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.


### LWConverterService

```Objective-C
self.converterService = [LWConverterService serviceWithDBPath:dbPath bihuaDBPath:bihuaDBPath];


//查询拼音,五笔(异步)
[self.converterService queryWithZi:zi updateUIBlock:^(NSString *pinyin, NSString *wubi) {
    if(!pinyin){
        pinyin = @"";
    }
    pinyinText = [NSString stringWithFormat:@"%@ %@", pinyinText, pinyin];

    if(!wubi){
        wubi = @"";
    }
    wubiText = [NSString stringWithFormat:@"%@  %@", wubiText, wubi];

}];

//查询笔顺(异步)
[self.converterService queryBiShunWithZi:zi updateUIBlock:^(NSString *bishun) {
    if(!bishun){
        bishun = @"";
    }
    bishunText = [NSString stringWithFormat:@"%@    %@", bishunText, bishun];

}];


//翻译
__weak typeof(self) weakSelf = self;
[self.converterService fanyiZi:self.sourceText to:self.translateLanguage updateUIBlock:^(NSString *translation, BOOL isError) {
    if (isError) {   
    	//todo: handle error

    } else {
        //todo: set translation
    }
}];

```

```Objective-C
if([inputText isEqualToString:@""] || [LWEncryptService isEncryptString:inputText]){
    //decrypt text from paste
    NSString *pasteText = [UIPasteboard myPasteboard].string;
    if([LWEncryptService isEncryptString:pasteText]){
        NSString *decryptText = [LWEncryptService decryptText:text]
        //todo: print decryptText
    }

}else{  // encrypt text
    NSArray *array = [LWEncryptService getShortcut];
    NSUInteger index = arc4random() % array.count;

    NSString *encryptText = [LWEncryptService encryptText:inputText displayText:array[index]];
    //todo: print encryptText
}

```


## Requirements

## Installation

LWWordConverter is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'LWWordConverter'
```

## Author

luowei, luowei@wodedata.com

## License

LWWordConverter is available under the MIT license. See the LICENSE file for more info.
