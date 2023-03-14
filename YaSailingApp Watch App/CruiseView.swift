import SwiftUI

struct CruiseVew: View {
    
    @EnvironmentObject var locationManager: LocationManager
    //private var _hFrameHeight = 50.0
    private let _rFrameWidth = 60.0
    private let _screenSize = WKInterfaceDevice.current().screenBounds
    private var _fontSize = 52.0
    
    init() {
        switch _screenSize.width {
        case 198.0 : _fontSize = 50
        case 150..<180 : _fontSize = 36
        default: break;
        }
    }
    
    func getSpeedColor() -> Color {
        return locationManager.isGpsGood
            ? Color(.white)
            : Color(.lightGray)
    }
    
    func getGpsColor() -> Color {
        return locationManager.isGpsGood
            ? Color(.green)
            : Color(.red)
    }
    
    func getRecordingColor() -> Color {
        return locationManager.isRecording ? Color(.green) : Color(.gray)
    }
    
    func startStop() {
        locationManager.isRecording
        ? locationManager.stopRecording()
        : locationManager.startRecording()
    }
    
    
    
    var body: some View {
        
        
        
        VStack {
            
            HStack {
                Image(systemName: "location.circle.fill")
                    .padding(.leading, 40)
                    .font(.system(size: 18))
                    .foregroundColor(getGpsColor())
                Image(systemName: "playpause.circle.fill")
                    .padding(.leading, 20)
                    .font(.system(size: 18))
                    .foregroundColor(getRecordingColor())
            }.frame(width: _screenSize.width, alignment: .leading)
                .padding(.top, 16)
                .padding(.bottom, 2)
            
            Divider()
            
            HStack {
                Text("SOG")
                    .frame(width: _screenSize.width, alignment: .leading)
                    .font(.system(size: 12))
                    .padding(.leading, 8)
                    .padding([.bottom], -4)
                    .foregroundColor(Color(.lightGray))
            }
            HStack {
                Text(String(format: "%04.1f", locationManager.speedKn))
                    .lineLimit(1)
                    .fixedSize()
                    .font(.system(size: _fontSize))
                    .fontWeight(Font.Weight.bold)
                    .padding([.bottom, .trailing], 8)
                    .monospaced()
                    .foregroundColor(getSpeedColor())
                //.background(Color(.lightGray))
                
                //
                Spacer()
                
                VStack{
                    Text("max")
                        .font(.system(size: 10))
                        .frame(width: _rFrameWidth, alignment: .trailing)
                        .padding(.top, -4)
                        .padding(.bottom, 0)
                        .foregroundColor(Color(.lightGray))
                    Text(String(format: "%04.1f", locationManager.maxSpeedKn))
                        .lineLimit(1)
                        .fixedSize()
                        .font(.system(size: 24, design: .monospaced))
                        .foregroundColor(getSpeedColor())
                        .frame(width: _rFrameWidth, alignment: .trailing)
                    
                    
                }//.background(Color(.blue))
                
                
            }
            .frame(height: _fontSize)
            //.background(Color(.gray))
            Divider()
            Text("COG")
                .frame(width: _screenSize.width, alignment: .leading)
                .font(.system(size: 12))
                .padding([.top], 0)
                .padding(.bottom, -4)
                .padding(.leading, 8)
                .foregroundColor(Color(.lightGray))
            HStack {
                Text(String(format: "%03d", locationManager.heading))
                    .lineLimit(1)
                    .fixedSize()
                    .font(.system(size: _fontSize))
                    .fontWeight(Font.Weight.bold)
                    .padding([.bottom, .trailing])
                    .monospaced()
                    .foregroundColor(getSpeedColor())
                Spacer()
                VStack{
                    Text("avg")
                        .font(.system(size: 10))
                        .frame(width: _rFrameWidth, alignment: .trailing)
                        .padding(.top, -4)
                        .padding(.bottom, 0)
                        .foregroundColor(Color(.lightGray))
                    Text(String(format: "%03d", locationManager.avgHeading))
                        .lineLimit(1)
                        .fixedSize()
                        .font(.system(size: 24, design: .monospaced))
                        .foregroundColor(getSpeedColor())
                        .frame(width: _rFrameWidth, alignment: .trailing)
                }//.background(Color(.blue))
            }
            .frame(height: _fontSize)
            //.background(Color(.gray))
            Divider()
            HStack {
                VStack {
                    HStack(alignment: .bottom) {
                        Spacer()
                        Text(String(format: "%06.2f", locationManager.distanceNm))
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundColor(locationManager.isRecording ? Color(.white) : Color(.lightGray))
                            .padding(.bottom, -2)
                        Text(" nm")
                            .font(.system(size: 10))
                            .foregroundColor(Color(.lightGray))
                    }
                    
                    HStack(alignment: .bottom) {
                        Spacer()
                        Text("\(String(format: "%01d", locationManager.durationSec.hours)):\(String(format: "%02d", locationManager.durationSec.minutes)):\(String(format: "%02d", locationManager.durationSec.seconds))")
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundColor(locationManager.isRecording ? Color(.white) : Color(.lightGray))
                            .padding(.bottom, -2)
                        Image(systemName: "clock")
                            .font(.system(size: 8))
                            .foregroundColor(Color(.lightGray))


                    }
                }
                .fixedSize(horizontal: true, vertical: false)
                .frame(width: _screenSize.width / 2, alignment: .trailing)
                
                Divider()
                
                VStack() {
                    Spacer()
                }
                .fixedSize(horizontal: true, vertical: false)
                .frame(width: _screenSize.width / 2)
            }.frame(width: _screenSize.width)
            
            Spacer()
            
        }
        .frame(height: _screenSize.height, alignment: .leading)
        .onTapGesture {
            startStop()
        }
        .onAppear {
            if locationManager.isLocationEnabled {
                locationManager.startUpdating()
            }
        }
        .onDisappear {
            //locationManager.stopUpdating()
        }
        
    }
}




struct CruiseView_Previews: PreviewProvider {
    static var previews: some View {
        CruiseVew()
            .environmentObject(LocationManager())
    }
}

extension TimeInterval {
    var hours: Int {
        Int(self / 3600)
    }
    
    var minutes: Int {
        Int(self.truncatingRemainder(dividingBy: 3600) / 60 )
    }
    
    var seconds: Int {
        Int(self.truncatingRemainder(dividingBy: 3600).truncatingRemainder(dividingBy: 60))
    }
}
