import SwiftUI
import MapKit

struct ContentView: View {
    @State private var searchText = ""
    @State private var selectedRegion: Region? = nil
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.95, longitude: 29.13),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var regions: [Region] = []
    @State private var polygons: [NamedPolygon] = []
    
    var filteredRegions: [Region] {
        if searchText.isEmpty { return regions }
        return regions.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.city.localizedCaseInsensitiveContains(searchText) ||
            $0.district.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text(LocalizedStringKey("app_title"))
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)
                TextField(LocalizedStringKey("search_placeholder"), text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding([.leading, .trailing])
                Spacer()
                MapView(polygons: polygons, regions: filteredRegions, selectedRegion: $selectedRegion, mapRegion: $mapRegion)
                    .frame(height: 350)
                Spacer()
            }
            .sheet(item: $selectedRegion) { region in
                RegionDetailView(region: region)
            }
            .navigationBarHidden(true)
            .onAppear {
                loadRegionsAndPolygons()
            }
        }
    }
    
    func loadRegionsAndPolygons() {
        // GeoJSON'dan polygonları oku
        if let url = Bundle.main.url(forResource: "regions", withExtension: "geojson"),
           let data = try? Data(contentsOf: url),
           let geo = try? JSONDecoder().decode(GeoJSON.self, from: data) {
            var tempPolygons: [NamedPolygon] = []
            var tempRegions: [Region] = []
            for feature in geo.features {
                guard let coords = feature.geometry.coordinates.first else { continue }
                let polygonCoords = coords.map { CLLocationCoordinate2D(latitude: $0[1], longitude: $0[0]) }
                let polygon = NamedPolygon(coordinates: polygonCoords, count: polygonCoords.count)
                polygon.name = feature.properties.name
                tempPolygons.append(polygon)
                // Örnek skor ve haberler (ileride API'den gelecek)
                let score = feature.properties.name == "Gümüşpınar" ? 68 : 90
                let news: [NewsItem] = feature.properties.name == "Gümüşpınar" ? [
                    NewsItem(title: "Gümüşpınar’da silahlı çatışma paniği", date: "2025-07-10", severity: "high", link: nil),
                    NewsItem(title: "İstanbul Kartal’da hırsızlık artışı", date: "2025-06-30", severity: "medium", link: nil)
                ] : [
                    NewsItem(title: "Koşuyolu’nda huzurlu yaz akşamı", date: "2025-07-01", severity: "low", link: nil)
                ]
                let region = Region(name: feature.properties.name, city: feature.properties.city, district: feature.properties.district, score: score, news: news)
                tempRegions.append(region)
            }
            self.polygons = tempPolygons
            self.regions = tempRegions
        }
    }
}

// MARK: - MapKit Wrapper
struct NamedPolygon: MKPolygon {
    var name: String?
}

struct MapView: UIViewRepresentable {
    let polygons: [NamedPolygon]
    let regions: [Region]
    @Binding var selectedRegion: Region?
    @Binding var mapRegion: MKCoordinateRegion
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        mapView.setRegion(mapRegion, animated: false)
        mapView.addOverlays(polygons)
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // No-op for MVP
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        init(_ parent: MapView) { self.parent = parent }
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polygon = overlay as? NamedPolygon, let name = polygon.name,
               let region = parent.regions.first(where: { $0.name == name }) {
                let renderer = MKPolygonRenderer(polygon: polygon)
                renderer.fillColor = UIColor(hex: region.colorHex).withAlphaComponent(0.5)
                renderer.strokeColor = UIColor.black
                renderer.lineWidth = 1
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
        func mapView(_ mapView: MKMapView, didSelect overlay: MKOverlay) {
            if let polygon = overlay as? NamedPolygon, let name = polygon.name,
               let region = parent.regions.first(where: { $0.name == name }) {
                parent.selectedRegion = region
            }
        }
    }
}

// MARK: - GeoJSON Decoding
struct GeoJSON: Codable {
    let features: [Feature]
    struct Feature: Codable {
        let properties: Properties
        let geometry: Geometry
        struct Properties: Codable {
            let name: String
            let district: String
            let city: String
        }
        struct Geometry: Codable {
            let coordinates: [[[Double]]]
        }
    }
}

// UIColor hex extension
import UIKit
extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}