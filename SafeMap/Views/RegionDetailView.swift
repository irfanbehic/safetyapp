import SwiftUI

struct RegionDetailView: View {
    let region: Region
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(region.name)
                .font(.title2)
                .bold()
            Text("\(NSLocalizedString("score", comment: "")): \(region.score)")
                .font(.headline)
            Divider()
            Text(LocalizedStringKey("news"))
                .font(.headline)
            ForEach(region.news.prefix(3)) { news in
                VStack(alignment: .leading, spacing: 4) {
                    Text(news.title)
                        .font(.subheadline)
                    Text(news.date)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            Button(action: {
                // Detaya git
            }) {
                Text(LocalizedStringKey("details"))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}

struct RegionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleNews = [
            NewsItem(title: "Gümüşpınar’da silahlı çatışma paniği", date: "2025-07-10", severity: "high", link: nil),
            NewsItem(title: "İstanbul Kartal’da hırsızlık artışı", date: "2025-06-30", severity: "medium", link: nil)
        ]
        let sampleRegion = Region(name: "Gümüşpınar", city: "İstanbul", district: "Kartal", score: 68, colorHex: "#FF9900", news: sampleNews)
        RegionDetailView(region: sampleRegion)
    }
}