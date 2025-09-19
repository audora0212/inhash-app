import SwiftUI

struct CalendarView: View {
    @EnvironmentObject private var store: ScheduleStore
    @State private var currentMonth: Date = Date()
    
    private var monthItems: [ScheduleItem] { store.items.filter { Calendar.current.isDate($0.due, equalTo: currentMonth, toGranularity: .month) } }
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
                    DatePicker("", selection: $currentMonth, displayedComponents: [.date]).datePickerStyle(.compact).labelsHidden()
                    Spacer()
                    Button(action: { shiftMonth(-1) }) { Image(systemName: "chevron.left") }
                    Button(action: { shiftMonth(1) }) { Image(systemName: "chevron.right") }
                }.padding(.horizontal)
                
                CalendarGrid(month: currentMonth, dots: monthDots()).padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("이번달 요약").font(.headline)
                    SummaryRow(title: "이번달 제출 과제", count: monthItems.filter { $0.type == .assignment }.count)
                    SummaryRow(title: "이번달 수강 수업", count: monthItems.filter { $0.type == .lecture }.count)
                    Divider()
                    Text("이번주 요약").font(.headline)
                    SummaryRow(title: "이번주 제출 과제", count: weekItems.filter { $0.type == .assignment }.count)
                    SummaryRow(title: "이번주 수강 수업", count: weekItems.filter { $0.type == .lecture }.count)
                }.padding(.horizontal)
                Spacer(minLength: 0)
            }.navigationTitle("캘린더")
        }
    }
    private func shiftMonth(_ delta: Int) { if let newDate = Calendar.current.date(byAdding: .month, value: delta, to: currentMonth) { currentMonth = newDate } }
    private func monthDots() -> Set<Int> { var days = Set<Int>(); let cal = Calendar.current; for it in monthItems { days.insert(cal.component(.day, from: it.due)) }; return days }
}

struct CalendarGrid: View {
    let month: Date; let dots: Set<Int>
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
        if remainder != 0 { cells += Array(repeating: nil, count: 7 - remainder) }
        return cells
    }
    var body: some View {
        VStack(spacing: 6) {
            HStack { ForEach(["일","월","화","수","목","금","토"], id: \.self) { d in Text(d).font(.caption).frame(maxWidth: .infinity) } }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(0..<days.count, id: \.self) { idx in
                    let day = days[idx]
                    ZStack {
                        if let day = day {
                            let isToday = Calendar.current.isDateInToday(Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: month).setting(day: day)) ?? Date())
                            Circle().fill(isToday ? Color.accentColor.opacity(0.15) : Color.clear).frame(width: 34, height: 34)
                            Text("\(day)").font(.subheadline)
                            if dots.contains(day) { Circle().fill(Color.red).frame(width: 6, height: 6).offset(y: 12) }
                        } else { Text("").frame(height: 34) }
                    }.frame(height: 40)
                }
            }
        }
    }
}

struct SummaryRow: View { let title: String; let count: Int; var body: some View { HStack { Text(title); Spacer(); Text("\(count)개").foregroundColor(.secondary) } } }

private extension DateComponents { func setting(day: Int) -> DateComponents { var c = self; c.day = day; return c } }


