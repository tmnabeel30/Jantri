//
//  Untitled.swift
//  Assignment
//
//  Created by Nabeel on 8/14/25.
//

import SwiftUI

public extension Color {
    init?(hex: String) {
        let raw = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard raw.hasPrefix("#"), raw.count == 7,
              let r = Int(raw.dropFirst().prefix(2), radix: 16),
              let g = Int(raw.dropFirst(3).prefix(2), radix: 16),
              let b = Int(raw.dropFirst(5).prefix(2), radix: 16)
        else { return nil }
        self = Color(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: 1)
    }
}
