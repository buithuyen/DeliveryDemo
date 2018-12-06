//
//  Route.swift
//  Delivery
//
//  Created by ThuyenBV on 12/2/18.
//  Copyright © 2018 Buvaty. All rights reserved.
//

import Foundation

struct Routes: Decodable {
    let routes: [Route]?
    let status: String?
}

struct Route {
    let legs: [Leg]?
    let overviewPolyline: OverviewPolyline?
}

extension Route: Decodable {
    enum RouteKeys: String, CodingKey {
        case legs = "legs"
        case overviewPolyline = "overview_polyline"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RouteKeys.self)
        let legs: [Leg] = try container.decode([Leg].self, forKey: .legs)
        let overviewPolyline: OverviewPolyline = try container.decode(OverviewPolyline.self, forKey: .overviewPolyline)
        
        self.init(legs: legs, overviewPolyline: overviewPolyline)
    }
}

struct Leg {
    let distance: Distance?
    let duration: Distance?
    let endAddress: String?
    let endLocation: Location?
    let startAddress: String?
    let startLocation: Location?
    let steps: [Step]?
}

extension Leg: Decodable {
    enum LegKeys: String, CodingKey {
        case distance = "distance"
        case duration = "duration"
        case endAddress = "end_address"
        case endLocation = "end_location"
        case startAddress = "start_address"
        case startLocation = "start_location"
        case steps = "steps"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: LegKeys.self)
        let distance: Distance = try container.decode(Distance.self, forKey: .distance)
        let duration: Distance = try container.decode(Distance.self, forKey: .duration)
        let endAddress: String = try container.decode(String.self, forKey: .endAddress)
        let endLocation: Location = try container.decode(Location.self, forKey: .endLocation)
        let startAddress: String = try container.decode(String.self, forKey: .startAddress)
        let startLocation: Location = try container.decode(Location.self, forKey: .startLocation)
        let steps: [Step] = try container.decode([Step].self, forKey: .steps)
        
        self.init(distance: distance,
                  duration: duration,
                  endAddress: endAddress,
                  endLocation: endLocation,
                  startAddress: startAddress,
                  startLocation: startLocation,
                  steps: steps)
    }
}

struct Distance: Decodable {
    let text: String?
    let value: Int?
}

struct Location: Decodable {
    let lat: Double?
    let lng: Double?
}

struct Step: Decodable {
    let distance: Distance?
    let duration: Distance?
    let endLocation: Location?
    let startLocation: Location?
    let travelMode: String?
}

struct OverviewPolyline: Decodable {
    let points: String?
}
