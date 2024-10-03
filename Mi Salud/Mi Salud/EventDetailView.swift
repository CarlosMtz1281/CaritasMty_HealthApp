//
//  EventDetailView.swift
//  Mi Salud
//
//  Created by Carlos Mtz on 03/10/24.
//

import SwiftUI

struct EventDetailView: View {
    let event: Event
    @Environment(\.presentationMode) var presentationMode

    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
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
                
                // Header section
                Text("Proximos eventos")
                    .font(.title)
                    .bold()
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .background(Color(Constants.Colors.primary))
            .foregroundColor(.white)
            
            // Available spots info
            HStack {
                Spacer()
                Text("Quedan \(event.availableSpots) cupos disponibles")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.black)
                Spacer()
            }
            .padding(.vertical)
            
            // Event details
            VStack(alignment: .leading) {
                Text("Lugar: \(event.location)")
                    .font(.body)
                
                Text("Fecha: \(event.eventDate)")
                    .font(.body)
                
                Text("Impartido por: \(event.organizer)")
                    .font(.body)
                
                Text("• Descripcion")
                    .font(.headline)
                    .padding(.top)
                
                Text(event.description)
                    .font(.body)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            
            // Reserve button
            Spacer()
            
            Button(action: {
                // Action for reserving
            }) {
                Text("Reservar Lugar")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
        }
        
    }
}

