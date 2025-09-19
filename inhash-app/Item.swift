import Foundation

struct Item: Identifiable, Hashable {
    let id = UUID()
    let title: String
}
