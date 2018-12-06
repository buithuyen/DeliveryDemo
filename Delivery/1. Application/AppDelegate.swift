//
//  AppDelegate.swift
//  Delivery
//
//  Created by ThuyenBV on 12/02/18.
//  Copyright © 2018 Buvaty. All rights reserved.
//

import UIKit
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        GMSServices.provideAPIKey(AppConfigs.Map.googleMapKey)
        
        return true
    }
}

