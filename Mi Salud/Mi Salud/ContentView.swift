//
//  ContentView.swift
//  Mi Salud
//
//  Created by Fernando Perez on 20/08/24.
//

import SwiftUI

struct ContentView: View {
    @State private var showSplash = true
    @State private var isLoggedIn = false
    @State private var selectedTab = 0
    
    init() {
        UITabBar.appearance().unselectedItemTintColor = Constants.Colors.PANTONE_COOL_GRAY_8_C
    }
    
    var body: some View {
        Group {
            if showSplash {
                SplashView()
                    .transition(.opacity) // Optional: add transition animation
            } else if !isLoggedIn {
                LoginView(isLoggedIn: $isLoggedIn)
                //LoginView()
            } else {
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
                    AccountView(isLoggedIn: $isLoggedIn)
                        .tabItem {
                            Image(systemName: "person")
                        }.tag(4)
                }
            }
        }
        .onAppear {
            // Show splash screen for 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showSplash = false
                }
            }
        }
    }
}


//#Preview {
//    ContentView()
//}
