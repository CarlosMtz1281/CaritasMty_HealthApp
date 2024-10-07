//
//  API.swift
//  Mi Salud
//
//  Created by Carlos Mtz on 23/09/24.
//

import Foundation

// Fetch session key and user ID from UserDefaults
let sessionKey: String = {
    return UserDefaults.standard.string(forKey: "session_key") ?? "d0e14599-d0c2-4853-8663-707303ff00e0" // Use hardcoded session key if not found
}()

let userID: Int = {
    return UserDefaults.standard.integer(forKey: "user_id") > 0 ? UserDefaults.standard.integer(forKey: "user_id") : 1 // Use stored user ID or default to 1
}()

// Struct to decode the current points response
struct PointsResponse: Codable {
    let nombre: String
    let puntos: Int
}

struct ProfilePictureResponse: Decodable {
    let archivo: String
}

// Fetch current points using the retrieved session key
func fetchCurrentPoints(userID: Int, sessionKey: String, completion: @escaping (String, Int) -> Void) {
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
                completion(pointsResponse.nombre, pointsResponse.puntos)
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

func comprarBono(userID: Int, puntos: Int, beneficioId: String, sessionKey: String, completion: @escaping (Result<String, Error>) -> Void){
    guard let url = URL(string: "http://localhost:8000/tienda/comprarBono") else {
        completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
        return
    }
    
    // crear body
    let body: [String: Any] = [
        "user_id": userID,
        "puntos": puntos,
        "beneficio_id": beneficioId
    ]
    
    // convertir body a json
    guard let jsonData = try? JSONSerialization.data(withJSONObject: body, options: []) else {
        completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Error al serializar JSON"])))
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue(sessionKey, forHTTPHeaderField: "key")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = jsonData
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            print("Código de respuesta: \(httpResponse.statusCode)")
        }
        
        // Manejar los datos recibidos
        if let data = data {
            do {
                // Intentar decodificar la respuesta como JSON
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let message = jsonResponse["message"] as? String {
                        completion(.success(message)) // Enviar el mensaje exitoso al completion
                    } else if let conflict = jsonResponse["conflict"] as? String {
                        completion(.success(conflict)) // Manejar mensaje de conflicto (ej. "Beneficio ya comprado")
                    } else if let error = jsonResponse["error"] as? String {
                        completion(.success(error)) // Manejar mensaje de error
                    } else {
                        completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Respuesta desconocida del servidor"])))
                    }
                } else {
                    completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Formato de respuesta no válido"])))
                }
            } catch {
                completion(.failure(error))
            }
        } else {
            completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "No se recibieron datos del servidor"])))
        }
    }
    
    task.resume()
}


// events

struct Event: Identifiable {
    let id = UUID()
    let title: String
    let date: String
    let location: String
    let availableSpots: Int
    let description: String
    let organizer: String
    let eventDate: String
}

struct EventItem: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let availableSpots: String
    let score: String
    let eventDate: String
    let location: String
    let organizer: String
    
    enum CodingKeys: String, CodingKey {
        case id = "ID_EVENTO"
        case title = "NOMBRE"
        case description = "DESCRIPCION"
        case availableSpots = "NUM_MAX_ASISTENTES"
        case score = "PUNTAJE"
        case eventDate = "FECHA" // Cambié "fECHA" a "FECHA" para que coincida con el JSON de ejemplo
        case location = "LUGAR"
        case organizer = "EXPOSITOR"
    }
}

func fetchEvents(sessionKey: String, completion: @escaping ([EventItem]) -> Void) {
    print("Fetching general events...")
    print(sessionKey)
    guard let url = URL(string: "http://localhost:8000/eventos/getFuturosEventos") else { return }
    
    var request = URLRequest(url: url)
    request.addValue(sessionKey, forHTTPHeaderField: "key") // Add session key as header
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error fetching events: \(error.localizedDescription)")
            return
        }
        
        guard let data = data else {
            print("No data returned")
            return
        }
        
        // Print the raw JSON response for debugging
     
        
        do {
            let events = try JSONDecoder().decode([EventItem].self, from: data)
            DispatchQueue.main.async {
                completion(events)
            }
        } catch {
            print("Error decoding events: \(error.localizedDescription)")
        }
    }.resume()
}

func fetchMyEvents(sessionKey: String, completion: @escaping ([EventItem]) -> Void) {
    print("Fetching personal events...")
    print(sessionKey)
    guard let url = URL(string: "http://localhost:8000/eventos/eventosUsuario/\(userID)") else { return }
    print("Fetching personal events...")
    
    var request = URLRequest(url: url)
    request.addValue(sessionKey, forHTTPHeaderField: "key") // Add session key as header
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error fetching personal events: \(error.localizedDescription)")
            return
        }
        
        guard let data = data else {
            print("No data returned")
            return
        }
        
        // Print the raw JSON response for debugging
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Raw JSON response: \(jsonString)")
        }
        
        do {
            let events = try JSONDecoder().decode([EventItem].self, from: data)
            DispatchQueue.main.async {
                completion(events)
            }
        } catch {
            print("Error decoding personal events: \(error.localizedDescription)")
        }
        
        print("Done")
    }.resume()
}

