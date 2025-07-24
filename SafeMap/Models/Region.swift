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
    let region: String
    let name: String
    let city: String
    let district: String
    let score: Int
    let news: [NewsItem]
    
    var colorHex: String {
        switch score {
        case 0...30:
            return "#FF0000"
        case 31...60:
            return "#FF9900"
        case 61...85:
            return "#FFD700"
        case 86...100:
            return "#00CC66"
        default:
            return "#CCCCCC"
        }
    }
}