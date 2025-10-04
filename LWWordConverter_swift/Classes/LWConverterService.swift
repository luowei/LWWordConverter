//
// LWConverterService.swift
// Created by luowei on 2017/3/28.
// Copyright (c) 2017 luowei. All rights reserved.
//

import Foundation
import SQLite3
import CommonCrypto

public class LWConverterService {

    // MARK: - Properties

    public var networkReachabilityStatus: Int = 0
    public var toLanguage: String = "en"
    public let dbPath: String
    public let bihuaDBPath: String

    private var dbSqlite: OpaquePointer?
    private var dbBihuaSqlite: OpaquePointer?

    // MARK: - Constants

    private static let fanyiURLString = "https://cn.bing.com/ttranslatev3"
    private static let dbPassword = "luowei.wodedata.com"

    // MARK: - Initialization

    public static func service(withDBPath dbPath: String, bihuaDBPath: String) -> LWConverterService? {
        let fileManager = FileManager.default

        guard fileManager.fileExists(atPath: dbPath),
              fileManager.fileExists(atPath: bihuaDBPath) else {
            return nil
        }

        return LWConverterService(dbPath: dbPath, bihuaDBPath: bihuaDBPath)
    }

    private init(dbPath: String, bihuaDBPath: String) {
        self.dbPath = dbPath
        self.bihuaDBPath = bihuaDBPath

        // Open databases
        _ = openDatabase()
        _ = openBihuaDatabase()

        // Monitor network status
        LWNetworkReachabilityManager.shared.setReachabilityStatusChangeBlock { [weak self] status in
            self?.networkReachabilityStatus = status.rawValue
        }
        LWNetworkReachabilityManager.shared.startMonitoring()
    }

    deinit {
        if let db = dbSqlite {
            sqlite3_close(db)
        }
        if let bihuaDb = dbBihuaSqlite {
            sqlite3_close(bihuaDb)
        }
    }

    // MARK: - Database Operations

    private func openDatabase() -> Bool {
        let result = sqlite3_open(dbPath, &dbSqlite)

        guard result == SQLITE_OK else {
            print("Failed to open Zidian DB: \(result)")
            if let db = dbSqlite {
                sqlite3_close(db)
            }
            return false
        }

        // Verify password
        let key = Self.dbPassword
        sqlite3_key(dbSqlite, key, Int32(key.count))

        let res = sqlite3_exec(dbSqlite, "SELECT count(*) FROM sqlite_master;", nil, nil, nil)
        if res == SQLITE_OK {
            print("Password is correct, or database has been initialized")
            return true
        } else {
            print("Incorrect password! errCode: \(res)")
            return false
        }
    }

    private func openBihuaDatabase() -> Bool {
        let result = sqlite3_open(bihuaDBPath, &dbBihuaSqlite)

        guard result == SQLITE_OK else {
            print("Failed to open BihuaWords DB: \(result)")
            if let db = dbBihuaSqlite {
                sqlite3_close(db)
            }
            return false
        }

        // Verify password
        let key = Self.dbPassword
        sqlite3_key(dbBihuaSqlite, key, Int32(key.count))

        let res = sqlite3_exec(dbBihuaSqlite, "SELECT count(*) FROM sqlite_master;", nil, nil, nil)
        if res == SQLITE_OK {
            print("Password is correct, or database has been initialized")
            return true
        } else {
            print("Incorrect password! errCode: \(res)")
            return false
        }
    }

    // MARK: - Query Methods

    public func query(withZi zi: String, updateUIBlock: @escaping (String?, String?) -> Void) {
        let dict = queryInternal(withZi: zi)
        let pinyin = dict["pinyin"]
        let wubi = dict["wubi"]
        updateUIBlock(pinyin, wubi)
    }

