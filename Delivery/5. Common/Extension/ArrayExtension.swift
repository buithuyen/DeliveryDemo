//
//  ArrayExtension.swift
//  Delivery
//
//  Created by ThuyenBV on 12/02/18.
//  Copyright © 2018 Buvaty. All rights reserved.
//

import Foundation
import CoreLocation

extension Array where Element == PharmacyLocation {
    
    mutating func sort(by location: CLLocation) {
        return sort(by: { $0.distance(to: location) < $1.distance(to: location) })
    }
    
    func sorted(by location: CLLocation) -> [PharmacyLocation] {
        return sorted(by: { $0.distance(to: location) < $1.distance(to: location) })
    }
}
