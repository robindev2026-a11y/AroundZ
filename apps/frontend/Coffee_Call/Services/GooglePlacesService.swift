import Foundation
import CoreLocation

struct PlacePrediction: Identifiable, Codable, Hashable {
    let id: String
    let description: String
    let mainText: String
    let secondaryText: String

    enum CodingKeys: String, CodingKey {
        case id = "place_id"
        case description
        case structuredFormatting = "structured_formatting"
    }

    enum StructuredFormattingKeys: String, CodingKey {
        case mainText = "main_text"
        case secondaryText = "secondary_text"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        description = try container.decode(String.self, forKey: .description)
        
        let structured = try container.nestedContainer(keyedBy: StructuredFormattingKeys.self, forKey: .structuredFormatting)
        mainText = try structured.decodeIfPresent(String.self, forKey: .mainText) ?? description
        secondaryText = try structured.decodeIfPresent(String.self, forKey: .secondaryText) ?? ""
    }
}

class GooglePlacesService {
    static let shared = GooglePlacesService()
    
    // TODO: Provide your Google Maps API Key here or in an environment configuration
    private let apiKey = "YOUR_GOOGLE_MAPS_API_KEY"
    
    private init() {}
    
    func fetchAutocompletePredictions(query: String, coordinate: CLLocationCoordinate2D?, completion: @escaping ([PlacePrediction]) -> Void) {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            completion([])
            return
        }
        
        var urlString = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(query)&key=\(apiKey)"
        if let coordinate = coordinate {
            urlString += "&location=\(coordinate.latitude),\(coordinate.longitude)&radius=50000"
        }
        
        guard let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedUrlString) else {
            completion([])
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async { completion([]) }
                return
            }
            
            do {
                let result = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let predictionsData = result?["predictions"] as? [[String: Any]] {
                    let jsonData = try JSONSerialization.data(withJSONObject: predictionsData, options: [])
                    let predictions = try JSONDecoder().decode([PlacePrediction].self, from: jsonData)
                    DispatchQueue.main.async { completion(predictions) }
                } else {
                    DispatchQueue.main.async { completion([]) }
                }
            } catch {
                print("Error parsing Google Places response: \(error)")
                DispatchQueue.main.async { completion([]) }
            }
        }.resume()
    }
    
    func fetchPlaceDetails(placeId: String, completion: @escaping (CLLocationCoordinate2D?, String?) -> Void) {
        let urlString = "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(placeId)&fields=geometry,name&key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            completion(nil, nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async { completion(nil, nil) }
                return
            }
            
            do {
                let result = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let resultDict = result?["result"] as? [String: Any],
                   let geometry = resultDict["geometry"] as? [String: Any],
                   let location = geometry["location"] as? [String: Double],
                   let lat = location["lat"], let lng = location["lng"] {
                    let name = resultDict["name"] as? String
                    DispatchQueue.main.async {
                        completion(CLLocationCoordinate2D(latitude: lat, longitude: lng), name)
                    }
                } else {
                    DispatchQueue.main.async { completion(nil, nil) }
                }
            } catch {
                print("Error parsing place details: \(error)")
                DispatchQueue.main.async { completion(nil, nil) }
            }
        }.resume()
    }
}