    private func queryInternal(withZi zi: String) -> [String: String] {
        var convertDict: [String: String] = [:]

        let param = zi.replacingOccurrences(of: "'", with: "''")
        let sqlQuery = "SELECT pinyin,wubi FROM zidian where zi = '\(param)' LIMIT 1"

        var statement: OpaquePointer?

        if sqlite3_prepare_v2(dbSqlite, sqlQuery, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                if let pinyinCString = sqlite3_column_text(statement, 0),
                   let wubiCString = sqlite3_column_text(statement, 1) {
                    let pinyinStr = String(cString: pinyinCString)
                    let wubiStr = String(cString: wubiCString)

                    let pinyinTrimText = pinyinStr.trimmingCharacters(in: .whitespacesAndNewlines)

                    // Remove # symbols using regex
                    let pattern = "^(#)([\\w\\W]*)(#)$"
                    if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                        let range = NSRange(pinyinTrimText.startIndex..., in: pinyinTrimText)
                        let pinyin = regex.stringByReplacingMatches(
                            in: pinyinTrimText,
                            options: [],
                            range: range,
                            withTemplate: "$2"
                        )
                        convertDict["pinyin"] = pinyin
                    }

                    convertDict["wubi"] = wubiStr
                }
            }
            sqlite3_finalize(statement)
        }

        return convertDict
    }

    public func queryBiShun(withZi zi: String, updateUIBlock: @escaping (String) -> Void) {
        let bishun = queryBiShunInternal(withZi: zi)
        updateUIBlock(bishun)
    }

    private func queryBiShunInternal(withZi zi: String) -> String {
        let param = zi.replacingOccurrences(of: "'", with: "''")
        let sqlQuery = "SELECT code FROM words_bihua_full where words = '\(param)' LIMIT 1"

        var statement: OpaquePointer?
        var code = ""

        if sqlite3_prepare_v2(dbBihuaSqlite, sqlQuery, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                if let codeCString = sqlite3_column_text(statement, 0) {
                    code = String(cString: codeCString)
                }
            }
            sqlite3_finalize(statement)
        }

        var bishun = ""
        for character in code {
            switch character {
            case "1":
                bishun += "一"
            case "2":
                bishun += "｜"
            case "3":
                bishun += "ノ"
            case "4":
                bishun += "、"
            case "5":
                bishun += "ㄥ"
            case "_":
                bishun += "*"
            default:
                break
            }
        }

        return bishun
    }

    // MARK: - Translation

    public func fanyiZi(_ zi: String, to: String?, updateUIBlock: @escaping (String, Bool) -> Void) {
        if let to = to, !to.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.toLanguage = to
        }

        // Check network
        if networkReachabilityStatus == LWNetworkReachabilityStatus.notReachable.rawValue {
            updateUIBlock("网络连接错误", true)
            return
        }

        let headers = [
            "Content-Type": "application/x-www-form-urlencoding; charset=UTF-8",
            "Referer": "https://cn.bing.com/translator/",
            "User-Agent": Self.userAgent(),
            "Origin": "https://cn.bing.com"
        ]

        guard let url = URL(string: Self.fanyiURLString) else {
            updateUIBlock("URL错误", true)
            return
        }

        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 60.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers

        let bodyText = "fromLang=auto-detect&text=\(zi)&to=\(toLanguage)"
        request.httpBody = bodyText.data(using: .utf8)

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                var translation = "数据处理异常"
                var isError = true

                if error == nil, let data = data {
                    do {
                        if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]],
                           let firstItem = jsonArray.first,
                           let translations = firstItem["translations"] as? [[String: Any]],
                           let firstTranslation = translations.first,
                           let text = firstTranslation["text"] as? String {
                            translation = text
                            isError = false
                        } else {
                            translation = "服务异常"
                        }
                    } catch {
                        translation = "数据处理异常"
                    }
                }

                updateUIBlock(translation, isError)
            }
        }
        dataTask.resume()
    }

    // MARK: - Helper Methods

    private static func userAgent() -> String {
        let uaList = [
            "Mozilla/5.0 (Windows NT 6.1; rv:67.0) Gecko/20100101 Firefox/67.0",
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:68.0) Gecko/20100101 Firefox/68.0",
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:66.0) Gecko/20100101 Firefox/66.0",
            "Mozilla/5.0 (Android 8.1.0; Mobile; rv:66.0) Gecko/66.0 Firefox/66.0",
            "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3724.8 Safari/537.36",
            "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.142 Safari/537.36",
            "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36",
            "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.86 Safari/537.36",
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.142 Safari/537.36",
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.61 Safari/537.36",
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3788.1 Safari/537.36",
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_5) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.1.1 Safari/605.1.15",
            "Mozilla/5.0 (Windows NT 6.1; Trident/7.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; .NET4.0C; .NET4.0E; rv:11.0) like Gecko",
            "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.103 Safari/537.36 OPR/60.0.3255.95",
            "Mozilla/5.0 (iPod; U; CPU iPhone OS 2_1 like Mac OS X; ja-jp) AppleWebKit/525.18.1 (KHTML, like Gecko) Version/3.1.1 Mobile/5F137 Safari/525.20",
            "Mozilla/5.0 (Linux; Android 7.0; VTR-AL00 Build/HUAWEIVTR-AL00; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/66.0.3359.126 MQQBrowser/6.2 TBS/044705 Mobile Safari/537.36 MMWEBID/9843 MicroMessenger/7.0.5.1440(0x27000537) Process/tools NetType/4G Language/zh_CN",
            "Mozilla/5.0 (iPhone; CPU iPhone OS 12_3_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 MicroMessenger/7.0.4(0x17000428) NetType/4G Language/zh_CN",
            "Mozilla/5.0 (iPhone; CPU iPhone OS 12_3_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 QQ/8.0.8.458 V1_IPH_SQ_8.0.8_1_APP_A Pixel/750 Core/WKWebView Device/Apple(iPhone 8) NetType/WIFI QBWebViewType/1 WKType/1"
        ]

        let index = Int.random(in: 0..<uaList.count)
        return uaList[index]
    }
}
