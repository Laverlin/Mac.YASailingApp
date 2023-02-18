//
//  ContentView.swift
//  YaSailingApp Watch App
//

import SwiftUI

struct TimerVew: View {
    
    var body: some View {
        
        ZStack{
            
            let ss = WKInterfaceDevice.current().screenBounds
            
            Path { path in
                path.addArc(center: CGPoint(x: ss.midX, y: ss.midY), radius: 90, startAngle: Angle(degrees: 275), endAngle: Angle(degrees: 0), clockwise: true)
                
            }
            .stroke(Color.orange, lineWidth: 10)
            .ignoresSafeArea()
            
            HStack{
                Text("4:05")
                    .font(.system(size: 50))
            }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TimerVew()
    }
}
