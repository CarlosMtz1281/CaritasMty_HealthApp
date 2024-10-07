//
//  EventDetailView.swift
//  Mi Salud
//
//  Created by Carlos Mtz on 03/10/24.
//

import SwiftUI

struct EventDetailView: View {
    let event: EventItem // Use EventItem instead of Event
    @Environment(\.presentationMode) var presentationMode
    
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
                
                // Event title (match the mockup)
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
                        Text(event.location) // Update with real location data if available in EventItem
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
                        Text(event.organizer) // Update with real organizer data if available
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
                // Action for reserving
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
        }
        .navigationBarHidden(true)  
    }
}


