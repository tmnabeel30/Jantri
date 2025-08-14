//
//  ColorSyncApp.swift.swift
//  Assignment
//
//  Created by Nabeel on 8/14/25.
//

import SwiftUI
import FirebaseCore

@main
struct ColorSyncApp: App {
    @StateObject private var vm: ColorListViewModel
    private let container: AppContainer

    init() {
        FirebaseApp.configure()

        let c = AppContainer()
        _vm = StateObject(wrappedValue: ColorListViewModel(repo: c.repository, net: c.network))
        self.container = c
    }

    var body: some Scene {
        WindowGroup {
            ColorListView()
                .environmentObject(vm)
        }
    }
}

// Simple DI container
final class AppContainer {
    let network = NetworkMonitor()
    let repository: ColorRepository

    init() {
        let store: LocalStore = JSONLocalStore()
        let cloud: CloudSyncing = FirestoreCloudSyncService()
        repository = ColorRepository(store: store, cloud: cloud)
    }
}
