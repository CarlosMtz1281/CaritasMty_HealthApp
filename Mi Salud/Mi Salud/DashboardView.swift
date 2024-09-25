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

//API CALLS

// Fetch current points using the hardcoded session key


struct DashboardView: View {
    @State private var points: Int = 0 // para puntos
    @State private var catalogItems: [CatalogItem] = [] // para catalogo
    @State private var currentImagePath: String?

    var body: some View {
        NavigationView{
        VStack(spacing: 0) {
            ScrollView(.vertical, showsIndicators: false) {
                // Header
                VStack {
                    // Salute
                    VStack{
                        HStack {
                            if let currentImagePath = currentImagePath {
                                Image(currentImagePath)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                    .foregroundColor(Color(Constants.Colors.accent))
                            } else {
                                Circle()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(Color(Constants.Colors.accent))
                            }
                            VStack(alignment: .leading) {
                                Text("Hola, Carlos!")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                            Spacer()
                        }
                        .padding()
                        .padding(.top, 70)

                        // Points section
                
                            // Points section
                            NavigationLink(destination: PointsHistoryView()) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("\(points) puntos")
                                            .font(.title2)
                                            .foregroundStyle(.black)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                            }
                    
                            .padding()
                            .background(Color.white)
                            .cornerRadius(20)
                            .padding(.horizontal, 30)
                            .padding(.bottom, 30)
                            .shadow(radius: 2)
                        }
                    .padding(.bottom, 20)
                    .frame(maxWidth: .infinity)
                    .frame(height: UIScreen.main.bounds.height * 0.26)
                    .background(Color(Constants.Colors.primary))
                    .clipShape(RoundedCornersShape(corners: [.bottomLeft, .bottomRight], radius: 20))

                    // Tienda section
                    VStack(alignment: .leading) {
                        Text("Tienda")
                            .font(.title)
                            .padding(.bottom, 20)
                            .padding()

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(catalogItems, id: \.id) { item in // Assuming CatalogItem has a unique 'id'
                                    VStack {
                                        Image("family_trip") // Assuming the image is static
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
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                        }
                        .frame(height: 150) // Set a fixed height for the ScrollView to avoid it expanding vertically too much
                    }
                    .padding(.bottom, 50)

                    // Último examen clinico
                    VStack(alignment: .leading) {
                        Text("Último examen de salud")
                            .font(.title2)
                            .padding(.leading)

                        HStack {
                            VStack(alignment: .leading) {
                                Text("Presion Arterial")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                Text("150 / 85")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("19/02/2024")
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

                    // Eventos section
                    VStack(alignment: .leading) {
                        Text("Próximos Eventos")
                            .font(.title)
                            .padding(.bottom, 20)
                            .padding()

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(0..<8) { _ in
                                    VStack {
                                        Image("family_trip") // Using the same image
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
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                        }
                        .frame(height: 150) // Set a fixed height for the ScrollView to avoid it expanding vertically too much
                    }
                    .padding(.bottom, 50)

                    Spacer()
                    Spacer()
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white) // Optional: to set a default background color
            .edgesIgnoringSafeArea(.top) // Ensures the view extends to the top edge
            .onAppear {
                fetchCurrentPoints(userID: userID, sessionKey: sessionKey) { fetchedPoints in
                    self.points = fetchedPoints

                // Now that we have fetched points, we can fetch the catalog
                fetchCatalog(sessionKey: sessionKey) { items in
                    self.catalogItems = items
                    
                    fetchProfilePicture(userID: userID, sessionKey: sessionKey) { path in
                        self.currentImagePath = path
                    }
                }
            }
        }
        }
        
    }
}
}

#Preview {
    DashboardView()
}
