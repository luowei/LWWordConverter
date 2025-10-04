//
// LWNetworkReachabilityManager.swift
// Created by luowei on 2017/3/28.
// Copyright (c) 2017 luowei. All rights reserved.
//

import Foundation
import Network

// MARK: - Network Reachability Status

public enum LWNetworkReachabilityStatus: Int {
    case unknown = -1
    case notReachable = 0
    case reachableViaWiFi = 1
    case reachableViaWWAN = 2
}

// MARK: - Network Reachability Manager

public class LWNetworkReachabilityManager {

    // MARK: - Singleton

    public static let shared = LWNetworkReachabilityManager()

    // MARK: - Properties

    private var monitor: NWPathMonitor?
    private var queue: DispatchQueue
    private var statusChangeBlock: ((LWNetworkReachabilityStatus) -> Void)?

    public private(set) var currentStatus: LWNetworkReachabilityStatus = .unknown

    // MARK: - Initialization

    private init() {
        self.queue = DispatchQueue(label: "com.luowei.networkReachability")
    }

    // MARK: - Public Methods

    public func setReachabilityStatusChangeBlock(_ block: @escaping (LWNetworkReachabilityStatus) -> Void) {
        self.statusChangeBlock = block
    }

    public func startMonitoring() {
        guard monitor == nil else { return }

        monitor = NWPathMonitor()
        monitor?.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }

            let newStatus: LWNetworkReachabilityStatus

            switch path.status {
            case .satisfied:
                if path.usesInterfaceType(.wifi) {
                    newStatus = .reachableViaWiFi
                } else if path.usesInterfaceType(.cellular) {
                    newStatus = .reachableViaWWAN
                } else {
                    newStatus = .reachableViaWiFi // Default for other types (ethernet, etc.)
                }
            case .unsatisfied, .requiresConnection:
                newStatus = .notReachable
            @unknown default:
                newStatus = .unknown
            }

            if self.currentStatus != newStatus {
                self.currentStatus = newStatus
                DispatchQueue.main.async {
                    self.statusChangeBlock?(newStatus)
                }
            }
        }

        monitor?.start(queue: queue)
    }

    public func stopMonitoring() {
        monitor?.cancel()
        monitor = nil
    }

    deinit {
        stopMonitoring()
    }
}
