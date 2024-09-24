//
//  API.swift
//  Mi Salud
//
//  Created by Carlos Mtz on 23/09/24.
//

import Foundation

// Fetch session key and user ID from UserDefaults
let sessionKey: String = {
    return UserDefaults.standard.string(forKey: "session_key") ?? "1035ba7c-569a-4b51-a95a-7a77870e4f4c" // Use hardcoded session key if not found
}()

let userID: Int = {
    return UserDefaults.standard.integer(forKey: "user_id") > 0 ? UserDefaults.standard.integer(forKey: "user_id") : 1 // Use stored user ID or default to 1
}()

// Struct to decode the current points response
struct PointsResponse: Decodable {
    let puntos: Int
}

// Fetch current points using the retrieved session key
func fetchCurrentPoints(userID: Int, sessionKey: String, completion: @escaping (Int) -> Void) {
    guard let url = URL(string: "http://localhost:8000/users/currentpoints/\(userID)") else { return }
    
    var request = URLRequest(url: url)
    request.addValue(sessionKey, forHTTPHeaderField: "key") // Add the session key as a header
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error fetching points: \(error)")
            return
        }
        
        guard let data = data else {
            print("No data returned")
            return
        }
        
        do {
            // Print the raw data to debug
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON response: \(jsonString)")
            }
            
            // Decode the dictionary response
            let pointsResponse = try JSONDecoder().decode(PointsResponse.self, from: data)
            DispatchQueue.main.async {
                completion(pointsResponse.puntos)
            }
        } catch {
            print("Error decoding points: \(error)")
        }
    }.resume()
}

// TIENDA

// Struct to represent a single catalog item
struct CatalogItem: Codable, Identifiable {
    let id: String
    let nombre: String
    let descripcion: String
    let puntos: String
    
    enum CodingKeys: String, CodingKey {
        case id = "ID_BENEFICIO"
        case nombre = "NOMBRE"
        case descripcion = "DESCRIPCION"
        case puntos = "PUNTOS"
    }
}

func fetchCatalog(sessionKey: String, completion: @escaping ([CatalogItem]) -> Void) {
    let urlString = "http://localhost:8000/tienda/catalogo"
    guard let url = URL(string: urlString) else { return }

    var request = URLRequest(url: url)
    request.httpMethod = "GET" // Ensure the method is set correctly
    request.addValue(sessionKey, forHTTPHeaderField: "key") // Replace with the expected header name if necessary

    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error fetching catalog: \(error.localizedDescription)")
            return
        }

        if let httpResponse = response as? HTTPURLResponse {
            print("HTTP Response Code: \(httpResponse.statusCode)")
            if httpResponse.statusCode != 200 {
                print("Error: Received HTTP \(httpResponse.statusCode)")
                if let data = data, let rawResponse = String(data: data, encoding: .utf8) {
                    print("Response Body: \(rawResponse)")
                }
                return
            }
        }

        guard let data = data else {
            print("No data received")
            return
        }

        if let rawString = String(data: data, encoding: .utf8) {
            print("Raw Response: \(rawString)")
        }

        do {
            let catalogItems = try JSONDecoder().decode([CatalogItem].self, from: data)
            DispatchQueue.main.async {
                completion(catalogItems)
            }
        } catch {
            print("Error decoding catalog items: \(error)")
        }
    }.resume()
}
