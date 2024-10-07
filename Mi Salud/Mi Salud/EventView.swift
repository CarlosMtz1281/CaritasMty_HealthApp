import SwiftUI

struct EventListView: View {
    @State private var myEvents: [EventItem] = []
    @State private var proxEvents: [EventItem] = []
    @State private var myChallenges: [ChallengeItem] = []
    @State private var challenges: [ChallengeItem] = []
    
    @State private var selectedTab: Tab = .events

    enum Tab {
        case events
        case challenges
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Eventos y Retos")
                        .font(.largeTitle)
                        .bold()
                        .padding(16)
                    
                    Spacer()
                }
                .padding()
                .background(Color(Constants.Colors.primary))
                .foregroundColor(.white)
                
                // Tab Selector using Picker
                Picker("Seleccione una pestaña", selection: $selectedTab) {
                    Text("Eventos").tag(Tab.events)
                        .font(.title2)
                    Text("Retos").tag(Tab.challenges)
                        .font(.title2)

                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if selectedTab == .events {
                            Text("Mis eventos")
                                .font(.title)
                                .bold()
                                .padding(.leading, 20)
                                .padding(.top, 5)

                            ForEach(myEvents) { event in
                                EventRow(event: event)
                                    .padding(.horizontal)
                            }
                            
                            Divider()
                                .padding(.horizontal)
                            
                            Text("Próximos eventos")
                                .font(.title)
                                .bold()
                                .padding(.leading, 20)
                                .padding(.top, 20)
                            
                            ForEach(proxEvents) { event in
                                EventRow(event: event)
                                    .padding(.horizontal)
                            }
                        } else {
                            Text("Mis Retos")
                                .font(.title)
                                .bold()
                                .padding(.leading, 20)
                                .padding(.top, 5)

                            ForEach(myChallenges) { challenge in
                                ChallengeRow(challenge: challenge)
                                    .padding(.horizontal)
                            }
                            
                            Divider()
                                .padding(.horizontal)
                            
                            Text("Retos Disponibles")
                                .font(.title)
                                .bold()
                                .padding(.leading, 20)
                                .padding(.top, 20)

                            ForEach(challenges) { challenge in
                                ChallengeRow(challenge: challenge)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.bottom, 30)
                }
                .onAppear {
                    fetchEvents(sessionKey: sessionKey) { fetchedEvents in
                        self.proxEvents = fetchedEvents
                        
                        fetchMyEvents(sessionKey: sessionKey) { fetchMyEvents in
                            self.myEvents = fetchMyEvents
                            print(myEvents)
                            
                            fetchChallenges(sessionKey: sessionKey) { fetchedChallenges in
                                self.challenges = fetchedChallenges
                                
                                fetchMyChallenges(userId: userID, sessionKey: sessionKey){ fetchedMyChallenges in self.myChallenges = fetchedMyChallenges
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct EventRow: View {
    let event: EventItem
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text(event.title)
                        .font(.title2)
                    
                    Text(event.eventDate)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                
                NavigationLink(destination: EventDetailView(event: event)) {
                    Text("Ver Más")
                        .frame(width: 100, height: 45)
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 16)
                        .background(Color.orange)
                        .cornerRadius(8)
                }
                .padding(.top, 8)
            }
            .frame(height: 60)
            .padding(15)
        }
        .padding(.vertical, 10)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct ChallengeRow: View {
    let challenge: ChallengeItem
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                    Text(challenge.title)
                        .font(.title2)
                    
                    Spacer()
                    
                    NavigationLink(destination: ChallengeDetailView(challenge: challenge)) {
                        Text("Ver Más")
                            .frame(width: 100, height: 45)
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 16)
                            .background(Color.orange)
                            .cornerRadius(8)
                    }
                    .padding(.top, 8)
                }
                Spacer()
            }
            .padding(15)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 2)
        }
    }


#Preview {
    EventListView()
}
