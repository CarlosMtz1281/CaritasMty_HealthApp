//
//  HealthView.swift
//  Mi Salud
//
//  Created by Germán Salas on 22/08/24.
//

import SwiftUI
import Charts

struct HealthView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var glucoseData: [HealthDataPoint] = []
    
    @State private var bloodPressureData: [BloodPressureDataPoint] = []
    
    @State private var heartRateData: [HealthDataPoint] = []
    
    var latestGlucose: Double {
        return glucoseData.first?.value ?? 0
    }
    
    var latestSystolic: Double {
        return bloodPressureData.first?.systolic ?? 0
    }
    
    var latestDiastolic: Double {
        return bloodPressureData.first?.diastolic ?? 0
    }
    
    var latestHeartRate: Double {
        return heartRateData.first?.value ?? 0
    }
    
    func calculateYAxisRange(for data: [HealthDataPoint]) -> ClosedRange<Double> {
        let minValue = data.map { $0.value }.min() ?? 0
        let maxValue = data.map { $0.value }.max() ?? 100
        let padding = (maxValue - minValue) * 0.3 // Add 10% padding to the range
        return (minValue - padding)...(maxValue + padding)
    }
    
    func calculateYAxisRangeBlood(for data: [BloodPressureDataPoint]) -> ClosedRange<Double> {
        // Extract systolic and diastolic values
        let systolicValues = data.map { $0.systolic }
        let diastolicValues = data.map { $0.diastolic }
        
        // Find the minimum and maximum values
        let minSystolic = systolicValues.min() ?? 0
        let maxSystolic = systolicValues.max() ?? 100
        let minDiastolic = diastolicValues.min() ?? 0
        let maxDiastolic = diastolicValues.max() ?? 100
        
        // Determine overall min and max
        let overallMin = min(minSystolic, minDiastolic)
        let overallMax = max(maxSystolic, maxDiastolic)
        
        // Add padding to the range
        let padding = (overallMax - overallMin) * 0.3 // Add 30% padding to the range
        
        return (overallMin - padding)...(overallMax + padding)
    }
    
    struct LegendItem: View {
        var color: Color
        var label: String
        
        var body: some View {
            HStack(spacing: 5) {
                Rectangle()
                    .fill(color)
                    .frame(width: 10, height: 10)
                    .cornerRadius(50)
                Text(label)
                    .font(.system(size: 13))
            }
        }
    }
    
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
                    
                    
                    Text("Historial Clinico")
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
            ScrollView(.vertical, showsIndicators: false){
                VStack{
                    VStack(spacing: 35){
                        VStack{
                            HStack{
                                Text("Juan Perez")
                                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                                    .bold()
                                Spacer()
                            }
                            HStack{
                                Image("profile1")
                                    .resizable()
                                    .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                                    .frame(width: 125, height: 225)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                Spacer()
                                VStack(alignment: .leading, spacing: 16){
                                    Text("Edad:")
                                    Text("Genero:")
                                    Text("Grupo de sangre:")
                                    Text("Peso:")
                                    Text("Altura:")
                                }
                                .padding(.leading, 10)
                                .font(.system(size: 20))
                                .bold()
                                VStack(spacing: 20){
                                    Text("35")
                                    Text("Masculino")
                                    Text("O+")
                                        .padding(.vertical, 11)
                                    Text("87 kg")
                                    Text("1.50 m")
                                }
                                .font(.system(size: 18))
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.top, 30)
                        VStack {
                            HStack{
                                Text("Resultados más recientes")
                                    .font(.title3)
                                    .bold()
                                Spacer()
                            }
                            HStack{
                                VStack(alignment: .leading) {
                                    HStack{
                                        Text("Glucosa: ")
                                        Spacer()
                                        Text(" \(latestGlucose, specifier: "%.1f") mg/dL")
                                    }
                                    
                                    HStack{
                                        Text("Presión Sistolica: ")
                                        Spacer()
                                        Text(" \(latestSystolic, specifier: "%.1f") mmHg")
                                    }
                                    
                                    HStack{
                                        Text("Presión Diastolica: ")
                                        Spacer()
                                        Text(" \(latestDiastolic, specifier: "%.1f") mmHg")
                                    }
                                    
                                    HStack{
                                        Text("Ritmo Cardiaco: ")
                                        Spacer()
                                        Text(" \(latestHeartRate, specifier: "%.1f") bpm")
                                    }
                                }
                                .font(.system(size: 16))
                                .padding(.horizontal)
                                Spacer()
                            }
                            .padding(.vertical)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.3), radius: 1, x: 0, y: 0)
                            .padding(.horizontal, 10)
                            
                        }
                        VStack{
                            HStack{
                                Text("Presion Arterial")
                                    .font(.title3)
                                    .bold()
                                Spacer()
                            }
                            HStack {
                                Spacer()
                                LegendItem(color: Color(Constants.Colors.accent), label: "Sistolica")
                                LegendItem(color: Color(Constants.Colors.PANTONE_320_C), label: "Diastolica")
                            }
                            .padding(.bottom, -20)
                            Chart(bloodPressureData.reversed()) { dataPoint in
                                LineMark(
                                    x: .value("Time", dataPoint.time),
                                    y: .value("Systolic", dataPoint.systolic),
                                    series: .value("Systolic", "Systolic")
                                )
                                .interpolationMethod(.cardinal)
                                .foregroundStyle(Color(Constants.Colors.accent)) // Use a different color for systolic

                                // Diastolic line
                                LineMark(
                                    x: .value("Time", dataPoint.time),
                                    y: .value("Diastolic", dataPoint.diastolic),
                                    series: .value("Diastolic", "Diastolic")
                                )
                                .interpolationMethod(.cardinal)
                                .foregroundStyle(Color(Constants.Colors.PANTONE_320_C)) // Use a different color for diastolic

                                // Systolic points
                                PointMark(
                                    x: .value("Time", dataPoint.time),
                                    y: .value("Systolic", dataPoint.systolic)
                                )
                                .foregroundStyle(Color(Constants.Colors.accent))
                                .symbol(Circle())
                                .symbolSize(50)

                                // Diastolic points
                                PointMark(
                                    x: .value("Time", dataPoint.time),
                                    y: .value("Diastolic", dataPoint.diastolic)
                                )
                                .foregroundStyle(Color(Constants.Colors.PANTONE_320_C))
                                .symbol(Circle())
                                .symbolSize(50)
                            }
                            .chartYScale(domain: calculateYAxisRangeBlood(for: bloodPressureData))
                            .frame(height: 150)
                            .padding()
                        }
                        VStack{
                            HStack{
                                Text("Ritmo Cardiaco")
                                    .font(.title3)
                                    .bold()
                                Spacer()
                            }
                            HStack {
                                Spacer()
                                LegendItem(color: Color(Constants.Colors.PANTONE_320_C), label: "Latidos por minuto")
                            }
                            .padding(.bottom, -20)
                            Chart(heartRateData.reversed()) { dataPoint in
                                LineMark(
                                    x: .value("Time", dataPoint.time),
                                    y: .value("Value", dataPoint.value)
                                )
                                .interpolationMethod(.cardinal)
                                .foregroundStyle(Color(Constants.Colors.PANTONE_320_C))
                                
                                PointMark(
                                    x: .value("Time", dataPoint.time),
                                    y: .value("Value", dataPoint.value)
                                )
                                .foregroundStyle(Color(Constants.Colors.PANTONE_320_C))
                                .symbol(Circle())
                                .symbolSize(50)
                            }
                            .chartYScale(domain: calculateYAxisRange(for: heartRateData))
                            .frame(height: 150)
                            .padding()
                        }
                        VStack{
                            HStack{
                                Text("Niveles de Glucosa")
                                    .font(.title3)
                                    .bold()
                                Spacer()
                            }
                            HStack {
                                Spacer()
                                LegendItem(color: Color(Constants.Colors.PANTONE_320_C), label: "Miligramos por decilitro")
                            }
                            .padding(.bottom, -20)
                            Chart(glucoseData.reversed()) { dataPoint in
                                LineMark(
                                    x: .value("Time", dataPoint.time),
                                    y: .value("Value", dataPoint.value)
                                )
                                .interpolationMethod(.cardinal)
                                .foregroundStyle(Color(Constants.Colors.PANTONE_320_C))
                                
                                PointMark(
                                    x: .value("Time", dataPoint.time),
                                    y: .value("Value", dataPoint.value)
                                )
                                .foregroundStyle(Color(Constants.Colors.PANTONE_320_C))
                                .symbol(Circle())
                                .symbolSize(50)
                            }
                            .chartYScale(domain: calculateYAxisRange(for: glucoseData))
                            .frame(height: 150)
                            .padding()
                        }
                    }
                }
            }
            .padding(.horizontal, 25)
        }
        .edgesIgnoringSafeArea(.top)
        .onAppear{
            fetchMedicionesSalud(userID: userID, sessionKey: sessionKey) { glucosa, presionArterial, ritmoCardiaco in
                self.glucoseData = glucosa
                self.bloodPressureData = presionArterial
                self.heartRateData = ritmoCardiaco
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    HealthView()
}
