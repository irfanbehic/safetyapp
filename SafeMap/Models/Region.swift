import Foundation

struct NewsItem: Identifiable, Codable {
    let id = UUID()
    let title: String
    let date: String
    let severity: String?
    let link: String?
}

struct Region: Identifiable, Codable {
    let id = UUID()
    let name: String
    let city: String
    let district: String
    let score: Int
    let colorHex: String
    let news: [NewsItem]
}