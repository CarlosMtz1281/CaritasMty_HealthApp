//
//  LoginView.swift
//  Mi Salud
//
//  Created by Nico Trevino on 26/08/24.
//

import SwiftUI

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    //@State private var isLoggedIn: Bool = false
    @State private var username = ""
    @State private var password = ""
    @State private var showingAlert = false

    var body: some View {
        VStack {
            Spacer()
            
            Image("logocaritas")
                .padding(.top, 30)
                .padding(.bottom, 60)
            
            VStack{
                HStack{Spacer()}
                
                // iniciar sesion
                Text("Iniciar Sesion")
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
                        showingAlert = true
                    }
                }
                .frame(width: 250, height: 50)
                .foregroundColor(.white)
                .font(.title2)
                .bold()
                .background(.PANTONE_320_C)
                .cornerRadius(5)
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Login Failed"), message: Text("Invalid username or password"), dismissButton: .default(Text("OK")))
                }
                .padding(.top, 35)
                .shadow(radius: 5)
                
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
                
                
                Spacer()
            }
            .padding()
            .background(Color(red: 244/255, green: 244/255, blue: 244/255))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .background(.PANTONE_302_C)
        .edgesIgnoringSafeArea(.bottom)
    }
}


//#Preview {
//   LoginView()
//}
