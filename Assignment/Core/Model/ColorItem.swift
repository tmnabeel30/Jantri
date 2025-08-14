//
//  Untitled.swift
//  Assignment
//
//  Created by Nabeel on 8/14/25.
//

import Foundation

struct ColorItem: Identifiable, Codable, Hashable {
    var id: String            // UUID string
    var hex: String           // "#RRGGBB"
    var createdAt: Date
    var isSynced: Bool
}
