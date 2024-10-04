//
//  PointsHistoryView.swift
//  Mi Salud
//
//  Created by Carlos Mtz on 18/09/24.
//


import SwiftUI

struct Transaction: Identifiable, Decodable {
    var id = UUID()  // Usando UUID para la identificación única de la fila
    var fecha: String
    var origen_nombre: String
    var puntos: String
    var tipo: Bool
    
    // Haciendo coincidir las claves de la respuesta de la API con las propiedades de la estructura
    enum CodingKeys: String, CodingKey {
        case fecha
        case origen_nombre
        case puntos
        case tipo
    }
}

// Función para obtener y decodificar el historial de puntos utilizando la clave de sesión hardcodeada
func fetchPointsHistory(userID: Int, sessionKey: String, completion: @escaping ([Transaction]?, String?) -> Void) {
    guard let url = URL(string: "http://localhost:8000/users/historypoints/\(userID)") else { return }
    
    var request = URLRequest(url: url)
    request.addValue(sessionKey, forHTTPHeaderField: "key") // Añadir la clave de sesión como un encabezado
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            DispatchQueue.main.async {
                completion(nil, "Error de conexión: No se pudo conectar al servidor")
            }
            return
        }
        
        guard let data = data else {
            DispatchQueue.main.async {
                completion(nil, "No se recibieron datos.")
            }
            return
        }
        
        // Debug: Imprimir la respuesta en bruto
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Respuesta JSON en bruto: \(jsonString)")
        }
        
        do {
            // Intentar decodificar los datos como un arreglo de transacciones
            let history = try JSONDecoder().decode([Transaction].self, from: data)
            DispatchQueue.main.async {
                completion(history, nil)
            }
        } catch {
            DispatchQueue.main.async {
                completion(nil, "Error inesperado: \(error.localizedDescription)")
            }
        }
    }.resume()
}

struct PointsHistoryView: View {
    @State private var points: Int = 0
    @State private var history: [Transaction] = []
    @State private var errorMessage: String? = nil
    @Environment(\.presentationMode) var presentationMode
    @State private var userName: String = "Usuario"
    
    var body: some View {
        VStack {
            // Encabezado
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss() // Descartar la vista actual
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
            
            // Mostrar los puntos
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
            
            // Lista de transacciones
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
            // Obtener los puntos primero, luego obtener el historial
            fetchPointsHistory(userID: userID, sessionKey: sessionKey) { fetchedHistory, error in
                if let error = error {
                    self.errorMessage = error
                } else if let fetchedHistory = fetchedHistory {
                    self.history = fetchedHistory
                }
            }
        }
        .alert(isPresented: Binding<Bool>(
            get: { self.errorMessage != nil },
            set: { _ in self.errorMessage = nil }
        )) {
            Alert(
                title: Text("Error"),
                message: Text(errorMessage ?? "Error desconocido"),
                dismissButton: .default(Text("OK"))
            )
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
