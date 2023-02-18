import Foundation
import CoreLocation

class LocationManager : NSObject, ObservableObject, CLLocationManagerDelegate {

    @Published private (set) var isLocationEnabled: Bool
    @Published private (set) var speedKn: Double
    
    private let _locationManager: CLLocationManager
    
    override init() {
        _locationManager = CLLocationManager()
        isLocationEnabled = false
        speedKn = 0.0
        
        super.init()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        _locationManager.allowsBackgroundLocationUpdates = true
        _locationManager.activityType = .otherNavigation
    }
    
    public func startUpdating() {
        _locationManager.startUpdatingLocation()
    }
    
    public func stopUpdating() {
        _locationManager.stopUpdatingLocation()
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
        }
    }

}
