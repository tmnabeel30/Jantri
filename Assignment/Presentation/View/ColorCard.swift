//
//  ColorCard.swift
//  Assignment
//
//  Created by Nabeel on 8/14/25.
//
import SwiftUI

struct ColorCard: View {
    let item: ColorItem
    var onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Rectangle()
                .fill(Color(hex: item.hex) ?? .gray.opacity(0.4))
                .frame(height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            HStack {
                Text(item.hex).font(.headline)
                Spacer(minLength: 6)
                if item.isSynced {
                    Label("Synced", systemImage: "checkmark.seal.fill")
                        .labelStyle(.titleAndIcon)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Label("Pending", systemImage: "clock")
                        .labelStyle(.titleAndIcon)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Text(item.createdAt, format: .dateTime.day().month().year().hour().minute())
                .font(.caption2)
                .foregroundStyle(.secondary)

            Button(role: .destructive, action: onDelete) {
                Text("Delete").frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .font(.caption)
        }
        .padding(10)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
