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
                    .font(.title2)
                    .bold()
                    .lineLimit(2)
                    .layoutPriority(1)
                    .padding(.bottom, 3)

                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .lineLimit(2)
                    .padding(.bottom, 10)

                Text("\(points) pts")
                    .font(.system(size: 20))
                    .bold()
                    .padding(.bottom, 10)
                    
                    

                Button(action: {
                    
                }) {
                    Text("Redimir")
                        .font(.system(size: 10))
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
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
    
    init() {
      UIScrollView.appearance().bounces = false
   }
    
    var body: some View {
        VStack(spacing: 0) {
            VStack {
                HStack {
                    VStack(alignment: .leading){
                        Text("Tienda")
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
                
                HStack(){
                    VStack(alignment: .leading){
                        Text("1,500 puntos")
                            .font(.title2)
                            .bold()
                    }
                    .padding(.leading, 30)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .padding(.trailing, 15)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(20)

                .padding(.horizontal,30)
                .padding(.bottom, 30)
                .shadow(radius: 2)
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
                        ShopCard(image: "family_trip", name: "Viaje con tu familia", description: "Un viaje promocional con tu familia", points: 10000000)
                        ShopCard(image: "family_trip", name: "Unos audifonos Sony", description: "Un viaje promocional con tu familia", points: 20000)
                        ShopCard(image: "family_trip", name: "Unos audifonos Sony", description: "Un viaje promocional con tu familia", points: 20000)
                        ShopCard(image: "family_trip", name: "Unos audifonos Sony", description: "Un viaje promocional con tu familia", points: 20000)
                        ShopCard(image: "family_trip", name: "Unos audifonos Sony", description: "Un viaje promocional con tu familia", points: 20000)
                        
                    }
                    .padding(.horizontal)
                }
            }
            Spacer()
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .edgesIgnoringSafeArea(.top)
        .edgesIgnoringSafeArea(.bottom)
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
