//
//  ChartView.swift
//  SwiftChart
//
//  Created by John Davenport on 1/28/25.
//

import SwiftUI
import Charts

struct HourlyData: Identifiable {
    let id: UUID = UUID()
    let date: Date
    let weatherNumber: Double
}

class ViewModel: ObservableObject {
    @Published var hourlyStats: [HourlyData] = []
    
    init() {
        generateDummyData()
    }
    
    private func generateDummyData() {
        let calendar = Calendar.current
        let startDate = Date() // Start from the current time

        // Define your custom weatherNumber values
        let manualValues: [Double] = [3, 7, 5, 8, 2, 6, 4, 10, 3, 9, 7, 1] // Exactly 12 values for the next 12 hours

        for hour in 0..<manualValues.count {
            let date = calendar.date(byAdding: .hour, value: hour, to: startDate)!
            let weatherNumber = manualValues[hour]
            hourlyStats.append(HourlyData(date: date, weatherNumber: weatherNumber))
        }
    }

}



struct ChartView: View {
    
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        
        Chart(viewModel.hourlyStats) { hourlyStats in
            
            let gradient = LinearGradient(
                gradient: Gradient(colors: viewModel.hourlyStats.map { weatherCardColor(for: $0.weatherNumber) }),
                startPoint: .leading,
                endPoint: .trailing
            )
            
            
            LineMark(
                x: .value("Date", hourlyStats.date),
                y: .value("WxNmbr", hourlyStats.weatherNumber)
            )
            .lineStyle(StrokeStyle(lineWidth: 7))
            .interpolationMethod(.catmullRom)
            .foregroundStyle(gradient)
            
            PointMark(
                x: .value("Date", hourlyStats.date),
                y: .value("WxNmbr", hourlyStats.weatherNumber)
            )
            .foregroundStyle(weatherCardColor(for: hourlyStats.weatherNumber))
            .symbolSize(500)
            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
            .annotation {
                Text("\(hourlyStats.weatherNumber, specifier: "%.0f")")
                    .font(.system(size: 15))
                    .fontWeight(.bold)
                    .foregroundStyle(Color.secondary)
                    .fontDesign(.rounded)
                    .offset(x: 0.47, y: 40.5)
                    .frame(width: 50, height: 50)
                    .kerning(-1.2)
            }
        }
        .frame(width: 330, height: 120)
        .chartYScale(domain: 0...10)
        .chartXScale(domain: Date()...Date().addingTimeInterval(12 * 60 * 60))
        .chartXAxis {
            AxisMarks(values: .stride(by: .hour, count: 2)) { value in
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(date, format: .dateTime.hour(.defaultDigits(amPM: .abbreviated)))
                    }
                }
                .offset(x: -15)
            }
        }
        .chartYAxis {
            AxisMarks {
                AxisGridLine()
            }
        }
    }
    
}

func weatherCardColor(for number: Double) -> Color {
    switch number {
    case 0...3: return .redCard
    case 4...6: return .yellowCard
    case 7...9: return .greenCard
    default: return .perfectCard
    }
}

#Preview {
    ChartView()
}
