import SwiftUI
struct EventListView: View {
    @State private var myEvents: [EventItem] = []
    @State private var proxEvents: [EventItem] = []
    @State private var myChallenges: [ChallengeItem] = []
    @State private var challenges: [ChallengeItem] = []
    @State private var userTags: [String] = [] // Añadir los tags del usuario
    @State private var userTagFrequencies: [Int] = [] // Añadir las frecuencias de los tags del usuario
    
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
                                MyEventRow(event: event, userTags: userTags, userTagFrequencies: userTagFrequencies) // Pasamos también las frecuencias
                                    .padding(.horizontal)
                            }
                            
                            Divider()
                                .padding(.horizontal)
                            
                            Text("Próximos eventos")
                                .font(.title)
                                .bold()
                                .padding(.leading, 20)
                                .padding(.top, 20)
                            
                            // Filter out events that are already in 'myEvents'
                            ForEach(proxEvents.filter { proxEvent in
                                !myEvents.contains(where: { $0.id == proxEvent.id }) // Compare by ID
                            }) { event in
                                EventRow(event: event, userTags: userTags, userTagFrequencies: userTagFrequencies) // Pasamos también las frecuencias
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
                    // Obtener los tags y frecuencias del usuario desde UserDefaults
                    if let storedTagsAndFrequencies = UserDefaults.standard.array(forKey: "user_tags") as? [String] {
                        
                        // Inicializar listas vacías para tags y frecuencias
                        var extractedTags: [String] = []
                        var extractedFrequencies: [Int] = []
                        
                        // Iterar sobre los valores guardados en UserDefaults
                        for tagAndFrequency in storedTagsAndFrequencies {
                            let components = tagAndFrequency.components(separatedBy: ": ")
                            
                            // Asegurarse de que hay dos componentes: el tag y la frecuencia
                            if components.count == 2, let frequency = Int(components[1]) {
                                extractedTags.append(components[0])
                                extractedFrequencies.append(frequency)
                            }
                        }
                        
                        // Asignar los valores procesados a las variables de estado
                        self.userTags = extractedTags
                        self.userTagFrequencies = extractedFrequencies
                    }
                    
                    // Fetch events
                    fetchEvents(sessionKey: sessionKey) { fetchedEvents in
                        self.proxEvents = fetchedEvents
                        
                        fetchMyEvents(sessionKey: sessionKey) { fetchMyEvents in
                            self.myEvents = fetchMyEvents
                            //print(myEvents)
                            
                            fetchChallenges(sessionKey: sessionKey) { fetchedChallenges in
                                self.challenges = fetchedChallenges
                                
                                fetchMyChallenges(userId: userID, sessionKey: sessionKey){ fetchedMyChallenges in
                                    self.myChallenges = fetchedMyChallenges
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}





struct MyEventRow: View {
    let event: EventItem
    let userTags: [String] // Añadimos los tags del usuario
    let userTagFrequencies: [Int] // Frecuencias de uso de tags del usuario

    var body: some View {
        // Llamamos a la función para calcular la compatibilidad
        let compatibility = eventsCompatibility(userTags: userTags, userTagFrequencies: userTagFrequencies, eventTags: event.tags) ?? 0.0
        
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text(event.title)
                        .font(.title2)
                    
                    Text(event.eventDate)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("Compatibilidad: \(Int(compatibility * 100))%")
                        .font(.subheadline)
                        .foregroundColor(Color(Constants.Colors.PANTONE_320_C))
                }
                Spacer()
                
                NavigationLink(destination: EventDetailView(event: event, registered: true)) {
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

struct EventRow: View {
    let event: EventItem
    let userTags: [String] // Añadimos los tags del usuario
    let userTagFrequencies: [Int] // Frecuencias de uso de tags del usuario

    var body: some View {
        // Llamamos a la función para calcular la compatibilidad
        let compatibility = eventsCompatibility(userTags: userTags, userTagFrequencies: userTagFrequencies, eventTags: event.tags) ?? 0.0
        
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text(event.title)
                        .font(.title2)
                    
                    Text(event.eventDate)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("Compatibilidad: \(Int(compatibility * 100))%")
                        .font(.subheadline)
                        .foregroundColor(Color(Constants.Colors.PANTONE_320_C))
                }
                Spacer()
                
                NavigationLink(destination: EventDetailView(event: event, registered: false)) {
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
