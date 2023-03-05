//
//  ContentView.swift
//  YaSailingApp Watch App
//

import SwiftUI

struct TimerVew: View {

    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var te: TimerEngine
    @EnvironmentObject var tabState: TabState

    func startStop() {
        te.isRunning ? te.stopTicks() : te.startTicks()
    }
    
    func onTimeExpired() {
        locationManager.startRecording()
        tabState.tabId = 2
    }
    

    
    var body: some View {
        
        TimelineView(PeriodicTimelineSchedule(from: te.startTime, by: 1.0)) { context in
            
            ZStack {
                
                ZStack {
                    Circle()
                        .stroke(lineWidth: 18.0)
                        .opacity(0.2)
                        .foregroundColor(Color.pink)
                    
                    let gradientColors =
                        [Color(hex: 0xC71FD6), Color(hex: 0xDC8219), Color(hex: 0x172EAA), Color(hex: 0xE93D3D)]
                        //[Color(hex: 0xF3003D), Color(hex: 0xFD783F), Color(hex: 0xFFCF00), Color(hex: 0x00E6B0)]
                    Circle()
                        .trim(from: 0, to: CGFloat(te.getUiRemains(time: context.date)) / CGFloat(te.totalTime))
                        .stroke(style: StrokeStyle(
                            lineWidth: 18,
                            lineCap: .butt,
                            lineJoin: .round,
                            dash: [1, 1.5]))
                        .fill(
//                            AngularGradient(
//                                colors: gradientColors,
//                                center: .center,
//                                startAngle: .degrees(0),
//                                endAngle: .degrees(360)))
                            LinearGradient(
                                gradient: .init(colors: gradientColors),
                                startPoint: .topLeading,
                                endPoint: .trailing))
                        .rotationEffect(.degrees(270))
                        .animation(.easeOut, value: te.getUiRemains(time: context.date))
                }
                
                VStack {
                    Text("  \(String(format: "%.2f", locationManager.speedKn))")
                        .font(.system(size: 25, design: .rounded)) +
                    Text(" kn")
                        .font(.system(size: 15, design: .rounded))   
                    
                    Text("\(te.getUiMin(time: context.date)):\(String(format: "%02d", te.getUiSec(time: context.date)))")
                        .font(.system(size: 50) )
                        .fontWeight(Font.Weight.bold)
                        .monospaced()
                    
                    Text(!te.isRunning ? "Press to start " : " ")
                        .font(.caption)
                }
                .onAppear {
                    if locationManager.isLocationEnabled {
                        locationManager.startUpdating()
                    } 
                }
                .onDisappear {
                   // locationManager.stopUpdating()
                }
            }
        }
        .focusable(true)
        .digitalCrownRotation(
            $te.adjustment,
            from: -Double(te.totalTime),
            through: Double(te.totalTime),
            by: 1,
            sensitivity: .medium,
            isContinuous: false,
            isHapticFeedbackEnabled: true)
        .onTapGesture(){ _ in
            startStop()
        }
        .onAppear {
            te.setOnTimerExpired(action: onTimeExpired)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TimerVew()
            .environmentObject(TimerEngine())
            .environmentObject(LocationManager())
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}
