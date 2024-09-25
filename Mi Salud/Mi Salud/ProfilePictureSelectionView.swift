//
//  ProfilePictureSelectionView.swift
//  Mi Salud
//
//  Created by Carlos Mtz on 24/09/24.
//

import SwiftUI

struct ProfilePictureSelectionView: View {
    
    let imageNames = ["profile1", "profile2", "profile3", "profile4", "profile5", "profile6", "profile7", "profile8", "profile9"]
    @State private var selectedImage: String? = nil
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            VStack{
                Spacer()
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.title2)
                            .bold()
                        
                    }
                    .padding()
                    .background(Color(Constants.Colors.primary))
                    .foregroundColor(.white)

                    
                    Text("Configuracion de cuenta")
                        .font(.system(size: 24))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.trailing)
                    
                    Spacer()
                }
                .padding()
                .foregroundColor(.white)
            }
            .background(Color(Constants.Colors.primary))
            .frame(height: 130)
            
            // Main title
            Text("Elige tu nueva foto de perfil")
                .font(.system(size: 25))
                .bold()
                .padding(.top, 40)
                .padding(.horizontal, 45)
                .multilineTextAlignment(.center)
            
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
                guard let selectedImage = selectedImage else {
                    print("No image selected")
                    return
                }
                
                updateProfilePicture(userID: userID, imagePath: selectedImage, sessionKey: sessionKey) { result in
                    switch result {
                    case .success(let message):
                        print(message)
                    case .failure(let error):
                        print("Failed to update profile picture: \(error.localizedDescription)")
                    }
                }
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
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.top)
        .background(Color.white) // Set the background color
    }
}

struct ProfilePictureSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePictureSelectionView()
    }
}
