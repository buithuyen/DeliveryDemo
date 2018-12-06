//
//  LocalNotificationExtension.swift
//  Delivery
//
//  Created by ThuyenBV on 12/2/18.
//  Copyright © 2018 Buvaty. All rights reserved.
//

import Foundation
import UserNotifications
import CoreLocation

extension UNUserNotificationCenter {
    static func scheduleNotification(region: CLRegion, message: String) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            guard granted == true else {return}
            
            let content = UNMutableNotificationContent()
            content.title = AppConfigs.App.appName
            content.body = message
            content.sound = UNNotificationSound.default
            content.categoryIdentifier = region.identifier
            
            let trigger = UNLocationNotificationTrigger(region: region, repeats: true)
            let request = UNNotificationRequest.init(identifier: region.identifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request)
        }
    }
}
