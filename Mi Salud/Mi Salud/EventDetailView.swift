//
//  EventDetailView.swift
//  Mi Salud
//
//  Created by Carlos Mtz on 03/10/24.
//

import SwiftUI

struct EventDetailView: View {
    let event: EventItem // EventItem model for event details
    @Environment(\.presentationMode) var presentationMode
    @State private var message: String = "" // State for holding success/error message
    @State private var showAlert = false // State for showing the alert
    
    var body: some View {
        VStack(alignment: .leading) {
            // Back button and title
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss() // Dismiss the current view
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                }
                .padding(.trailing, 8)
                
                // Event title
                Text("Detalles de evento")
                    .font(.title2)
                    .bold()
                
                Spacer()
            }
            .padding()
            .background(Color(Constants.Colors.primary))
            .foregroundColor(.white)
            
            Text(event.title)
                .font(.title)
                .bold()
                .padding(.top, 20)
                .padding(.leading, 20)
            
            // Image and Available spots section
            HStack {
                // Placeholder for event image
                Image("family_trip") // Replace with a dynamic image if you have one
                    .resizable()
                    .frame(width: 200, height: 200)
                    .cornerRadius(10)
                
                Spacer()
                
                // Available spots information
                Text("Quedan \(event.availableSpots) cupos disponibles")
                    .font(.headline)
                    .bold()
                    .foregroundColor(.black)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 20)
            
            // Event details section
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Lugar:").bold()
                        Text(event.location)
                    }
                    .font(.body)
                    .foregroundColor(.black)
                    
                    HStack {
                        Text("Fecha:").bold()
                        Text(event.eventDate)
                    }
                    .font(.body)
                    .foregroundColor(.black)
                    
                    HStack {
                        Text("Impartido por:").bold()
                        Text(event.organizer)
                    }
                    .font(.body)
                    .foregroundColor(.black)
                }
                
                Divider()
                
                Text("Descripción")
                    .font(.headline)
                    .padding(.top)
                
                Text(event.description)
                    .font(.body)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Reserve Button
            Button(action: {
                registrarParticipacion(userID: userID, idEvento: event.id, sessionKey: sessionKey) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let successMessage):
                            message = successMessage
                            showAlert = true
                            // After successful registration, dismiss the view
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                presentationMode.wrappedValue.dismiss()
                            }
                        case .failure(let error):
                            message = "Error: \(error.localizedDescription)"
                            showAlert = true
                        }
                    }
                }
            }) {
                Text("Reservar Lugar")
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Resultado"), message: Text(message), dismissButton: .default(Text("OK")))
            }
        }
        .navigationBarHidden(true)
    }
}


