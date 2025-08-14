//
//  Untitled.swift
//  Assignment
//
//  Created by Nabeel on 8/14/25.
//

import Foundation
import Combine

@MainActor
final class ColorListViewModel: ObservableObject {
    @Published private(set) var items: [ColorItem] = []
    @Published private(set) var isOnline: Bool = true
    @Published var isSyncing: Bool = false
    @Published var lastSyncError: String?

    private let repo: ColorRepository
    private let net: NetworkMonitor
    private var bag = Set<AnyCancellable>()

    init(repo: ColorRepository, net: NetworkMonitor) {
        self.repo = repo
        self.net = net

        // Initial load
        Task { [weak self] in self?.items = await repo.all() }

        // React to connectivity
        net.$isOnline
            .receive(on: DispatchQueue.main)
            .sink { [weak self] online in
                guard let self = self else { return }
                self.isOnline = online
                Task { await self.syncIfNeeded() }
            }
            .store(in: &bag)
    }

    func generateColor() {
        Task { [weak self] in
            guard let self = self else { return }
            do {
                _ = try await repo.createRandom()
                self.items = await repo.all()
            } catch { self.lastSyncError = error.localizedDescription }
        }
    }

    func delete(_ item: ColorItem) {
        Task { [weak self] in
            guard let self = self else { return }
            do {
                try await repo.delete(id: item.id)
                self.items = await repo.all()
            } catch { self.lastSyncError = error.localizedDescription }
        }
    }

    func syncNow() { Task { await syncIfNeeded() } }

    private func syncIfNeeded() async {
        guard !isSyncing else { return }
        isSyncing = true; defer { isSyncing = false }
        do {
            _ = try await repo.syncIfNeeded(online: isOnline)
            items = await repo.all()
            lastSyncError = nil
        } catch { lastSyncError = error.localizedDescription }
    }
}
