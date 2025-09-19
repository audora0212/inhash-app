import SwiftUI
import Combine

// MARK: - Models

enum ScheduleType: String, CaseIterable, Identifiable {
    case assignment
    case lecture
    
    var id: String { rawValue }
    var title: String {
        switch self {
        case .assignment: return "과제"
        case .lecture: return "수업"
        }
    }
    var icon: String {
        switch self {
        case .assignment: return "doc.text"
        case .lecture: return "play.rectangle"
        }
    }
}

struct ScheduleItem: Identifiable {
    let id = UUID()
    let type: ScheduleType
    let course: String
    let title: String
    let due: Date
}

final class ScheduleStore: ObservableObject {
    @Published var items: [ScheduleItem] = []
    
    init() {
        let now = Date()
        items = [
            ScheduleItem(type: .assignment, course: "객체지향프로그래밍", title: "1주차 실습과제", due: Calendar.current.date(byAdding: .hour, value: 10, to: now)!),
            ScheduleItem(type: .lecture, course: "생명과학", title: "1주차 1교시 동영상", due: Calendar.current.date(byAdding: .day, value: 1, to: now)!),
            ScheduleItem(type: .assignment, course: "객체지향프로그래밍", title: "2주차 실습과제", due: Calendar.current.date(byAdding: .day, value: 3, to: now)!),
            ScheduleItem(type: .lecture, course: "컴퓨터네트워크", title: "Chap1-1 동영상", due: Calendar.current.date(byAdding: .day, value: 4, to: now)!)
        ]
    }
}

// MARK: - Root

struct ContentView: View {
    @StateObject private var store = ScheduleStore()
    @StateObject private var auth = AuthStore()
    
    var body: some View {
        Group {
            if !auth.isAuthenticated {
                AuthFlowView()
            } else if !auth.isLmsLinked {
                LmsLinkView()
            } else {
                MainTabs()
            }
        }
        .environmentObject(store)
        .environmentObject(auth)
    }
}

struct MainTabs: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("홈", systemImage: "house") }
            CalendarView()
                .tabItem { Label("캘린더", systemImage: "calendar") }
            SummaryView()
                .tabItem { Label("요약", systemImage: "chart.bar") }
            SettingsView()
                .tabItem { Label("설정", systemImage: "gearshape") }
        }
    }
}

// MARK: - Auth Flow

struct AuthFlowView: View {
    @State private var isSignup = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                if isSignup {
                    SignupView()
                } else {
                    LoginView()
                }
                Button(isSignup ? "이미 계정이 있으신가요? 로그인" : "계정이 없으신가요? 회원가입") {
                    withAnimation { isSignup.toggle() }
                }
            }
            .padding()
            .navigationTitle(isSignup ? "회원가입" : "로그인")
        }
    }
}

struct LoginView: View {
    @EnvironmentObject private var auth: AuthStore
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var loading = false
    
    var body: some View {
        ZStack {
            // 배경 그라디언트
            AppBackground()
            
            VStack(spacing: 24) {
                // 로고 + 타이틀
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.purple.opacity(0.9), .blue.opacity(0.9)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 84, height: 84)
                            .shadow(color: .purple.opacity(0.25), radius: 18, x: 0, y: 10)
                        Text("IH")
                            .foregroundColor(.white)
                            .font(.system(size: 34, weight: .heavy, design: .rounded))
                            .kerning(2)
                    }
                    Text("INHASH")
                        .font(.system(size: 28, weight: .heavy))
                        .foregroundStyle(LinearGradient(colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing))
                    Text("인하대 스마트 과제 관리")
                        .font(.callout)
                        .foregroundColor(.secondary)
                }
                
                // 카드 컨테이너
                VStack(spacing: 14) {
                    IconTextField(systemImage: "envelope", placeholder: "이메일", text: $email, isSecure: .constant(false), showSecure: .constant(false))
                        .frame(height: 44)
                    IconTextField(systemImage: "lock", placeholder: "비밀번호", text: $password, isSecure: .constant(true), showSecure: $showPassword)
                        .frame(height: 44)
                    
                    Button(action: submit) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.blue, Color.purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: Color.black.opacity(0.12), radius: 16, x: 0, y: 8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.35), lineWidth: 1)
                                )
                            HStack(spacing: 8) {
                                if loading { ProgressView().tint(.white).scaleEffect(0.9) }
                                Text(loading ? "로그인 중..." : "로그인")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 8)
                        }
                        .frame(height: 48)
                    }
                    .buttonStyle(LightenOnPressStyle(cornerRadius: 12, overlayOpacity: 0.12))
                    .disabled(loading || email.isEmpty || password.isEmpty)
                    
                    KakaoButton {
                        // TODO: 카카오 로그인 훅 연결
                    }
                    .frame(height: 48)
                    
                    HStack {
                        Button("비밀번호 찾기") {}
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        Spacer()
                        Button("회원가입") {
                            NotificationCenter.default.post(name: NSNotification.Name("toggleSignup"), object: nil)
                        }
                        .font(.footnote)
                        .foregroundColor(.purple)
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.06), radius: 20, x: 0, y: 10)
                )
                .frame(maxWidth: 360)
                
                if let err = auth.errorMessage {
                    Text(err).foregroundColor(.red).font(.footnote)
                }
            }
            .padding(.horizontal, 16)
            .offset(y: -48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
    }
    
    private func submit() {
        loading = true
        Task {
            await auth.login(email: email, password: password)
            loading = false
        }
    }
}