// codigo de retos
struct ChallengeItem: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let contact: String
    let deadline: String
    let score: String
    
    enum CodingKeys: String, CodingKey {
        case id = "ID_RETO"
        case title = "NOMBRE"
        case description = "DESCRIPCION"
        case contact = "CONTACTO"
        case deadline = "FECHA_LIMITE"
        case score = "PUNTAJE"
    }
}

func fetchChallenges(sessionKey: String, completion: @escaping ([ChallengeItem]) -> Void) {
    print("Fetching challenges...")
    print(sessionKey)
    guard let url = URL(string: "http://localhost:8000/retos/getRetos") else { return }
    
    var request = URLRequest(url: url)
    request.addValue(sessionKey, forHTTPHeaderField: "key") // Agregar clave de sesión como header
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error fetching challenges: \(error.localizedDescription)")




////////////////////////////////////////////////////////////////////////////// SALUD ///////////////////////////////////////////////////////////////////////////
struct HealthDataPoint: Identifiable {
    var id = UUID()
    var time: String
    var value: Double
}

struct BloodPressureDataPoint: Identifiable {
    var id = UUID()
    var time: String
    var systolic: Double
    var diastolic: Double
}

struct MedicionesResponse: Codable {
    let resultados: MedicionesResultados
}

struct MedicionesResultados: Codable {
    let glucosa: [Glucose]
    let presion_arterial: [BloodPressure]
    let ritmo_cardiaco: [HeartRate]
}

struct Glucose: Codable {
    var fecha: String
    var glucosa: Int
}

struct BloodPressure: Codable {
    var fecha: String
    var presion_diastolica: Int
    var presion_sistolica: Int
}

struct HeartRate: Codable {
    var fecha: String
    var ritmo: Int
}

func formatDate(_ dateString: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
    if let date = formatter.date(from: dateString) {
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MM/dd/yy"
        return outputFormatter.string(from: date)
    }
    return dateString
}

func fetchMedicionesSalud(userID: Int, sessionKey: String, completion: @escaping ([HealthDataPoint], [BloodPressureDataPoint], [HealthDataPoint]) -> Void) {
    guard let url = URL(string: "http://localhost:8000/mediciones/medicionesdatos/\(userID)") else {
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.addValue(sessionKey, forHTTPHeaderField: "key")
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error fetching health data: \(error)")
            return
        }
        
        guard let data = data else {
            print("No data returned")
            return
        }
        
        // Imprimir la respuesta JSON en bruto para depuración
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Raw JSON response: \(jsonString)")
        }
        
        do {
            let challenges = try JSONDecoder().decode([ChallengeItem].self, from: data)
            DispatchQueue.main.async {
                completion(challenges)
            }
        } catch {
            print("Error decoding challenges: \(error.localizedDescription)")
        }
    }.resume()
}

// Nuevo método para obtener los retos del usuario
func fetchMyChallenges(userId: Int, sessionKey: String, completion: @escaping ([ChallengeItem]) -> Void) {
    print("Fetching my challenges for user: \(userId)...")
    print(sessionKey)
    guard let url = URL(string: "http://localhost:8000/retos/getMyRetos/\(userId)") else { return }
    
    var request = URLRequest(url: url)
    request.addValue(sessionKey, forHTTPHeaderField: "key") // Agregar clave de sesión como header
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error fetching my challenges: \(error.localizedDescription)")
            return
        }
        
        guard let data = data else {
            print("No data returned")
            return
        }
        
        // Imprimir la respuesta JSON en bruto para depuración
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Raw JSON response: \(jsonString)")
        }
        
        do {
            let challenges = try JSONDecoder().decode([ChallengeItem].self, from: data)
            DispatchQueue.main.async {
                completion(challenges)
            }
        } catch {
            print("Error decoding my challenges: \(error.localizedDescription)")
        }
    }.resume()
}

        do {
            // Debug: Print the raw JSON
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON response: \(jsonString)")
            }

            // Decode the response
            let medicionesResponse = try JSONDecoder().decode(MedicionesResponse.self, from: data)
            
            // Process the data and send it via the completion handler
            DispatchQueue.main.async {
                let glucosaData = medicionesResponse.resultados.glucosa.map {
                    HealthDataPoint(time: formatDate($0.fecha), value: Double($0.glucosa))
                }
                
                let bloodPressureData = medicionesResponse.resultados.presion_arterial.map {
                    BloodPressureDataPoint(time: formatDate($0.fecha), systolic: Double($0.presion_sistolica), diastolic: Double($0.presion_diastolica))
                }
                
                let heartRateData = medicionesResponse.resultados.ritmo_cardiaco.map {
                    HealthDataPoint(time: formatDate($0.fecha), value: Double($0.ritmo))
                }
                
                // Call the completion handler with the formatted data
                completion(glucosaData, bloodPressureData, heartRateData)
            }
        } catch {
            print("Error decoding health data response: \(error)")
        }
    }.resume()
}
