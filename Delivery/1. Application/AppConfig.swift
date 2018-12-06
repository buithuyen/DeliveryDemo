//
//  AppConfig.swift
//  Delivery
//
//  Created by ThuyenBV on 12/2/18.
//  Copyright © 2018 Buvaty. All rights reserved.
//

import Foundation

struct AppConfigs {
    struct App {
        static let bundleIdentifier : String = Bundle.main.bundleIdentifier ?? ""
        static let appName : String = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? ""
    }
    
    struct Location {
        static let regionCircularRadius : Double = 1000.0
    }
    
    struct Map {
        static let googleMapKey = "AIzaSyAxdz4-JfihFHsU-wFs8pLuU0jNfnudefU"
        static let travelMode = "driving"
        static let zoomLevelDefault : Float = 15.0
        static let latDefault : Double = 105.804610
        static let lngDefault : Double = 105.804610
    }
    
    struct Network {
        static let useStaging = false
        static let loggingEnabled = false
        static var baseURL: String {
            return "https://maps.googleapis.com/maps/api/"
        }
    }
    
    struct Demension {
        
    }
    
    struct NotificationKey {
        
    }
}
