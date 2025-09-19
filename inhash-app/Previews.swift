import SwiftUI

// 개별 화면 단독 미리보기 세트

#Preview("LoginView") {
    let auth = AuthStore()
    return LoginView()
        .environmentObject(auth)
        .previewDisplayName("LoginView")
        .preferredColorScheme(.light)
}

#Preview("SignupView") {
    let auth = AuthStore()
    return SignupView()
        .environmentObject(auth)
        .previewDisplayName("SignupView")
        .preferredColorScheme(.light)
}

#Preview("LmsLinkView") {
    let auth = AuthStore()
    auth.isAuthenticated = true // 콘텐츠 플로우 무시하고 화면 구성만 미리보기
    return LmsLinkView()
        .environmentObject(auth)
        .previewDisplayName("LmsLinkView")
}

#Preview("HomeView") {
    let store = ScheduleStore()
    return HomeView()
        .environmentObject(store)
        .previewDisplayName("HomeView")
}

#Preview("CalendarView") {
    let store = ScheduleStore()
    return CalendarView()
        .environmentObject(store)
        .previewDisplayName("CalendarView")
}

#Preview("SummaryView") {
    SummaryView()
        .previewDisplayName("SummaryView")
}

#Preview("SettingsView") {
    SettingsView()
        .previewDisplayName("SettingsView")
}
