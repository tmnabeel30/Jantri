//
//  LocalStore.swift
//  Assignment
//
//  Created by Nabeel on 8/14/25.
//

import Foundation

protocol LocalStore {
    func load() throws -> [ColorItem]
    func save(_ items: [ColorItem]) throws
}

struct JSONLocalStore: LocalStore {
    private let fileURL: URL
    private let enc: JSONEncoder
    private let dec: JSONDecoder

    init(filename: String = "colors.json") {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.fileURL = docs.appendingPathComponent(filename)
        self.enc = JSONEncoder()
        self.dec = JSONDecoder()
        enc.outputFormatting = [.prettyPrinted, .sortedKeys]
        enc.dateEncodingStrategy = .iso8601
        dec.dateDecodingStrategy = .iso8601
    }

    func load() throws -> [ColorItem] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return [] }
        let data = try Data(contentsOf: fileURL)
        return try dec.decode([ColorItem].self, from: data)
    }

    func save(_ items: [ColorItem]) throws {
        let data = try enc.encode(items)
        try data.write(to: fileURL, options: .atomic)
    }
}
