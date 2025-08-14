//
//  CloudSyncService.swift
//  Assignment
//
//  Created by Nabeel on 8/14/25.
//

import Foundation
import FirebaseFirestore

protocol CloudSyncing {
    /// Upserts unsynced items; returns IDs that were successfully synced.
    func sync(unsynced: [ColorItem]) async throws -> Set<String>
}

struct FirestoreCloudSyncService: CloudSyncing {
    func sync(unsynced: [ColorItem]) async throws -> Set<String> {
        guard !unsynced.isEmpty else { return [] }

        let db = Firestore.firestore()
        let batch = db.batch()
        let col = db.collection("colors")

        for item in unsynced {
            batch.setData([
                "hex": item.hex,
                "createdAt": Timestamp(date: item.createdAt)
            ], forDocument: col.document(item.id), merge: true)
        }

        try await commit(batch: batch)
        return Set(unsynced.map { $0.id })
    }

    private func commit(batch: WriteBatch) async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            batch.commit { error in
                if let error = error {
                    cont.resume(throwing: error)
                } else {
                    cont.resume(returning: ())
                }
            }
        }
    }
}
