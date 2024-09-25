//
//  API.swift
//  Mi Salud
//
//  Created by Carlos Mtz on 23/09/24.
//

import Foundation

// Fetch session key and user ID from UserDefaults
let sessionKey: String = {
    return UserDefaults.standard.string(forKey: "session_key") ?? "7c3e7347-bc6b-462f-a6a6-1358be14728f" // Use hardcoded session key if not found
}()

let userID: Int = {
    return UserDefaults.standard.integer(forKey: "user_id") > 0 ? UserDefaults.standard.integer(forKey: "user_id") : 1 // Use stored user ID or default to 1
}()

// Struct to decode the current points response
struct PointsResponse: Decodable {
    let puntos: Int
}

struct ProfilePictureResponse: Decodable {
    let archivo: String
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

func updateProfilePicture(userID: Int, imagePath: String, sessionKey: String, completion: @escaping (Result<String, Error>) -> Void) {
    guard let url = URL(string: "http://localhost:8000/users/profilepicture") else { return }
    
    var request = URLRequest(url: url)
    request.httpMethod = "PATCH"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(sessionKey, forHTTPHeaderField: "key")

    let body: [String: Any] = [
        "user_id": userID,
        "path": imagePath
    ]
    
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
    } catch {
        print("Failed to serialize JSON: \(error)")
        return
    }
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    completion(.success("Profile picture updated successfully"))
                }
            } else {
                let errorMessage = "Error: HTTP \(httpResponse.statusCode)"
                print(errorMessage)
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                }
            }
        }
    }.resume()
}

func fetchProfilePicture(userID: Int, sessionKey: String, completion: @escaping (String) -> Void) {
    guard let url = URL(string: "http://localhost:8000/users/profilepicture/\(userID)") else {
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.addValue(sessionKey, forHTTPHeaderField: "key")
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error fetching profile picture: \(error)")
            return
        }
        
        guard let data = data else {
            print("No data returned")
            return
        }
        
        do {
            if let jsonString = String(data: data, encoding: .utf8) {
                //print("Raw JSON response: \(jsonString)")
            }

            let profilePictureResponse = try JSONDecoder().decode(ProfilePictureResponse.self, from: data)
            DispatchQueue.main.async {
                completion(profilePictureResponse.archivo)
            }
        } catch {
            print("Error decoding profile picture response: \(error)")
        }
    }.resume()
}
