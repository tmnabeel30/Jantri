//
//  Untitled.swift
//  Assignment
//
//  Created by Nabeel on 8/14/25.
//

import Foundation

actor ColorRepository {
    private var items: [ColorItem]
    private let store: LocalStore
    private let cloud: CloudSyncing

    init(store: LocalStore, cloud: CloudSyncing) {
        self.store = store
        self.cloud = cloud
        self.items = (try? store.load()) ?? []
    }

    func all() -> [ColorItem] { items }

    func createRandom() throws -> ColorItem {
        let hex = Self.randomHex()
        let item = ColorItem(id: UUID().uuidString, hex: hex, createdAt: Date(), isSynced: false)
        items.insert(item, at: 0)
        try store.save(items)
        return item
    }

    func delete(id: String) throws {
        items.removeAll { $0.id == id }
        try store.save(items)
    }

    func syncIfNeeded(online: Bool) async throws -> Set<String> {
        guard online else { return [] }
        let pending = items.filter { !$0.isSynced }
        guard !pending.isEmpty else { return [] }
        let syncedIDs = try await cloud.sync(unsynced: pending)
        if !syncedIDs.isEmpty {
            items = items.map { var x = $0; if syncedIDs.contains(x.id) { x.isSynced = true }; return x }
            try store.save(items)
        }
        return syncedIDs
    }

    private static func randomHex() -> String {
        let r = Int.random(in: 0...255)
        let g = Int.random(in: 0...255)
        let b = Int.random(in: 0...255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
