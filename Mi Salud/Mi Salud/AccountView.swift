//
//  AccountView.swift
//  Mi Salud
//
//  Created by Nico Trevino on 22/08/24.
//

import SwiftUI

struct AccountView: View {
    var body: some View {
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

                Button(action: {
                }) {
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
    
    func signOut() {
        guard let url = URL(string: "http://localhost:8000/users/signOut") else { return }
        
        // obtener
        guard let sessionKey = UserDefaults.standard.string(forKey: "session_key"),
              let userId = UserDefaults.standard.string(forKey: "user_id") else {
            print("Error: No session key or user ID found.")
            return
        }
        
        // request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.setValue(sessionKey, forHTTPHeaderField: "key")
        request.setValue(userId, forHTTPHeaderField: "user_id")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error:", error?.localizedDescription ?? "Unknown error")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("Signed out successfully")
                
                // limpiar defaults
                UserDefaults.standard.removeObject(forKey: "user_id")
                UserDefaults.standard.removeObject(forKey: "session_key")
                
                // cerrar app
                DispatchQueue.main.async {
                    exit(0)
                }
                
            } else {
                print("Error signing out: \(String(describing: error?.localizedDescription))")
            }
        }.resume()
    }
}

#Preview {
    AccountView()
}
