//
// LWWordConverterView.swift
// Created by luowei on 2017/3/28.
// Copyright (c) 2017 luowei. All rights reserved.
//

import SwiftUI

// MARK: - Word Converter View

@available(iOS 13.0, *)
public struct LWWordConverterView: View {

    // MARK: - Properties

    @State private var inputText: String = ""
    @State private var pinyinResult: String = ""
    @State private var wubiResult: String = ""
    @State private var bishunResult: String = ""
    @State private var translationResult: String = ""
    @State private var encryptedText: String = ""
    @State private var decryptedText: String = ""
    @State private var displayText: String = "再见"

    private let converterService: LWConverterService?

    // MARK: - Initialization

    public init(dbPath: String, bihuaDBPath: String) {
        self.converterService = LWConverterService.service(withDBPath: dbPath, bihuaDBPath: bihuaDBPath)
    }

    // MARK: - Body

    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {

                    // Input Section
                    inputSection

                    // Pinyin & Wubi Section
                    querySection

                    // Stroke Order Section
                    strokeOrderSection

                    // Translation Section
                    translationSection

                    // Encryption Section
                    encryptionSection

                    // Decryption Section
                    decryptionSection

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("LWWordConverter")
        }
    }

    // MARK: - View Components

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("输入文字")
                .font(.headline)

            TextField("请输入文字", text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
        }
    }

    private var querySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("拼音与五笔查询")
                .font(.headline)

            Button("查询拼音和五笔") {
                queryPinyinAndWubi()
            }
            .buttonStyle(.borderedProminent)

            if !pinyinResult.isEmpty {
                HStack {
                    Text("拼音:")
                        .fontWeight(.medium)
                    Text(pinyinResult)
                        .foregroundColor(.blue)
                }
            }

            if !wubiResult.isEmpty {
                HStack {
                    Text("五笔:")
                        .fontWeight(.medium)
                    Text(wubiResult)
                        .foregroundColor(.green)
                }
            }
        }
    }

    private var strokeOrderSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("笔顺查询")
                .font(.headline)

            Button("查询笔顺") {
                queryBishun()
            }
            .buttonStyle(.borderedProminent)

            if !bishunResult.isEmpty {
                HStack {
                    Text("笔顺:")
                        .fontWeight(.medium)
                    Text(bishunResult)
                        .font(.title2)
                        .foregroundColor(.orange)
                }
            }
        }
    }

    private var translationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("翻译")
                .font(.headline)

            Button("翻译成英文") {
                translateToEnglish()
            }
            .buttonStyle(.borderedProminent)

            if !translationResult.isEmpty {
                HStack {
                    Text("翻译:")
                        .fontWeight(.medium)
                    Text(translationResult)
                        .foregroundColor(.purple)
                }
            }
        }
    }

    private var encryptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("文本加密")
                .font(.headline)

            TextField("显示文本 (默认: 再见)", text: $displayText)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button("加密文本") {
                encryptText()
            }
            .buttonStyle(.borderedProminent)

            if !encryptedText.isEmpty {
                VStack(alignment: .leading) {
                    Text("加密结果:")
                        .fontWeight(.medium)
                    Text(encryptedText)
                        .font(.caption)
                        .foregroundColor(.red)
                        .textSelection(.enabled)
                }
            }
        }
    }

    private var decryptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("文本解密")
                .font(.headline)

            Button("解密文本") {
                decryptText()
            }
            .buttonStyle(.borderedProminent)

            if !decryptedText.isEmpty {
                HStack {
                    Text("解密结果:")
                        .fontWeight(.medium)
                    Text(decryptedText)
                        .foregroundColor(.teal)
                }
            }
        }
    }

    // MARK: - Actions

    private func queryPinyinAndWubi() {
        guard !inputText.isEmpty else { return }

        converterService?.query(withZi: inputText) { pinyin, wubi in
            self.pinyinResult = pinyin ?? "未找到"
            self.wubiResult = wubi ?? "未找到"
        }
    }

    private func queryBishun() {
        guard !inputText.isEmpty else { return }

        converterService?.queryBiShun(withZi: inputText) { bishun in
            self.bishunResult = bishun.isEmpty ? "未找到" : bishun
        }
    }

    private func translateToEnglish() {
        guard !inputText.isEmpty else { return }

        converterService?.fanyiZi(inputText, to: "en") { text, isError in
            self.translationResult = text
        }
    }

    private func encryptText() {
        guard !inputText.isEmpty else { return }

        if let encrypted = LWEncryptService.encryptText(inputText, displayText: displayText) {
            self.encryptedText = encrypted
        }
    }

    private func decryptText() {
        guard !encryptedText.isEmpty else { return }

        if let decrypted = LWEncryptService.decryptText(encryptedText) {
            self.decryptedText = decrypted
        }
    }
}

// MARK: - Preview

@available(iOS 13.0, *)
struct LWWordConverterView_Previews: PreviewProvider {
    static var previews: some View {
        LWWordConverterView(
            dbPath: "/path/to/zidian.dat",
            bihuaDBPath: "/path/to/bhwords.dat"
        )
    }
}
