//
//  QRView.swift
//  Mi Salud
//
//  Created by Germán Salas on 22/08/24.
//

import SwiftUI
import CoreImage.CIFilterBuiltins



struct DottedRoundedSquareView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .stroke(style: StrokeStyle(lineWidth: 4, dash: [10]))
            .frame(width: 270, height: 270)
            .foregroundColor(Color(Constants.Colors.primary))
            .padding()
    }
}

struct QRView: View {
    @State private var inputText = "\(UserDefaults.standard.integer(forKey: "user_id") > 0 ? UserDefaults.standard.integer(forKey: "user_id") : 1)" // Valor definido por el administrador
    @State private var qrCodeImage: UIImage?
    
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    var body: some View {
        NavigationView {
            
            HStack{
                VStack {
                    VStack {
                        HStack {
                            VStack(alignment: .leading){
                                Text("Tu código")
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
                        
                        
                    }
                    .padding(.bottom,20)
                    .frame(maxWidth: .infinity)
                    .frame(height: UIScreen.main.bounds.height * 0.20)
                    .background(Color(Constants.Colors.primary))
                    .clipShape(RoundedCornersShape(corners: [.bottomLeft, .bottomRight], radius: 20))
                    Spacer()
                    ZStack {
                        VStack {
                            // Cambiar el color de la imagen "puntos" utilizando un .foregroundColor o un .colorMultiply
                            DottedRoundedSquareView()
                        }
                        
                        VStack {
                            // Mostrar imagen QR si existe
                            if let qrImage = qrCodeImage {
                                Image(uiImage: qrImage)
                                    .resizable()
                                    .interpolation(.none)
                                    .scaledToFit()
                                    .frame(width: 230, height: 330)
                                    .padding(1)
                            } else {
                                Text("Generando código QR...")
                                    .padding()
                            }
                        }
                    }
                    Spacer()
                }
                .onAppear(perform: generateQRCode) // Generar QR en cuanto aparece la vista
            }
            .padding(0)
            .edgesIgnoringSafeArea(.top)
            .background(.white)
        }
    }
    
    // Función para generar el código QR basado en el texto predefinido
    func generateQRCode() {
        guard let data = inputText.data(using: .ascii) else { return }
        filter.setValue(data, forKey: "inputMessage")
        
        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                let uiImage = UIImage(cgImage: cgimg)
                qrCodeImage = uiImage
            }
        }
    }
}

#Preview {
    QRView()
}
