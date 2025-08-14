//
//  Untitled.swift
//  Assignment
//
//  Created by Nabeel on 8/14/25.
//

import Foundation
import Network
import Combine

final class NetworkMonitor: ObservableObject {
    @Published private(set) var isOnline: Bool = true

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "net.monitor")

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async { self?.isOnline = (path.status == .satisfied) }
        }
        monitor.start(queue: queue)
    }
}
