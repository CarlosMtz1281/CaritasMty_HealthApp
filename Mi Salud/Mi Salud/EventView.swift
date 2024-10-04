//
//  EventView.swift
//  Mi Salud
//
//  Created by Carlos Mtz on 03/10/24.
//

import SwiftUI

struct EventListView: View {
    // Sample data for events
    let events: [Event] = [
        Event(title: "Charla Nutricion", date: "29 Noviembre 2024", location: "Oficinas Caritas San Jose de Uro", availableSpots: 20, description: "Lorem Ipsum etsun dolorem, Sancti Sacramentum...", organizer: "Caritas Salud", eventDate: "15 de Enero 2025 8:00 AM"),
        Event(title: "Taller de Yoga", date: "10 Diciembre 2024", location: "Parque Fundidora", availableSpots: 15, description: "Una sesión de yoga al aire libre para relajarse...", organizer: "Yoga Studio", eventDate: "10 de Diciembre 2024 9:00 AM"),
        Event(title: "Clínica de Cardiología", date: "5 Enero 2025", location: "Hospital General Monterrey", availableSpots: 10, description: "Clínica gratuita de prevención y detección de enfermedades cardiacas.", organizer: "Hospital General", eventDate: "5 de Enero 2025 10:00 AM")
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                // Header section
                HStack {
                    Text("Próximos eventos")
                        .font(.largeTitle)
                        .bold()
                        .padding(.horizontal)
                    
                    Spacer()
                }
                .padding()
                .background(Color(Constants.Colors.primary))
                .foregroundColor(.white)
                
                // Scrollable list of events
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        
                        // Events section
                        VStack(alignment: .leading, spacing: 16) {
                            // Title for user's events
                            Text("Mis eventos")
                                .font(.title)
                                .bold()
                                .padding(20)
                            
                            // Display user's events (Here, we show a few hardcoded events)
                            ForEach(events) { event in
                                EventRow(event: event)
                                    .padding(.horizontal)
                            }
                            
                            Divider()
                                .padding(.horizontal)
                            
                            // Title for upcoming events
                            Text("Próximos eventos")
                                .font(.title)
                                .bold()
                                .padding(20)
                            
                            // Display upcoming events (Using the same sample data)
                            ForEach(events) { event in
                                EventRow(event: event)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
        }
    }
}

struct EventRow: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading) {
            // Event title and date
            HStack{
                HStack{
                    VStack(alignment: .leading){
                        
                        Text(event.title)
                            .font(.title2)
                        
                        Text(event.date)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                
                
                Spacer()
                // "Ver Más" button and navigation
                NavigationLink(destination: EventDetailView(event: event)) {
                    Text("Ver Más")
                        .frame(width:100, height: 45)
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 16)
                        .background(Color.orange)
                        .cornerRadius(8)
                }
                .padding(.top, 8)
            }.frame(height: 60)
                .padding(15)
            
            
            
        }
        .padding(.vertical, 10)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

#Preview {
    EventListView()
}
