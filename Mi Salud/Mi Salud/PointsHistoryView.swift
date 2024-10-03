//
//  PointsHistoryView.swift
//  Mi Salud
//
//  Created by Carlos Mtz on 18/09/24.
//

import SwiftUI

struct Transaction: Identifiable, Decodable {
    var id = UUID()  // Using UUID for unique row identification
    var fecha: String
    var origen_nombre: String
    var puntos: String
    var tipo: Bool
    
    // Match the API response keys to your struct properties
    enum CodingKeys: String, CodingKey {
        case fecha
        case origen_nombre
        case puntos
        case tipo
    }
}


// Fetch current points using the hardcoded session key


// Fetch and decode transaction history using the hardcoded session key
func fetchPointsHistory(userID: Int, sessionKey: String, completion: @escaping ([Transaction]) -> Void) {
    guard let url = URL(string: "http://localhost:8000/users/historypoints/\(userID)") else { return }
    
    var request = URLRequest(url: url)
    request.addValue(sessionKey, forHTTPHeaderField: "key") // Add the session key as a header
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error fetching history: \(error)")
            return
        }
        
        guard let data = data else {
            print("No data returned")
            return
        }
        
        // Debug: Print the raw response
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Raw JSON response: \(jsonString)")
        }
        
        do {
            // Try to decode the data as an array of transactions
            let history = try JSONDecoder().decode([Transaction].self, from: data)
            DispatchQueue.main.async {
                completion(history)
            }
        } catch DecodingError.typeMismatch {
            // If the response is not an array, try to decode as a dictionary (assumed to be an error message)
            do {
                let errorResponse = try JSONDecoder().decode([String: String].self, from: data)
                print("Received dictionary (possible error message): \(errorResponse)")
                // You can handle the error response here, e.g., showing an alert to the user
            } catch {
                print("Failed to decode as error dictionary: \(error)")
            }
        } catch {
            print("Unexpected error decoding history: \(error)")
        }
    }.resume()
}

struct PointsHistoryView: View {
    @State private var points: Int = 0
    @State private var history: [Transaction] = []
    @Environment(\.presentationMode) var presentationMode 
    @State private var userName: String = "Usuario"


    
    var body: some View {
        VStack {
            // Header
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss() // Dismiss the current view
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                }
                .padding(.trailing, 8)
                
                Text("Historial de puntos")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding()
            .background(Color(Constants.Colors.primary))
            .foregroundColor(.white)
            
            // Points display
            HStack {
                Circle()
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color.orange)
                Text("\(points) puntos")
                    .font(.largeTitle)
                    .bold()
                Spacer()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .padding()
            .shadow(radius: 2)
            
            // Transactions list
            List {
                Section(header: Text("Ultimas Transacciones")) {
                    ForEach(history.reversed()) { transaction in
                        TransactionRow(title: transaction.origen_nombre, date: transaction.fecha, points: "\(transaction.tipo ? transaction.puntos : "-\(transaction.puntos)") puntos", tipo: transaction.tipo)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            
            Spacer()
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .onAppear {
            // Fetch points first, then fetch history
            fetchCurrentPoints(userID: userID, sessionKey: sessionKey) { fetchedName, fetchedPoints in
                // Store the fetched name and points
                self.userName = fetchedName
                self.points = fetchedPoints

                
                // Once points are fetched, fetch the history
                fetchPointsHistory(userID: userID, sessionKey: sessionKey) { fetchedHistory in
                    self.history = fetchedHistory
                }
            }
        }
    }
}

struct TransactionRow: View {
    var title: String
    var date: String
    var points: String
    var tipo: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            HStack {
                Text(date)
                Spacer()
                Text(points)
                    .bold()
                    .foregroundColor(tipo ? .green : .red)
            }
            .font(.subheadline)
            .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
}

#Preview {
    PointsHistoryView()
}
