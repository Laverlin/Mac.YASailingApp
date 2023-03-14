import SwiftUI

enum DeviceSize: Int {
    case small = 1
    case medium = 2
    case large = 3
}

struct DeviceParams {
    public var deviceSize: DeviceSize
    public var mainFontSize: Double
    public var smallCaptionPaddingTop: Double
    public var smallCaptionPaddingLeft: Double
    public var summaryFontSize: Double
    
    init(_ screenWidth: Double){

        switch screenWidth {
        case 150..<180:
            deviceSize = DeviceSize.small
            mainFontSize = 36
            smallCaptionPaddingTop = -8
            smallCaptionPaddingLeft = -4
            summaryFontSize = 12
        case 190..<200:
            deviceSize = DeviceSize.medium
            mainFontSize = 50
            smallCaptionPaddingTop = -13
            smallCaptionPaddingLeft = -10
            summaryFontSize = 14
        default:
            deviceSize = DeviceSize.large
            mainFontSize = 52
            smallCaptionPaddingTop = -13
            smallCaptionPaddingLeft = -14
            summaryFontSize = 14
        //default: break
        }
    }
}


struct CruiseVew: View {
    
    @EnvironmentObject var locationManager: LocationManager

    private let _rFrameWidth = 60.0
    private let _screenSize = WKInterfaceDevice.current().screenBounds
    private var _deviceParams: DeviceParams
    
    init() {
        _deviceParams = DeviceParams(_screenSize.width)
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
                    .padding([.top], -2)
                    .padding([.bottom], -2)
                    .foregroundColor(Color(.lightGray))
            }
            HStack {
                Text(String(format: "%04.1f", locationManager.speedKn))
                    .lineLimit(1)
                    .fixedSize()
                    .font(.system(size: _deviceParams.mainFontSize))
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
            .frame(height: _deviceParams.mainFontSize - 8)
            //.background(Color(.gray))
            Divider()
            Text("COG")
                .frame(width: _screenSize.width, alignment: .leading)
                .font(.system(size: 12))
                .padding([.top], -4)
                .padding(.bottom, -2)
                .padding(.leading, 8)
                .foregroundColor(Color(.lightGray))
            HStack {
                Text(String(format: "%03d", locationManager.heading))
                    .lineLimit(1)
                    .fixedSize()
                    .font(.system(size: _deviceParams.mainFontSize))
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
            .frame(height: _deviceParams.mainFontSize - 8)
            //.background(Color(.gray))
            Divider()

            
            HStack {
                VStack {
                    HStack(alignment: .top) {
                        Text("total")
                            .font(.system(size: 9))
                            .foregroundColor(Color(.lightGray))
                            .padding([.top], _deviceParams.smallCaptionPaddingTop)
                            .padding([.leading], _deviceParams.smallCaptionPaddingLeft)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                    }
                    HStack(alignment: .bottom) {
                        Spacer()
                        Text(String(format: "%06.2f", locationManager.distanceNm))
                            .font(.system(size: _deviceParams.summaryFontSize, design: .monospaced))
                            .foregroundColor(locationManager.isRecording ? Color(.white) : Color(.lightGray))
                            .padding(.bottom, -2)
                        Text(" nm")
                            .font(.system(size: 10))
                            .foregroundColor(Color(.lightGray))
                    }
                    
                    HStack(alignment: .bottom) {
                        Spacer()
                        Text(locationManager.durationSec.asShortString)
                            .font(.system(size: _deviceParams.summaryFontSize, design: .monospaced))
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

                
                VStack(alignment: .leading) {
                    HStack {
                        Text("last lap")
                            .font(.system(size: 9))
                            .foregroundColor(Color(.lightGray))
                            .padding([.top], _deviceParams.smallCaptionPaddingTop)
                            .padding([.leading], _deviceParams.smallCaptionPaddingLeft - 6)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    HStack(alignment: .bottom) {
                        Text(String(format: "%06.2f", locationManager.laps.last?.distance ?? 0))
                            .font(.system(size: _deviceParams.summaryFontSize, design: .monospaced))
                            .foregroundColor(Color(.lightGray))
                            .padding(.bottom, -2)
                            .padding(.leading, -10)
                        Text(" nm")
                            .font(.system(size: 10))
                            .foregroundColor(Color(.lightGray))
                    }
                    
                    HStack(alignment: .bottom) {
                        Text(locationManager.laps.last?.duration.asShortString ?? "0:00:00")
                            .font(.system(size: _deviceParams.summaryFontSize, design: .monospaced))
                            .foregroundColor(Color(.lightGray))
                            .padding(.bottom, -2)
                            .padding(.leading, -10)
                        Image(systemName: "clock")
                            .font(.system(size: 8))
                            .foregroundColor(Color(.lightGray))
                    }
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
    
    var asShortString: String {
        "\(String(format: "%01d", self.hours)):\(String(format: "%02d", self.minutes)):\(String(format: "%02d", self.seconds))"
    }
}
