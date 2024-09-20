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
    
    enum CodingKeys: String, CodingKey {
        case fecha
        case origen_nombre
        case puntos
        case tipo
    }
}
func fetchCurrentPoints(userID: Int, completion: @escaping (Int) -> Void) {
    guard let url = URL(string: "http://localhost:8000/users/currentpoints/\(userID)") else { return }
    
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let data = data {
            do {
                // Decode an array of dictionaries, then extract the "puntos" value from the first one
                if let pointsArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: String]],
                   let firstEntry = pointsArray.first,
                   let puntosString = firstEntry["puntos"],
                   let puntos = Int(puntosString) {
                    DispatchQueue.main.async {
                        completion(puntos)
                    }
                } else {
                    print("Unexpected points format")
                }
            } catch {
                print("Error decoding points: \(error)")
            }
        } else if let error = error {
            print("Error fetching points: \(error)")
        }
    }.resume()
}

// Fetch and decode transaction history
func fetchPointsHistory(userID: Int, completion: @escaping ([Transaction]) -> Void) {
    guard let url = URL(string: "http://localhost:8000/users/historypoints/\(userID)") else { return }
    
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let data = data {
            do {
                // Decode the array of dictionaries into the Transaction struct
                let history = try JSONDecoder().decode([Transaction].self, from: data)
                DispatchQueue.main.async {
                    completion(history)
                }
            } catch {
                print("Error decoding history: \(error)")
            }
        } else if let error = error {
            print("Error fetching history: \(error)")
        }
    }.resume()
}

struct PointsHistoryView: View {
    @State private var points: Int = 0
    @State private var history: [Transaction] = []
    
    var userID: Int = 1 // Hardcoded for now, replace with actual user ID
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Text("Historial de puntos")
                    .font(.title2)
                    .bold()
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
                    ForEach(history) { transaction in
                        TransactionRow(title: transaction.origen_nombre, date: transaction.fecha, points: "\(transaction.puntos) puntos")
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            
            
            Spacer()
        }
        
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .onAppear {
            // Fetch points and history when the view appears
            fetchCurrentPoints(userID: userID) { fetchedPoints in
                self.points = fetchedPoints
            }
            
            fetchPointsHistory(userID: userID) { fetchedHistory in
                self.history = fetchedHistory
            }
        }
    }
}

struct TransactionRow: View {
    var title: String
    var date: String
    var points: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            HStack {
                Text(date)
                Spacer()
                Text(points)
                    .bold()
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
