import SwiftUI
import MapKit

struct ContentView: View {
    @State private var searchText = ""
    @State private var selectedRegion: Region? = nil
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.95, longitude: 29.13),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    // Hardcoded region data for MVP
    let regions: [Region] = [
        Region(
            name: "Gümüşpınar",
            city: "İstanbul",
            district: "Kartal",
            score: 68,
            colorHex: "#FF9900",
            news: [
                NewsItem(title: "Gümüşpınar’da silahlı çatışma paniği", date: "2025-07-10", severity: "high", link: nil),
                NewsItem(title: "İstanbul Kartal’da hırsızlık artışı", date: "2025-06-30", severity: "medium", link: nil)
            ]
        ),
        Region(
            name: "Koşuyolu",
            city: "İstanbul",
            district: "Kadıköy",
            score: 90,
            colorHex: "#00CC66",
            news: [
                NewsItem(title: "Koşuyolu’nda huzurlu yaz akşamı", date: "2025-07-01", severity: "low", link: nil)
            ]
        )
    ]
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
                MapView(regions: regions, selectedRegion: $selectedRegion, mapRegion: $mapRegion)
                    .frame(height: 350)
                Spacer()
            }
            .sheet(item: $selectedRegion) { region in
                RegionDetailView(region: region)
            }
            .navigationBarHidden(true)
        }
    }
}

// MapView SwiftUI wrapper
struct MapView: UIViewRepresentable {
    let regions: [Region]
    @Binding var selectedRegion: Region?
    @Binding var mapRegion: MKCoordinateRegion
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        mapView.setRegion(mapRegion, animated: false)
        // Add polygons
        for region in regions {
            if let polygon = regionPolygon(for: region) {
                mapView.addOverlay(polygon)
            }
        }
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // No-op for MVP
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Example: create polygon for hardcoded regions
    func regionPolygon(for region: Region) -> MKPolygon? {
        if region.name == "Gümüşpınar" {
            let coords = [
                CLLocationCoordinate2D(latitude: 40.900, longitude: 29.200),
                CLLocationCoordinate2D(latitude: 40.900, longitude: 29.210),
                CLLocationCoordinate2D(latitude: 40.910, longitude: 29.210),
                CLLocationCoordinate2D(latitude: 40.910, longitude: 29.200)
            ]
            let polygon = MKPolygon(coordinates: coords, count: coords.count)
            polygon.title = region.name
            return polygon
        } else if region.name == "Koşuyolu" {
            let coords = [
                CLLocationCoordinate2D(latitude: 41.000, longitude: 29.050),
                CLLocationCoordinate2D(latitude: 41.000, longitude: 29.060),
                CLLocationCoordinate2D(latitude: 41.010, longitude: 29.060),
                CLLocationCoordinate2D(latitude: 41.010, longitude: 29.050)
            ]
            let polygon = MKPolygon(coordinates: coords, count: coords.count)
            polygon.title = region.name
            return polygon
        }
        return nil
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        init(_ parent: MapView) {
            self.parent = parent
        }
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polygon = overlay as? MKPolygon {
                let renderer = MKPolygonRenderer(polygon: polygon)
                if let region = parent.regions.first(where: { $0.name == polygon.title }) {
                    renderer.fillColor = UIColor(hex: region.colorHex).withAlphaComponent(0.5)
                } else {
                    renderer.fillColor = UIColor.gray.withAlphaComponent(0.3)
                }
                renderer.strokeColor = UIColor.black
                renderer.lineWidth = 1
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            // Not used for polygons
        }
        func mapView(_ mapView: MKMapView, didSelect overlay: MKOverlay) {
            if let polygon = overlay as? MKPolygon, let name = polygon.title {
                if let region = parent.regions.first(where: { $0.name == name }) {
                    parent.selectedRegion = region
                }
            }
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