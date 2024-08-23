//
//  ContentView.swift
//  Mi Salud
//
//  Created by Fernando Perez on 20/08/24.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    private var user = "user1"
    
    init() {
        UITabBar.appearance().unselectedItemTintColor = Constants.Colors.PANTONE_COOL_GRAY_8_C
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Image(systemName: "house")
                }.tag(0)
            HealthView()
                .tabItem {
                    Image(systemName: "stethoscope")
                }.tag(1)
            QRView()
                .tabItem {
                    Image(systemName: "qrcode")
                }.tag(2)
            ShopView()
                .tabItem {
                    Image(systemName: "bag")
                }.tag(3)
            AccountView()
                .tabItem {
                    Image(systemName: "person")
                }.tag(4)
        }
    }
}

#Preview {
    ContentView()
}
