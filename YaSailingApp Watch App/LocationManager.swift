import Foundation
import CoreLocation
import SwiftUI

class LocationManager : NSObject, ObservableObject, CLLocationManagerDelegate {

    @Published private (set) var isLocationEnabled: Bool
    @Published private (set) var speedKn: Double
    @Published private (set) var maxSpeedKn: Double
    @Published private (set) var heading: Int
    @Published private (set) var avgHeading: Int
    @Published private (set) var isGpsGood: Bool
    @Published private (set) var distanceNm: Double
    @Published private (set) var durationSec: Double
    @Published private (set) var isRecording: Bool
    @Published private (set) var isLocationUpdates: Bool
    
    private let _locationManager: CLLocationManager
    private var _avgHolder: [Double]
    private var _lastLocation: CLLocation?
    private var _startTime: Date?
    private var _savedDuration: Double
    
    
    override init() {
        _locationManager = CLLocationManager()
        _avgHolder = Array()
        _savedDuration = 0
        isRecording = false
        isLocationEnabled = false
        isLocationUpdates = false
        speedKn = 0.0
        maxSpeedKn = 0.0
        heading = 0
        avgHeading = 0
        isGpsGood = false
        distanceNm = 0
        durationSec = 0

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
        isLocationUpdates = false
    }
    
    public func startRecording() {
        guard isLocationUpdates else { return }
        isRecording = true
        _startTime = Date()
    }
    
    public func stopRecording() {
        isRecording = false
        durationSec = _startTime != nil ? Date().timeIntervalSince(_startTime!) : 0
        _savedDuration += durationSec
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
