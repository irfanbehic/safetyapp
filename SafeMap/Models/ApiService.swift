import Foundation
import MapKit

class ApiService {
    static let shared = ApiService()
    private init() {}
    
    let baseURL = URL(string: "http://localhost:8000")!
    
    func fetchRegions(completion: @escaping (Result<[Region], Error>) -> Void) {
        let url = baseURL.appendingPathComponent("regions")
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }
            do {
                let regions = try JSONDecoder().decode([Region].self, from: data)
                completion(.success(regions))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchGeoJSON(completion: @escaping (Result<GeoJSON, Error>) -> Void) {
        let url = baseURL.appendingPathComponent("regions/geojson")
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }
            do {
                let geo = try JSONDecoder().decode(GeoJSON.self, from: data)
                completion(.success(geo))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}