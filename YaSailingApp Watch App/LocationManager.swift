import Foundation
import CoreLocation
import SwiftUI


struct LapInfo {
    public var duration = 0.0
    public var distance = 0.0
    public var startTime: Date?
    public var startDistance = 0.0
}

class LocationManager : NSObject, ObservableObject, CLLocationManagerDelegate {

    @Published private (set) var isLocationEnabled = false
    @Published private (set) var isLocationUpdates = false
    @Published private (set) var isRecording = false
    @Published private (set) var isGpsGood = false
    @Published private (set) var speedKn = 0.0
    @Published private (set) var maxSpeedKn = 0.0
    @Published private (set) var heading = 0
    @Published private (set) var avgHeading = 0
    @Published private (set) var distanceNm = 0.0
    @Published private (set) var durationSec = 0.0
    @Published private (set) var laps: [LapInfo]


    
    private let _locationManager: CLLocationManager
    private var _avgHolder: [Double]
    private var _lastLocation: CLLocation?
    private var _startTime: Date?
    private var _savedDuration = 0.0
    private var _lastLap = LapInfo()
    
    
    override init() {
        _locationManager = CLLocationManager()
        _avgHolder = Array()
        laps = Array()

        super.init()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        _locationManager.allowsBackgroundLocationUpdates = true
        _locationManager.activityType = .otherNavigation
    }
    
    public func startUpdating() {
        _locationManager.startUpdatingLocation()
        isLocationUpdates = true
    }
    
    public func stopUpdating() {
        _locationManager.stopUpdatingLocation()
        stopRecording()
        isLocationUpdates = false
    }
    
    public func startRecording() {
        guard isLocationUpdates else { return }
        isRecording = true
        _startTime = Date()
        _lastLap = LapInfo(startTime: Date(), startDistance: distanceNm)
    }
    
    public func stopRecording() {
        isRecording = false
        durationSec = _savedDuration + (_startTime != nil ? Date().timeIntervalSince(_startTime!) : 0)
        _savedDuration = durationSec
        _lastLap.duration = _lastLap.startTime != nil ? Date().timeIntervalSince(_lastLap.startTime!) : 0
        _lastLap.distance = distanceNm - _lastLap.startDistance
        laps.append(_lastLap)
    }
    
    internal func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse ||
            manager.authorizationStatus == .authorizedAlways {
            isLocationEnabled = true
        } else {
            isLocationEnabled = false
        }
        
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
    }
    
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            speedKn = max(0.0, location.speed) * 1.943844
            heading = Int(max(0.0, location.course))
            maxSpeedKn = max(maxSpeedKn, speedKn)
            isGpsGood = location.speed >= 0 && location.course >= 0
            
            if isGpsGood {
                avgHeading = getAvg(heading: Double(heading))

                if isRecording && _lastLocation != nil {
                    distanceNm += (location.distance(from: _lastLocation!) / 1852)
                }
                _lastLocation = location
            }
            
            if isRecording {
                durationSec = _savedDuration + (_startTime != nil ? Date().timeIntervalSince(_startTime!) : 0)
            }
        }
    }
    
    private func getAvg(heading: Double) -> Int {
        if _avgHolder.count > 10 {
            _avgHolder.removeFirst()
        }
        _avgHolder.append(heading);

        let (s, c) =
            _avgHolder.lazy
                .map({ Angle(degrees: $0).radians })
                .map({ (sin($0), cos($0)) })
                .reduce(into: (0.0, 0.0), { $0.0 += $1.0; $0.1 += $1.1 })

        return (Int(Angle(radians: atan2(s / Double(_avgHolder.count), c / Double(_avgHolder.count))).degrees) + 360) % 360
    }

}
