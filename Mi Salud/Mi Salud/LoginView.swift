//
//  LoginView.swift
//  Mi Salud
//
//  Created by Nico Trevino on 26/08/24.
//

import SwiftUI

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @Binding var selectedTab: Int
    //@State private var isLoggedIn: Bool = false
    @State private var username = ""
    @State private var password = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack {
            Spacer()
            
            Image("logocaritas")
                .padding(.top, 30)
                .padding(.bottom, 60)
            
            VStack{
                HStack{Spacer()}
                
                // iniciar sesion
                Text("Iniciar Sesión")
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                    .font(.largeTitle)
                    .foregroundColor(.PANTONE_302_C)
                    .bold()
                
                VStack(alignment: .leading){
                    // Usuario
                    Text("Usuario")
                        .padding(.horizontal, 23)
                        .padding(.bottom, -5)
                        .font(.title)
                        .bold()
                    
                    TextField("", text: $username)
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color(red: 198/255, green: 198/255, blue: 198/255)))
                        .foregroundColor(.black)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                        .autocapitalization(.none) // quitar caps
                    
                    // Contra
                    Text("Contraseña")
                        .padding(.horizontal, 23)
                        .padding(.bottom, -5)
                        .padding(.top, 15)
                        .font(.title)
                        .bold()
                    
                    SecureField("", text: $password)
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color(red: 198/255, green: 198/255, blue: 198/255)))
                        .foregroundColor(.black)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                }
                
                
                // boton normal
                Button("Ingresar") {
                    // Perform login logic here
                    if username == "A" && password == "1234" {
                        isLoggedIn = true
                    } else {
                        loginUser(correo: username, password: password)
                    }
                }
                //.frame(width: 250, height: 50)
                .frame(width: 265, height: 65)
                .foregroundColor(.white)
                .font(.title2)
                .bold()
                .background(.PANTONE_320_C)
                .cornerRadius(5)
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Login Failed"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                //.padding(.top, 35)
                .padding(.top, 55)
                .shadow(radius: 5)
                
                /*
                 Divider()
                 .padding(.top, 15)
                 .padding(.bottom, 15)
                 .padding(.horizontal, 20)
                 
                 // boton google
                 
                 Button(action: {/*aun nada*/}) {
                 HStack {
                 Image("logogoogle")
                 .resizable()
                 .scaledToFit()
                 .frame(width: 24, height: 24)
                 
                 Text("Ingresar con Google")
                 .font(.title3)
                 .bold()
                 }
                 }
                 .frame(width: 250, height: 45)
                 .foregroundColor(.black)
                 .font(.title3)
                 .bold()
                 .background(.white)
                 .cornerRadius(5)
                 .shadow(radius: 5)
                 */
                
                Spacer()
            }
            .padding()
            .background(Color(red: 244/255, green: 244/255, blue: 244/255))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .background(.PANTONE_302_C)
        .edgesIgnoringSafeArea(.bottom)
    }
    // funcion de login
    func loginUser(correo: String, password: String) {
        let concUrl = Constants.path + "/users/login"

        guard let url = URL(string: concUrl) else { return }
        
        let body: [String: Any] = ["correo": correo, "password": password]
        let jsonData = try? JSONSerialization.data(withJSONObject: body)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self.alertMessage = "Error de conexion: No se pudo establecer conexion con el servidor"
                    self.showingAlert = true
                }
                return
            }
            
            // Print the raw response for debugging
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }
            print("Raw Response: \(String(describing: String(data: data, encoding: .utf8)))")
            
            do {
                // Decode the JSON response
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    // Check if there's an error message
                    if let errorMessage = jsonResponse["error"] as? String {
                        DispatchQueue.main.async {
                            self.alertMessage = errorMessage  // Show the error message (e.g., "Credenciales inválidas")
                            self.showingAlert = true
                        }
                    } else if let userId = jsonResponse["user_id"] as? Int ?? Int(jsonResponse["user_id"] as? String ?? ""),
                              let sessionKey = jsonResponse["key"] as? String,
                              let tags = jsonResponse["tags"] as? [[String: Any]] {
                        
                        // Store user_id and session_key in UserDefaults
                        UserDefaults.standard.set(userId, forKey: "user_id")
                        UserDefaults.standard.set(sessionKey, forKey: "session_key")
                        
                        // Store tags in UserDefaults (or handle them as needed)
                        let formattedTags = tags.map { tag in
                            if let nombre = tag["nombre"] as? String, let veces_usado = tag["veces_usado"] as? Int {
                                return "\(nombre): \(veces_usado)"
                            }
                            return ""
                        }
                        
                        UserDefaults.standard.set(formattedTags, forKey: "user_tags")
                        
                        // Debug: Print the tags
                        print("User Tags: \(formattedTags)")
                        
                        // Update the login state
                        DispatchQueue.main.async {
                            self.isLoggedIn = true
                            self.selectedTab = 0
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.alertMessage = "Unexpected response format."
                            self.showingAlert = true
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.alertMessage = "Failed to decode response."
                    self.showingAlert = true
                }
            }
        }.resume()
    }
}
struct LoginView_Previews: PreviewProvider {
    @State static var isLoggedIn: Bool = false
    @State static var selectedTab: Int = 0

    static var previews: some View {
        LoginView(isLoggedIn: $isLoggedIn, selectedTab: $selectedTab)
    }
}
