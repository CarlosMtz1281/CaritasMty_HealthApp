//
//  AccountView.swift
//  Mi Salud
//
//  Created by Nico Trevino on 22/08/24.
//

import SwiftUI

struct AccountView: View {
    @Binding var isLoggedIn: Bool
    var body: some View {
        NavigationView{
            VStack {
                HStack {
                    Text("PERFIL")
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 40)
                .padding(.bottom, 20)
                
                VStack(spacing: 0) {
                    Divider()
                    
                    NavigationLink(destination: ProfilePictureSelectionView()) {
                        HStack {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(Constants.Colors.primary), lineWidth: 2)
                                .frame(width: 55, height: 55)
                                .overlay(
                                    Image(systemName: "pencil.circle")
                                        .font(.system(size: 36))
                                        .foregroundColor(Color(Constants.Colors.primary))
                                )
                                .padding(.leading)
                            
                            Text("Modificar Cuenta")
                                .font(.headline)
                                .foregroundColor(.black)
                                .padding()
                            
                            Spacer()
                        }
                        .padding(.vertical)
                    }
                    
                    
                    Divider()
                    
                    Button(action: {
                    }) {
                        HStack {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(Constants.Colors.primary), lineWidth: 2)
                                .frame(width: 55, height: 55)
                                .overlay(
                                    Image(systemName: "bolt.circle")
                                        .font(.system(size: 36))
                                        .foregroundColor(Color(Constants.Colors.primary))
                                )
                                .padding(.leading)
                            
                            Text("Ver mis puntos")
                                .font(.headline)
                                .foregroundColor(.black)
                                .padding()
                            
                            Spacer()
                        }
                        .padding(.vertical)
                    }
                    
                    Divider()
                    
                    Button(action: {
                        signOut()
                    }) {
                        HStack {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(Constants.Colors.primary), lineWidth: 2)
                                .frame(width: 55, height: 55)
                                .overlay(
                                    Image(systemName: "arrowshape.turn.up.left.circle")
                                        .font(.system(size: 36))
                                        .foregroundColor(Color(Constants.Colors.primary))
                                )
                                .padding(.leading)
                            
                            Text("Cerrar Sesión")
                                .font(.headline)
                                .foregroundColor(.black)
                                .padding()
                            
                            Spacer()
                        }
                        .padding(.vertical)
                    }
                    
                    Divider()
                }
                .padding(.horizontal)
                Spacer()
            }
        }
    }
    
    func resetDefaults() {
        UserDefaults.standard.removeObject(forKey: "user_id")
        UserDefaults.standard.removeObject(forKey: "session_key")
        UserDefaults.standard.removeObject(forKey: "user_tags")
        
        // Sincroniza para asegurarte de que los cambios se guarden inmediatamente
        UserDefaults.standard.synchronize()
    }
    
    func signOut() {
        let concUrl = Constants.path + "/users/signOut"

        guard let url = URL(string: concUrl) else { return }
        
        // Retrieve sessionKey and userId from UserDefaults
        guard let sessionKey = UserDefaults.standard.string(forKey: "session_key"),
              let userId = UserDefaults.standard.string(forKey: "user_id") else {
            print("Error: No session key or user ID found.")
            return
        }
        
        // Debugging: Print the user_id and sessionKey
        print("Signing out with user_id: \(userId) and session_key: \(sessionKey)")
        
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add sessionKey and userId to headers as strings (with consistent header names)
        request.setValue(sessionKey, forHTTPHeaderField: "key")
        request.setValue(userId, forHTTPHeaderField: "User-Id")  // Notice the change here

        // Send the request
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error:", error?.localizedDescription ?? "Unknown error")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                // Debugging: Print the response status
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("Signed out successfully")
                
                // Clear UserDefaults
                resetDefaults()
                
                // Close app
                DispatchQueue.main.async {
                    isLoggedIn = false
                }
                
            } else {
                // Debugging: Print the raw response if sign-out fails
                print("Failed to sign out. Raw Response: \(String(data: data, encoding: .utf8) ?? "No response data")")
                print("Error signing out: \(String(describing: error?.localizedDescription))")
            }
        }.resume()
    }
}

#Preview {
    AccountView(isLoggedIn: .constant(true))
}
