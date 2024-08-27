//
//  SplashView.swift
//  Mi Salud
//
//  Created by Nico Trevino on 26/08/24.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
         VStack {
             HStack{Spacer()}
             Spacer()
             Image("logocaritas")
                 .padding()
                 .padding()
             
             
             HStack{
                 Spacer()
                 Text("Mi Salud")
                     .foregroundStyle(.white)
                     .bold()
                     .font(Font.custom("Arial", size:36))
                     .padding()
                 Spacer()
             }
             .background(.PANTONE_320_C)
             .padding(.bottom,50)
                 
             Spacer()
                 
         }.background(.PANTONE_302_C)
     }

}

#Preview {
    SplashView()
}
