import SwiftUI

struct ColorListView: View {
    @EnvironmentObject var vm: ColorListViewModel
    @State private var columns = [GridItem(.adaptive(minimum: 120), spacing: 12)]

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                HStack {
                    connectivityPill
                    Spacer()
                    Button(action: { vm.syncNow() }) {
                        HStack(spacing: 6) {
                            if vm.isSyncing { ProgressView() }
                            Text("Sync now")
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(!vm.isOnline)
                }

                Button(action: vm.generateColor) {
                    Text("Generate Color")
                        .fontWeight(.semibold)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                if let err = vm.lastSyncError {
                    Text("\(err)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(vm.items) { item in
                            ColorCard(item: item) { vm.delete(item) }
                        }
                    }
                    .padding(.top, 4)
                }
            }
            .padding(16)
            .navigationTitle("Color Cards")
        }
    }

    private var connectivityPill: some View {
        HStack(spacing: 8) {
            Circle().frame(width: 10, height: 10).foregroundStyle(vm.isOnline ? .green : .red)
            Text(vm.isOnline ? "Online" : "Offline").font(.subheadline).foregroundStyle(.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.thinMaterial)
        .clipShape(Capsule())
    }
}
