import Foundation
import SwiftUI
import Combine

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


