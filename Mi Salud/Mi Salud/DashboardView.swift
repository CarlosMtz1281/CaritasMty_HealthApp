//
//  DashboardView.swift
//  Mi Salud
//
//  Created by Germán Salas on 22/08/24.
//

import SwiftUI

struct RoundedCornersShape: Shape {
    var corners: UIRectCorner
    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// Fetch random image for events
func randomImage() -> Image {
    let images = ["Card1", "Card2", "Card3"]
    let randomIndex = Int.random(in: 0..<images.count)
    return Image(images[randomIndex])
}

// Fetch random image name for items
func randomImageName() -> String {
    let images = ["image1", "image2", "image3"]
    let randomIndex = Int.random(in: 0..<images.count)
    return images[randomIndex]
}

struct DashboardView: View {
    @State private var points: Int = 0
    @State private var catalogItems: [CatalogItem] = []
    @State private var currentImagePath: String?
    @State private var userName: String = "Usuario"
    @State private var bloodPressureData: [BloodPressureDataPoint] = []

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView(.vertical, showsIndicators: false) {
                    // Header Section
                    headerSection
                    
                    // Catalog Section
                    catalogSection
                    
                    // Last Health Exam Section
                    healthExamSection
                    
                    // Upcoming Events Section
                    eventsSection
                }
                .background(Color.white)
                .edgesIgnoringSafeArea(.top)
                .onAppear(perform: loadData)
            }
        }
    }

   
    private var headerSection: some View {
        VStack {
            HStack {
                if let currentImagePath = currentImagePath {
                    Image(currentImagePath)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .frame(width: 50, height: 50)
                        .foregroundColor(Color(Constants.Colors.accent))
                }
                VStack(alignment: .leading) {
                    Text("Hola, \(userName)")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                Spacer()
            }
            .padding()
            .padding(.top, 70)
            
            NavigationLink(destination: PointsHistoryView(points: points)) {
                HStack {
                    Text("\(points) puntos")
                        .font(.title2)
                        .foregroundColor(.black)
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding()
                .background(Color.white)
                .cornerRadius(20)
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
                .shadow(radius: 2)
            }
        }
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity)
        .frame(height: UIScreen.main.bounds.height * 0.26)
        .background(Color(Constants.Colors.primary))
        .clipShape(RoundedCornersShape(corners: [.bottomLeft, .bottomRight], radius: 20))
    }

    private var catalogSection: some View {
        VStack(alignment: .leading) {
            Text("Catálogo")
                .font(.title)
                .padding(.bottom, 0)
                .padding()

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(catalogItems, id: \.id) { item in
                        NavigationLink(destination: ShopView()) {
                            VStack {
                                Image(item.imagen) // Assuming the image is static
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 150, height: 100)
                                    .clipped()

                                VStack(alignment: .leading) {
                                    Text(item.nombre) // Display the item's name
                                        .font(.headline)
                                    Text("\(item.puntos) pts") // Assuming `puntos` is a property in CatalogItem
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                .padding(8)
                            }
                            .frame(width: 200)
                            .frame(height: 200)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 10)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .frame(height: 230)
            }
            .padding(.bottom, 0)
        }
    }

    private var healthExamSection: some View {
        VStack(alignment: .leading) {
            Text("Último examen de salud")
                .font(.title2)
                .padding(.leading)

            NavigationLink(destination: HealthView(CurrentImagePath: currentImagePath ?? "")) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Presión Arterial")
                            .font(.title2)
                            .foregroundColor(.white)
                        Text("\(String(format: "%.0f", bloodPressureData.first?.systolic ?? 0)) / \(String(format: "%.0f", bloodPressureData.first?.diastolic ?? 0))")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("\(bloodPressureData.first?.time ?? "No Data")")
                            .font(.subheadline)
                            .foregroundColor(.white)
                        Text("San José del Uro")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                }
                .frame(height: 80)
                .padding()
                .background(Color.teal)
                .cornerRadius(10)
                .padding(.horizontal)
            }
        }
    }

    private var eventsSection: some View {
        VStack(alignment: .leading) {
            Text("Próximos Eventos")
                .font(.title)
                .padding(.bottom, 0)
                .padding()

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(0..<8) { _ in
                        NavigationLink(destination: EventListView()) {
                            VStack {
                                randomImage() // Using the same image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 150, height: 100)
                                    .clipped()

                                VStack(alignment: .leading) {
                                    Text("Platica Nutrición")
                                        .font(.headline)
                                    Text("19/09/2024")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                .padding(8)
                            }
                            .frame(width: 180)
                            .frame(height: 200)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 10)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 0)
                .frame(height: 230)
            }
            .padding(.bottom, 50)
        }
    }

    private func loadData() {
        fetchCurrentPoints(userID: userID, sessionKey: sessionKey) { fetchedName, fetchedPoints in
            self.userName = fetchedName
            self.points = fetchedPoints

            fetchCatalog(sessionKey: sessionKey) { items in
                self.catalogItems = items

                fetchProfilePicture(userID: userID, sessionKey: sessionKey) { path in
                    self.currentImagePath = path
                    fetchMedicionesSalud(userID: userID, sessionKey: sessionKey) { glucosa, presionArterial, ritmoCardiaco, userInfo in
                        self.bloodPressureData = presionArterial
                    }
                }
            }
        }
    }
}

#Preview {
    DashboardView()
}
