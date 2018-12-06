//
//  PharmacyLocation.swift
//  Delivery
//
//  Created by ThuyenBV on 12/02/18.
//  Copyright © 2018 Buvaty. All rights reserved.
//

import Foundation
import CoreLocation

struct PharmacyLocation: Decodable {
    let location: Location?
    let icon: String?
    let id: String?
    let name: String?
    let photos: Photos?
    let placeid: String?
    let rating: Double?
    let vicinity: String?
    
    var position: CLLocation {
        get {
            return CLLocation(latitude: self.location?.lat ?? 0, longitude: self.location?.lng ?? 0)
        }
    }
    
    func distance(to location: CLLocation) -> CLLocationDistance {
        return location.distance(from: self.position)
    }        
}

struct Photos: Decodable {
    let height: Int?
    let photoReference: String?
    let width: Int?
}

