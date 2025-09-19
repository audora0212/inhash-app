import SwiftUI

struct SettingsView: View {
    @AppStorage("notifyAssignments") private var notifyAssignments: Bool = true
    @AppStorage("notifyLectures") private var notifyLectures: Bool = true
    @AppStorage("ddayOption") private var ddayOption: Int = 1
    let ddayOptions: [Int] = [3, 2, 1]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("알림 설정")) {
                    Toggle("과제 알림", isOn: $notifyAssignments)
                    Toggle("수업 알림", isOn: $notifyLectures)
                    Picker("사전 알림(D-일)", selection: $ddayOption) { ForEach(ddayOptions, id: \.self) { d in Text("D-\(d)").tag(d) } }
                }
                Section(header: Text("계정")) {
                    Button(role: .none) { } label: { Label("LMS 계정 재연결", systemImage: "arrow.triangle.2.circlepath") }
                    Button(role: .destructive) { } label: { Label("로그아웃", systemImage: "rectangle.portrait.and.arrow.forward") }
                }
            }.navigationTitle("설정")
        }
    }
}


