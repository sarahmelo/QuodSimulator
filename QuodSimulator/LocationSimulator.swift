import UIKit
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }
        let latitude = currentLocation.coordinate.latitude
        let longitude = currentLocation.coordinate.longitude
        print("Latitude: \(latitude), Longitude: \(longitude)")

        getAddressFromCoordinates(latitude: latitude, longitude: longitude) { address in
            if let address = address {
                print("Endereço: \n\(address)")
            } else {
                print("Não foi possível obter o endereço.")
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Erro ao obter localização: \(error.localizedDescription)")
    }

    private func getAddressFromCoordinates(latitude: Double, longitude: Double, completion: @escaping (String?) -> Void) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Erro ao obter endereço: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let placemark = placemarks?.first else {
                print("Nenhum endereço encontrado.")
                completion(nil)
                return
            }
            
            var address = ""
            
            if let street = placemark.thoroughfare {
                address += street
            }
            
            if let number = placemark.subThoroughfare {
                address += ", \(number)"
            }
            
            if let city = placemark.locality {
                address += "\n\(city)"
            }
            
            if let state = placemark.administrativeArea {
                address += " - \(state)"
            }
            
            if let postalCode = placemark.postalCode {
                address += "\nCEP: \(postalCode)"
            }
            
            completion(address)
        }
    }
}