struct IconTextField: View {
    let systemImage: String
    let placeholder: String
    @Binding var text: String
    @Binding var isSecure: Bool
    @Binding var showSecure: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemGray6))
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .foregroundColor(.secondary)
                if isSecure && !showSecure {
                    SecureField(placeholder, text: $text)
                        .textContentType(.password)
                } else {
                    TextField(placeholder, text: $text)
                        .textContentType(isSecure ? .password : .username)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .keyboardType(isSecure ? .default : .emailAddress)
                }
                if isSecure {
                    Button(action: { showSecure.toggle() }) {
                        Image(systemName: showSecure ? "eye.slash" : "eye")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
        }
    }
}

struct KakaoButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 1.0, green: 0.898, blue: 0.0))
                Text("카카오로 계속하기")
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding(.horizontal, 8)
            }
            .frame(height: 48)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(LightenOnPressStyle(cornerRadius: 12, overlayOpacity: 0.1))
    }
}

// MARK: - Background

struct AppBackground: View {
    var body: some View {
        ZStack {
            // 3색 그라디언트 베이스
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(red: 243/255, green: 246/255, blue: 250/255), location: 0.0),   // #F3F6FA (진하게)
                    .init(color: Color(red: 221/255, green: 227/255, blue: 235/255), location: 0.5),   // #DDE3EB (진하게)
                    .init(color: Color(red: 233/255, green: 238/255, blue: 245/255), location: 1.0)    // #E9EEF5 (진하게)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // 라디얼 글로우로 밝은 하이라이트
            RadialGradient(
                gradient: Gradient(colors: [Color.white.opacity(0.45), Color.white.opacity(0.0)]),
                center: .topLeading,
                startRadius: 0,
                endRadius: 420
            )
            .blendMode(.plusLighter)
            .ignoresSafeArea()
            
            RadialGradient(
                gradient: Gradient(colors: [Color.white.opacity(0.28), Color.white.opacity(0.0)]),
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 520
            )
            .blendMode(.plusLighter)
            .ignoresSafeArea()
            
            // 부드럽게 떠다니는 유리 구체 느낌의 오브들
            FloatingOrb(
                colors: [Color.blue.opacity(0.40), Color.purple.opacity(0.22)],
                size: 240,
                initialOffset: CGSize(width: -140, height: -100),
                finalOffset: CGSize(width: -100, height: -140),
                duration: 9.5,
                delay: 0
            )
            .blendMode(.plusLighter)
            
            FloatingOrb(
                colors: [Color.purple.opacity(0.30), Color.blue.opacity(0.18)],
                size: 280,
                initialOffset: CGSize(width: 120, height: 220),
                finalOffset: CGSize(width: 160, height: 200),
                duration: 10.5,
                delay: 0.8
            )
            .blendMode(.plusLighter)
            
            FloatingOrb(
                colors: [Color.blue.opacity(0.25), Color.purple.opacity(0.14)],
                size: 180,
                initialOffset: CGSize(width: -10, height: 260),
                finalOffset: CGSize(width: 20, height: 240),
                duration: 11.5,
                delay: 0.4
            )
            .blendMode(.plusLighter)
        }
        .allowsHitTesting(false)
    }
}

struct FloatingOrb: View {
    let colors: [Color]
    let size: CGFloat
    let initialOffset: CGSize
    let finalOffset: CGSize
    let duration: Double
    let delay: Double
    
    @State private var animate: Bool = false
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [colors.first ?? .blue, colors.dropFirst().first ?? .purple, .clear]),
                    center: .center,
                    startRadius: 0,
                    endRadius: size * 0.7
                )
            )
            .frame(width: size, height: size)
            .blur(radius: 24)
            .opacity(0.9)
            .offset(x: animate ? finalOffset.width : initialOffset.width,
                    y: animate ? finalOffset.height : initialOffset.height)
            .onAppear {
                withAnimation(.easeInOut(duration: duration).delay(delay).repeatForever(autoreverses: true)) {
                    animate = true
                }
            }
    }
}

