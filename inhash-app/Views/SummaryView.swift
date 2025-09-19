import SwiftUI

struct SummaryView: View {
    var body: some View {
        VStack { Spacer(); Image(systemName: "text.badge.plus").font(.largeTitle).padding(.bottom, 8); Text("요약 기능은 곧 제공될 예정입니다.").font(.title3).foregroundColor(.secondary); Spacer() }
            .padding()
            .navigationTitle("요약")
    }
}


