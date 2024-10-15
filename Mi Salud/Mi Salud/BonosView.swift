//
//  BonosView.swift
//  Mi Salud
//
//  Created by Carlos Mtz on 15/10/24.
//

import SwiftUI

struct BonosView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showingAlert = false
    @State private var selectedCode: String = ""
    
    // Add state to store the fetched bonos and potential error message
    @State private var bonos: [Bono] = []
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            VStack {
                Spacer()
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.title2)
                            .bold()
                    }
                    .padding()
                    .background(Color(Constants.Colors.primary))
                    .foregroundColor(.white)

                    Text("Bonos Comprados")
                        .font(.system(size: 24))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.trailing)

                    Spacer()
                }
                .padding()
                .foregroundColor(.white)
            }
            .background(Color(Constants.Colors.primary))
            .frame(height: 130)

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else {
                // Display list of Bonos
                List(bonos) { bono in
                    HStack {
                        Button(action: {
                            // Show the special code in an alert
                            selectedCode = bono.codigo
                            showingAlert = true
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(bono.nombre)
                                        .font(.title3)
                                        .bold()
                                        .padding(.bottom, 5)
                                    Text(bono.descripcion)
                                        .font(.subheadline)
                                    Text("Puntos: \(bono.puntos)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                VStack {
                                    Image(systemName: "lock")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                    Text("Ver código")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .background(Color.orange)
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                }
                .listStyle(PlainListStyle())
                .alert(isPresented: $showingAlert) {
                    Alert(
                        title: Text("Código"),
                        message: Text("Tu código es: \(selectedCode)"),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.top)
        .background(Color.white) // Set the background color

        .onAppear {
            // Call the API when the view appears
            fetchBonosComprados(userID: userID, sessionKey: sessionKey) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let fetchedBonos):
                        self.bonos = fetchedBonos
                    case .failure(let error):
                        self.errorMessage = handleFetchBonosError(error)
                    }
                }
            }
        }
    }

    // Handle error message from the API
    private func handleFetchBonosError(_ error: FetchBonosError) -> String {
        switch error {
        case .invalidSessionKey:
            return "Sesión inválida. Por favor, vuelve a iniciar sesión."
        case .noBonosFound:
            return "No se encontraron bonos comprados."
        case .serverError(let message):
            return "Error del servidor: \(message)"
        case .invalidResponse:
            return "Respuesta inválida del servidor."
        case .decodingError(let decodingErrorMessage):
            return "Error de decodificación: \(decodingErrorMessage)"
        }
    }
}

struct BonosView_Previews: PreviewProvider {
    static var previews: some View {
        BonosView()
    }
}