struct LightenOnPressStyle: ButtonStyle {
    let cornerRadius: CGFloat
    let overlayOpacity: Double
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.white)
                    .opacity(configuration.isPressed ? overlayOpacity : 0)
            )
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct SignupView: View {
    @EnvironmentObject private var auth: AuthStore
    @State private var email = ""
    @State private var password = ""
    @State private var loading = false
    
    var body: some View {
        VStack(spacing: 12) {
            TextField("이메일", text: $email)
                .textContentType(.username)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding().background(Color.gray.opacity(0.1)).cornerRadius(8)
            SecureField("비밀번호", text: $password)
                .textContentType(.newPassword)
                .padding().background(Color.gray.opacity(0.1)).cornerRadius(8)
            
            Button(action: submit) {
                HStack {
                    if loading { ProgressView().progressViewStyle(.circular) }
                    Text("회원가입")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(loading || email.isEmpty || password.isEmpty)
            
            if let err = auth.errorMessage { Text(err).foregroundColor(.red).font(.footnote) }
        }
    }
    
    private func submit() {
        loading = true
        Task {
            await auth.signup(email: email, password: password)
            loading = false
        }
    }
}

// MARK: - LMS Link

struct LmsLinkView: View {
    @EnvironmentObject private var auth: AuthStore
    @State private var username = ""
    @State private var password = ""
    @State private var progress = 0
    @State private var loading = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("LMS 계정을 등록해 주세요")
                    .font(.headline)
                TextField("학번", text: $username)
                    .keyboardType(.numberPad)
                    .padding().background(Color.gray.opacity(0.1)).cornerRadius(8)
                SecureField("비밀번호", text: $password)
                    .padding().background(Color.gray.opacity(0.1)).cornerRadius(8)
                
                if loading || auth.isLinkingLMS {
                    ProgressView(value: Double(progress), total: 100)
                    Text("데이터 수집중 \(progress)%...")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                
                Button(action: submit) {
                    HStack {
                        if loading { ProgressView().progressViewStyle(.circular) }
                        Text("LMS 연동 및 수집 시작")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(loading || username.isEmpty || password.isEmpty)
                
                if let err = auth.errorMessage { Text(err).foregroundColor(.red).font(.footnote) }
                
                Spacer()
            }
            .padding()
            .navigationTitle("LMS 연동")
        }
    }
    
    private func submit() {
        loading = true
        Task {
            await auth.linkLms(username: username, password: password) { p in
                self.progress = p
            }
            loading = false
        }
    }
}

// MARK: - Home

struct HomeView: View {
    @EnvironmentObject private var store: ScheduleStore
    @State private var selectedTypes: Set<ScheduleType> = Set(ScheduleType.allCases)
    
    var filteredItems: [ScheduleItem] {
        store.items
            .filter { selectedTypes.contains($0.type) }
            .sorted { $0.due < $1.due }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(ScheduleType.allCases) { type in
                            FilterChip(
                                label: type.title,
                                systemImage: type.icon,
                                isOn: selectedTypes.contains(type)
                            ) {
                                if selectedTypes.contains(type) {
                                    selectedTypes.remove(type)
                                } else {
                                    selectedTypes.insert(type)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                List(filteredItems) { item in
                    ScheduleRow(item: item)
                }
                .listStyle(.plain)
            }
            .navigationTitle("임박 일정")
        }
    }
}

struct FilterChip: View {
    let label: String
    let systemImage: String
    let isOn: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.footnote)
                Text(label)
                    .font(.subheadline)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(isOn ? Color.accentColor.opacity(0.2) : Color.gray.opacity(0.15))
            .foregroundColor(isOn ? .accentColor : .primary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct ScheduleRow: View {
    let item: ScheduleItem
    
    var remainingText: String {
        let now = Date()
        let diff = item.due.timeIntervalSince(now)
        if diff <= 0 { return "기한 지남" }
        let hours = Int(diff / 3600)
        if hours < 24 { return "D-0 · \(hours)시간 남음" }
        let days = Int(diff / 86400)
        return "D-\(days)"
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.type.icon)
                .foregroundColor(item.type == .assignment ? .blue : .green)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                Text(item.course)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(remainingText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(item.due, style: .date)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Calendar

struct CalendarView: View {
    @EnvironmentObject private var store: ScheduleStore
    @State private var currentMonth: Date = Date()
    
    private var monthItems: [ScheduleItem] {
        store.items.filter { Calendar.current.isDate($0.due, equalTo: currentMonth, toGranularity: .month) }
    }
    
    private var weekItems: [ScheduleItem] {
        let cal = Calendar.current
        let startOfWeek = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        let endOfWeek = cal.date(byAdding: .day, value: 7, to: startOfWeek)!
        return store.items.filter { $0.due >= startOfWeek && $0.due < endOfWeek }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                HStack {
                    DatePicker("", selection: $currentMonth, displayedComponents: [.date])
                        .datePickerStyle(.compact)
                        .labelsHidden()
                    Spacer()
                    Button(action: { shiftMonth(-1) }) {
                        Image(systemName: "chevron.left")
                    }
                    Button(action: { shiftMonth(1) }) {
                        Image(systemName: "chevron.right")
                    }
                }
                .padding(.horizontal)
                
                CalendarGrid(month: currentMonth, dots: monthDots())
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("이번달 요약")
                        .font(.headline)
                    SummaryRow(title: "이번달 제출 과제", count: monthItems.filter { $0.type == .assignment }.count)
                    SummaryRow(title: "이번달 수강 수업", count: monthItems.filter { $0.type == .lecture }.count)
                    Divider()
                    Text("이번주 요약")
                        .font(.headline)
                    SummaryRow(title: "이번주 제출 과제", count: weekItems.filter { $0.type == .assignment }.count)
                    SummaryRow(title: "이번주 수강 수업", count: weekItems.filter { $0.type == .lecture }.count)
                }
                .padding(.horizontal)
                
                Spacer(minLength: 0)
            }
            .navigationTitle("캘린더")
        }
    }
    
    private func shiftMonth(_ delta: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: delta, to: currentMonth) {
            currentMonth = newDate
        }
    }
    
    private func monthDots() -> Set<Int> {
        let cal = Calendar.current
        var days = Set<Int>()
        for it in monthItems {
            let d = cal.component(.day, from: it.due)
            days.insert(d)
        }
        return days
    }
}

struct CalendarGrid: View {
    let month: Date
    let dots: Set<Int>
    
    private var days: [Int?] {
        let cal = Calendar.current
        let range = cal.range(of: .day, in: .month, for: month)!
        let first = cal.date(from: cal.dateComponents([.year, .month], from: month))!
        let firstWeekday = cal.component(.weekday, from: first)
        let leadingBlanks = (firstWeekday + 6) % 7
        let total = leadingBlanks + range.count
        var cells: [Int?] = Array(repeating: nil, count: leadingBlanks)
        cells += range.map { Optional($0) }
        let remainder = total % 7
        if remainder != 0 {
            cells += Array(repeating: nil, count: 7 - remainder)
        }
        return cells
    }
    
    var body: some View {
        VStack(spacing: 6) {
            HStack {
                ForEach(["일","월","화","수","목","금","토"], id: \.self) { d in
                    Text(d).font(.caption).frame(maxWidth: .infinity)
                }
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(0..<days.count, id: \.self) { idx in
                    let day = days[idx]
                    ZStack {
                        if let day = day {
                            let isToday = isToday(day: day, month: month)
                            Circle()
                                .fill(isToday ? Color.accentColor.opacity(0.15) : Color.clear)
                                .frame(width: 34, height: 34)
                            Text("\(day)")
                                .font(.subheadline)
                            if dots.contains(day) {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 6, height: 6)
                                    .offset(y: 12)
                            }
                        } else {
                            Text("")
                                .frame(height: 34)
                        }
                    }
                    .frame(height: 40)
                }
            }
        }
    }
    
    private func isToday(day: Int, month: Date) -> Bool {
        let cal = Calendar.current
        var comp = cal.dateComponents([.year, .month], from: month)
        comp.day = day
        guard let date = cal.date(from: comp) else { return false }
        return cal.isDateInToday(date)
    }
}

struct SummaryRow: View {
    let title: String
    let count: Int
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text("\(count)개")
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Summary (Placeholder)

struct SummaryView: View {
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "text.badge.plus")
                .font(.largeTitle)
                .padding(.bottom, 8)
            Text("요약 기능은 곧 제공될 예정입니다.")
                .font(.title3)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding()
        .navigationTitle("요약")
    }
}

// MARK: - Settings

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
                    Picker("사전 알림(D-일)", selection: $ddayOption) {
                        ForEach(ddayOptions, id: \.self) { d in
                            Text("D-\(d)").tag(d)
                        }
                    }
                }
                
                Section(header: Text("계정")) {
                    Button(role: .none) {
                    } label: {
                        Label("LMS 계정 재연결", systemImage: "arrow.triangle.2.circlepath")
                    }
                    Button(role: .destructive) {
                    } label: {
                        Label("로그아웃", systemImage: "rectangle.portrait.and.arrow.forward")
                    }
                }
            }
            .navigationTitle("설정")
        }
    }
}

#Preview {
    ContentView()
}
