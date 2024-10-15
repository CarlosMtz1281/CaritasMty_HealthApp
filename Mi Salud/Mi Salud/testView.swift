//
//  testView.swift
//  Mi Salud
//
//  Created by Nico Trevino on 13/10/24.
//
//import SwiftUI
//import CoreML
//
//
//struct testView: View {
//    // Safely unwrap the result of testModel()
//    var predicto: Double? {
//        return testModel()?.Similarity
//    }
//
//    var body: some View {
//        VStack {
//            Text("Testing Model Prediction")
//                .font(.title)
//
//            // Use optional binding to check if 'predicto' has a value
//            if let predicto = predicto {
//                Text("Compatibilidad predicha: \(predicto)")
//                    .font(.title2)
//                    .padding()
//                    .foregroundColor(.white)
//                    .background(Color.blue)
//                    .cornerRadius(10)
//            } else {
//                Text("Predicción no disponible")
//                    .font(.title2)
//                    .padding()
//                    .foregroundColor(.red)
//            }
//        }
//        .padding()
//    }
//}
//
//#Preview {
//    testView()
//}
