//
//  ViewModel.swift
//  Delivery
//
//  Created by ThuyenBV on 12/2/18.
//  Copyright © 2018 Buvaty. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxCoreLocation
import NSObject_Rx
import CoreLocation
import UserNotifications

protocol PharmacyLocationHandle {
    func getPharmacyLocation() -> Observable<[PharmacyLocation]>
    func sortPharmacyLocationToShortest(location: CLLocation,
                                        pharmacyLocations: [PharmacyLocation]) -> Observable<[PharmacyLocation]>
}

protocol RouteHandle {
    func getRoute(currentLocation: CLLocation, pharmacyLocations: [PharmacyLocation]) -> Observable<[Route]>
    func fetchRouteSpec(origin: CLLocation, destination: CLLocation) -> Observable<[Route]>
}

//MARK: Declare
class ViewModel: NSObject {
    struct Input {
        let location: Observable<CLLocation>
    }
    
    struct Output {
        let showAlert: PublishSubject<String>
        let pharmacyLocation: Observable<[PharmacyLocation]>
        let route: Observable<[Route]>
        let totalDistance: Observable<Int>
        let totalDuration: Observable<Int>
    }
    
    
    /// <#Description#>
    ///
    /// - Parameter input: <#input description#>
    /// - Returns: <#return value description#>
    func transform(input: Input) -> Output {
        let pharmacyLocation = self.getPharmacyLocation()
        let myLocationAndPharmacyLocation = Observable.combineLatest(input.location,pharmacyLocation)
        
        let pharmacyLocationSorted = myLocationAndPharmacyLocation.flatMap { (currentLocation, pharmacyLocation) -> Observable<[PharmacyLocation]> in
            return self.sortPharmacyLocationToShortest(location: currentLocation,
                                                       pharmacyLocations: pharmacyLocation)
        }
        
        let route = myLocationAndPharmacyLocation.flatMap { (currentLocation, pharmacyLocation) -> Observable<[Route]> in
            return self.getRoute(currentLocation: currentLocation, pharmacyLocations: pharmacyLocation)
        }
        
        let totalDistance = route.flatMap { (routes) -> Observable<Int> in
            return self.caculateTotalDistance(routes: routes)
        }
        
        let totalDuration = route.flatMap { (routes) -> Observable<Int> in
            return self.caculateTotalDuration(routes: routes)
        }
        
        return Output(showAlert: PublishSubject<String>(),
                      pharmacyLocation: pharmacyLocationSorted,
                      route: route,
                      totalDistance:totalDistance,
                      totalDuration:totalDuration)
    }
}

// MARK: Location handle
extension ViewModel: PharmacyLocationHandle {
    
    /// <#Description#>
    ///
    /// - Returns: <#return value description#>
    func getPharmacyLocation() -> Observable<[PharmacyLocation]> {
        if let path = Bundle.main.path(forResource: "location", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                let results = try JSONDecoder().decode([PharmacyLocation].self, from: data)
                
                return Observable.just(results)
            } catch {
                return Observable.just([])
            }
        }
        
        return Observable.just([])
    }
    
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - location: <#location description#>
    ///   - pharmacyLocations: <#pharmacyLocations description#>
    /// - Returns: <#return value description#>
    func sortPharmacyLocationToShortest(location: CLLocation, pharmacyLocations: [PharmacyLocation]) -> Observable<[PharmacyLocation]> {
        guard pharmacyLocations.count > 0 else {return Observable.just([])}
        
        var sortArray = pharmacyLocations.sorted(by: location)
        var shortestArray = [PharmacyLocation]()
        
        while sortArray.count > 0 {
            guard let item = sortArray.first else {break}
            
            shortestArray.append(item)
            sortArray.remove(at: 0)
            
            sortArray = sortArray.sorted(by: item.position)
        }
        
        return Observable.just(shortestArray)
    }
}

// MARK: Route handle
extension ViewModel: RouteHandle {
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - currentLocation: <#currentLocation description#>
    ///   - pharmacyLocations: <#pharmacyLocations description#>
    /// - Returns: <#return value description#>
    func getRoute(currentLocation: CLLocation, pharmacyLocations: [PharmacyLocation]) -> Observable<[Route]> {
        guard pharmacyLocations.count > 0 else {return Observable.just([])}
        
        var routes = Observable<[Route]>.just([])

        let results = fetchRouteSpec(origin: currentLocation,
                                     destination: pharmacyLocations[0].position)
        routes = Observable.combineLatest(routes, results).map({ (route, result) -> [Route] in
            return route + result
        })

        for i in 0..<pharmacyLocations.count {
            guard i < pharmacyLocations.count - 1 else {break}

            let results = fetchRouteSpec(origin: pharmacyLocations[i].position,
                                         destination: pharmacyLocations[i+1].position)
            routes = Observable.combineLatest(routes, results).map({ (route, result) -> [Route] in
                return route + result
            })
        }

        return routes
    }
    
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - origin: <#origin description#>
    ///   - destination: <#destination description#>
    /// - Returns: <#return value description#>
    func fetchRouteSpec(origin: CLLocation, destination: CLLocation) -> Observable<[Route]> {
        let originString = String("\(origin.coordinate.latitude),\(origin.coordinate.longitude)")
        let destinationString = String("\(destination.coordinate.latitude),\(destination.coordinate.longitude)")
        
        return ServiceManager.shared
            .getDirectionSpec(origin: originString, destination: destinationString)
            .map { (routes) -> [Route] in
                guard let route = routes.routes else {return []}
                return route
        }
    }
    
    
    /// <#Description#>
    ///
    /// - Parameter routes: <#routes description#>
    /// - Returns: <#return value description#>
    func caculateTotalDistance(routes: [Route]) -> Observable<Int> {
        var total : Int = 0
        
        for route in routes {
            guard let legs = route.legs else {continue}
            
            for leg in legs {
                total += leg.distance?.value ?? 0
            }
        }
        
        return Observable.just(total)
    }
    
    
    /// <#Description#>
    ///
    /// - Parameter routes: <#routes description#>
    /// - Returns: <#return value description#>
    func caculateTotalDuration(routes: [Route]) -> Observable<Int> {
        var total : Int = 0
        
        for route in routes {
            guard let legs = route.legs else {continue}
            
            for leg in legs {
                total += leg.duration?.value ?? 0
            }
        }
        
        return Observable.just(total)
    }

}
