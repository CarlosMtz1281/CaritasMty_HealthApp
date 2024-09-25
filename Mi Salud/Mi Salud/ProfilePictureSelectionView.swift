//
//  ProfilePictureSelectionView.swift
//  Mi Salud
//
//  Created by Carlos Mtz on 24/09/24.
//

import SwiftUI

struct ProfilePictureSelectionView: View {
    
    let imageNames = ["foto1", "foto2", "foto3", "foto4", "foto5", "foto6", "foto7"]
    @State private var selectedImage: String? = nil
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Spacer()
            // Top bar with back button
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss() // Back button action
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.title2)
                    
                }
                .padding()
                .background(Color(Constants.Colors.primary))
                .foregroundColor(.white)
                

                Spacer()
                
                Text("Configuracion de cuenta")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.trailing)
                
                Spacer()
            }
            .padding()
            .background(Color(Constants.Colors.primary))
            .foregroundColor(.white)
            
            // Main title
            Text("Elige tu nueva foto de perfil")
                .font(.headline)
                .padding(.top, 40)
            
            // Grid of images
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(imageNames, id: \.self) { imageName in
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .border(selectedImage == imageName ? Color.orange : Color.clear, width: 4)
                        .onTapGesture {
                            selectedImage = imageName
                        }
                }
            }
            .padding()
            
            Spacer()

            // Change Photo Button
            Button(action: {
                // Action to change the profile picture
            }) {
                Text("Cambiar Foto")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.orange)
                    .cornerRadius(25)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 10)

            // Cancel Button
            Button(action: {
                presentationMode.wrappedValue.dismiss() // Cancel action
            }) {
                Text("Cancelar")
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(25)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 30)
        }
        .edgesIgnoringSafeArea(.top)
        .background(Color.white) // Set the background color
    }
}

struct ProfilePictureSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePictureSelectionView()
    }
}
