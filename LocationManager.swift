import Foundation
import CoreLocation
import Combine
import UIKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    // Published properties for location and heading.
    @Published var location: CLLocation? {
        didSet {
            if let loc = location {
                // Start the API call or any other update with the location.
                PrayerData.shared.startDailyUpdates(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
            }
        }
    }
    @Published var heading: CLHeading?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    override init() {
        super.init()
        locationManager.delegate = self

        // Set up heading updates (adjust accuracy as needed)
        locationManager.headingFilter = kCLHeadingFilterNone

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(checkLocationPermission),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    @objc private func checkLocationPermission() {
        requestLocationPermission()
    }

    private func showLocationDeniedAlert() {
        let alert = UIAlertController(
            title: "Location Permission Needed",
            message: "Please enable location services in Settings to fetch accurate prayer times.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            self.openAppSettings()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        if let topVC = UIApplication.shared.windows.first?.rootViewController {
            topVC.present(alert, animated: true)
        }
    }

    private func requestLocationPermission() {
        locationManager.delegate = self  // Ensure delegate is set before requesting
        let status = locationManager.authorizationStatus

        switch status {
        case .notDetermined:
            print("Requesting location permission...")
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            print("Permission granted, starting location updates...")
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()  // Start heading updates
        case .denied, .restricted:
            print("Location permission denied")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showLocationDeniedAlert()
            }
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.authorizationStatus = status
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()  // Start heading updates when authorized
        } else {
            print("Location permission denied")
            openAppSettings()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        locationManager.stopUpdatingLocation()  // You may want to adjust this if you want continuous location updates.
        print("User's location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
    }
    
    // New delegate method for heading updates.
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        DispatchQueue.main.async {
            self.heading = newHeading
        }
    }
    
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        // Return true to display calibration if needed.
        return true
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }

    private func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}
