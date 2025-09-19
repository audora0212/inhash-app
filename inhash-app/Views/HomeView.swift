import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: ScheduleStore
    @State private var selectedTypes: Set<ScheduleType> = Set(ScheduleType.allCases)
    
    var filteredItems: [ScheduleItem] {
        store.items.filter { selectedTypes.contains($0.type) }.sorted { $0.due < $1.due }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(ScheduleType.allCases) { type in
                            FilterChip(label: type.title, systemImage: type.icon, isOn: selectedTypes.contains(type)) {
                                if selectedTypes.contains(type) { selectedTypes.remove(type) } else { selectedTypes.insert(type) }
                            }
                        }
                    }.padding(.horizontal)
                }
                List(filteredItems) { item in ScheduleRow(item: item) }
                    .listStyle(.plain)
            }
            .navigationTitle("임박 일정")
        }
    }
}

struct FilterChip: View {
    let label: String; let systemImage: String; let isOn: Bool; let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) { Image(systemName: systemImage).font(.footnote); Text(label).font(.subheadline) }
                .padding(.vertical, 6).padding(.horizontal, 10)
                .background(isOn ? Color.accentColor.opacity(0.2) : Color.gray.opacity(0.15))
                .foregroundColor(isOn ? .accentColor : .primary)
                .clipShape(Capsule())
        }.buttonStyle(.plain)
    }
}

struct ScheduleRow: View {
    let item: ScheduleItem
    var remainingText: String {
        let now = Date(); let diff = item.due.timeIntervalSince(now)
        if diff <= 0 { return "기한 지남" }
        let hours = Int(diff/3600); if hours < 24 { return "D-0 · \(hours)시간 남음" }
        let days = Int(diff/86400); return "D-\(days)"
    }
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.type.icon).foregroundColor(item.type == .assignment ? .blue : .green).frame(width: 28)
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title).font(.headline)
                Text(item.course).font(.subheadline).foregroundColor(.secondary)
                Text(remainingText).font(.caption).foregroundColor(.secondary)
            }
            Spacer()
            Text(item.due, style: .date).font(.footnote).foregroundColor(.secondary)
        }.padding(.vertical, 6)
    }
}


