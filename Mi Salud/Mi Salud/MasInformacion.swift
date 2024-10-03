//
//  MasInformacion.swift
//  Mi Salud
//
//  Created by Fernando Perez on 02/10/24.
//

import SwiftUI

struct MasInformacion: View {
    var catalogItem: CatalogItem
    @State var userPoints: Int
    @Environment(\.presentationMode) var presentationMode
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""

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
                
                Text("Catalogo")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding()
            .background(Color(Constants.Colors.primary))
            .foregroundColor(.white)
            
            // info
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Título del Bono
                    Text(catalogItem.nombre)
                        .font(.system(size: 35, weight: .bold))
                        .padding(.horizontal)
                    
                    // Imagen del Bono
                    Image("family_trip")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width - 40, height: 250)
                        .clipped()
                        .cornerRadius(10)
                        .padding(.horizontal)
                    
                    // Información de disponibilidad y puntos
                    VStack(alignment: .leading, spacing: 10) {
                        Text("5 bonos disponibles") // Información de ejemplo
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(.gray)
                        
                        VStack(alignment: .leading) {
                            Text("\(catalogItem.puntos) puntos")
                                .font(.system(size: 25, weight: .semibold))
                            Text("Tu saldo actual: \(userPoints)")
                                .font(.system(size: 20, weight: .regular))
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 10)
                    }
                    .padding(.horizontal)
                    
                    // Botón de Reclamar
                    Button(action: {
                        // Acción para reclamar el bono
                        comprarBono(userID: userID, puntos: userPoints, beneficioId: catalogItem.id, sessionKey: sessionKey) { result in
                            switch result {
                            case .success(let response):
                                alertTitle = "Resultado"
                                alertMessage = response
                                showAlert = true
                                // actualizar visualmente los puntos si se compro el bono
                                if response == "Beneficio comprado exitosamente"{
                                    userPoints = userPoints - Int(catalogItem.puntos)!
                                }
                            case .failure(let error):
                                alertTitle = "Error"
                                alertMessage = error.localizedDescription
                                showAlert = true
                            }
                        }
                    }) {
                        Text("Reclamar Bono")
                            .font(.system(size: 23, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .background(Color.orange)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // Descripción
                    VStack(alignment: .leading) {
                        Text("Descripcion")
                            .font(.system(size: 25, weight: .semibold))
                        Text(catalogItem.descripcion)
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(.gray)
                    }
                    .padding()
                    }
                .padding(.vertical)
            }

            
            Spacer()
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}


#Preview {
    MasInformacion(catalogItem: CatalogItem(id: "1", nombre: "Día libre", descripcion: "Un día libre extra para descansar.", puntos: "20"), userPoints: 100)
}

