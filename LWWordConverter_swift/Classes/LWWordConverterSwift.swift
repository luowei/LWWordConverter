//
// LWWordConverterSwift.swift
// LWWordConverter Swift Module
// Created by luowei on 2017/3/28.
// Copyright (c) 2017 luowei. All rights reserved.
//

import Foundation

// MARK: - Module Info

/// LWWordConverter Swift版本
/// 文字转换器，包括五笔与拼音的编码转换，翻译以及文本加密。
public struct LWWordConverterSwift {

    /// 库版本号
    public static let version = "1.0.0"

    /// 库名称
    public static let name = "LWWordConverter"

    /// 获取库信息
    public static func info() -> String {
        return "\(name) v\(version) - Swift/SwiftUI Edition"
    }
}

// MARK: - Public Exports

// Re-export main classes for convenient importing
public typealias ConverterService = LWConverterService
public typealias EncryptService = LWEncryptService
public typealias NetworkReachability = LWNetworkReachabilityManager
public typealias ReachabilityStatus = LWNetworkReachabilityStatus
