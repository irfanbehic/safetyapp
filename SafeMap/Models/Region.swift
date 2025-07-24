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
    let news: [NewsItem]
    
    // Skor aralığına göre renk döndürür (dokümantasyona göre)
    var colorHex: String {
        switch score {
        case 0...30:
            return "#FF0000" // Kırmızı
        case 31...60:
            return "#FF9900" // Turuncu
        case 61...85:
            return "#FFD700" // Sarı
        case 86...100:
            return "#00CC66" // Yeşil
        default:
            return "#CCCCCC" // Bilinmeyen
        }
    }
}