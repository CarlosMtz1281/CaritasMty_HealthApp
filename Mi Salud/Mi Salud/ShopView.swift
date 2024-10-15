//
//  ShopView.swift
//  Mi Salud
//
//  Created by Germán Salas on 22/08/24.
//

import SwiftUI

struct ShopCard: View {
    var image: String
    var name: String
    var description: String
    var points: Int
    var catalogItem: CatalogItem
    var userPoints: Int

    var body: some View {
        HStack{
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 130)
                .clipped()
                .padding(.trailing, 10)

            VStack(alignment: .leading) {
                Text(name)
                    .font(.system(size: 21))
                    .bold()
                    .lineLimit(2)
                    .layoutPriority(1)
                    .padding(.bottom, 3)

                Text(description)
                    .font(.system(size: 13.5))
                    .foregroundColor(.gray)
                    .lineLimit(2)
                    .padding(.bottom, 10)

                Text("\(points) pts")
                    .font(.system(size: 20))
                    .bold()
                    .padding(.bottom, 10)
                    
                    

                NavigationLink(destination: MasInformacion(catalogItem: catalogItem, userPoints: userPoints)) {
                    Text("Más Detalles")
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .bold()
                }
                .frame(maxWidth: .infinity)
                .background(Color(Constants.Colors.accent))
                .cornerRadius(100)
            }
            .padding(.trailing, 15)
            .padding(.vertical, 15)
            
        }
        .frame(width: 325)
        .background(Color.white)
        .cornerRadius(5)
        .shadow(radius: 2)
    }
}

struct ShopView: View {
    @State private var isButtonVisible = true
    @State private var lastScrollOffset: CGFloat = 0
    private let scrollThreshold: CGFloat = 50
    @State private var points: Int = 0
    @State private var catalogItems: [CatalogItem] = []
    @State private var userName: String = "Usuario"
    @State private var showAlert = false
    @State private var alertMessage = ""

    
    init() {
        UIScrollView.appearance().bounces = false
    }
    
    var body: some View {
        NavigationStack{
            VStack(spacing: 0) {
                VStack {
                    HStack {
                        VStack(alignment: .leading){
                            Text("Catalogo")
                                .font(.title)
                                .foregroundColor(.white)
                                .bold()
                        }
                        .padding(.leading, 30)
                        .frame(width: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                        Spacer()
                    }
                    .padding()
                    .padding(.top, 70)
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                    
                    NavigationLink(destination: PointsHistoryView(points: points)) {
                        HStack(){
                            VStack(alignment: .leading){
                                Text("\(points) puntos")
                                    .font(.title2)
                                    .bold()
                                    .foregroundStyle(Color.black)
                            }
                            .padding(.leading, 30)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .padding(.trailing, 15)
                                .foregroundStyle(Color.black)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(20)
                        .padding(.horizontal,30)
                        .padding(.bottom, 30)
                        .shadow(radius: 2)
                    }
                }
                .padding(.bottom,20)
                .frame(maxWidth: .infinity)
                .frame(height: UIScreen.main.bounds.height * 0.26)
                .background(Color(Constants.Colors.primary))
                .clipShape(RoundedCornersShape(corners: [.bottomLeft, .bottomRight], radius: 20))
                
                if isButtonVisible {
                    HStack(){
                        Spacer()
                        Button(action: {
                            
                        }) {
                            HStack {
                                Image(systemName: "line.horizontal.3.decrease.circle")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                Text("Filtros")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 25)
                            .background(Color(Constants.Colors.primary))
                            .cornerRadius(100)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                    }
                    .frame(width: .infinity)
                    .padding(.horizontal, 20)
                    .background(Color.clear)
                }
                
                ScrollViewReader {proxy in
                    ScrollView(.vertical, showsIndicators: false){
                        GeometryReader { geometry in
                            Color.clear
                                .preference(key: ScrollOffsetKey.self, value: geometry.frame(in: .global).minY)
                                .onPreferenceChange(ScrollOffsetKey.self) { value in
                                    let scrollDifference = value - lastScrollOffset
                                    if abs(scrollDifference) > scrollThreshold {
                                        if value < lastScrollOffset {
                                            withAnimation {
                                                isButtonVisible = false
                                            }
                                        } else if value > lastScrollOffset {
                                            withAnimation {
                                                isButtonVisible = true
                                            }
                                        }
                                        lastScrollOffset = value
                                    }
                                }
                        }
                        .frame(height: 0)
                        
                        VStack(spacing: 20) {
                            ForEach(catalogItems) { item in
                                ShopCard(image: "family_trip", name: item.nombre, description: item.descripcion, points: Int(item.puntos) ?? 0, catalogItem: item, userPoints: points)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                Spacer()
                Spacer()
                Spacer()
            }
            .onAppear{
                fetchCurrentPoints(userID: userID, sessionKey: sessionKey) { fetchedName, fetchedPoints in
                    if fetchedPoints == 0 {
                        self.alertMessage = "Error: No se pudieron obtener los puntos."
                        self.showAlert = true
                    } else {
                        self.userName = fetchedName
                        self.points = fetchedPoints
                        
                        fetchCatalog(sessionKey: sessionKey) { items in
                            if items.isEmpty {
                                self.alertMessage = "Error: No hay artículos disponibles en el catálogo."
                                self.showAlert = true
                            } else {
                                self.catalogItems = items
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .edgesIgnoringSafeArea(.top)
            .padding(.bottom, 10)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Error de Conexión"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("Aceptar"))
                )
            }
        }
    }
}

struct ScrollOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    ShopView()
}
