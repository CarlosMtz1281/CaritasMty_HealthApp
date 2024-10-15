//
//  ContentView.swift
//  miSaludHelper
//
//  Created by Nico Trevino on 04/10/24.
//

import SwiftUI

struct ContentView: View {
    @State private var qrCode: String = ""
    @State private var isScanning = true
    @State private var eventId: String = ""
    @State private var alertMessage: String = ""
    @State private var showingAlert = false
    
    var body: some View {
        VStack(alignment:.center) {
            Text("Registrar asistencia a Evento")
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                .padding(.top, 20)
                .padding(.horizontal, 5)
                .foregroundColor(.black)
            
            TextField("id de evento", text: $eventId)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color(red: 198/255, green: 198/255, blue: 198/255)))
                .foregroundColor(.black)
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
                .autocapitalization(.none)
            
            
            if isScanning {
                Spacer()

                QRScannerView(isScanning: $isScanning, didFindCode: { code in
                    self.qrCode = code
                })
                .frame(width: 320, height: 450)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.black, lineWidth: 2)
                )
            } else {
                Text("ID de usuario escaneado: \(qrCode)")
                    .font(.title3)
                    .foregroundColor(.black)
                    .padding(.top, 30)

                Button("Confirmar asistencia") {
                    confirmarAsistencia()
                }
                .padding()
                .background(Color(red: 255/255, green: 88/255, blue: 0/255))
                .foregroundColor(.white)
                .font(.title2)
                .cornerRadius(10)
                
                Button("Escanear otro código") {
                    isScanning = true
                }
                .padding()
                .background(Color(red: 0/255, green: 48/255, blue: 73/255))
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
        .background(.white)
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Resultado"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    func confirmarAsistencia() {
        guard let userId = Int(qrCode), let eventIdInt = Int(eventId) else {
            alertMessage = "Código QR o ID del evento inválido"
            showingAlert = true
            return
        }

        let url = URL(string: "https://sabritones.tc2007b.tec.mx:10206/eventos/asistirEvento")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let json: [String: Any] = [
            "user_id": userId,
            "id_evento": eventIdInt
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: json)

        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.alertMessage = "Error: \(error.localizedDescription)"
                    self.showingAlert = true
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.alertMessage = "No data returned"
                    self.showingAlert = true
                }
                return
            }

            let responseString = String(data: data, encoding: .utf8) ?? "Error desconocido"
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    self.alertMessage = "Asistencia registrada exitosamente."
                    self.showingAlert = true
                }
            } else {
                DispatchQueue.main.async {
                    self.alertMessage = "Error: \(responseString)"
                    self.showingAlert = true
                }
            }
        }.resume()
    }

}

#Preview {
    ContentView()
}
