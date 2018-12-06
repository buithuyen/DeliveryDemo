//
//  ViewController.swift
//  Delivery
//
//  Created by ThuyenBV on 12/02/18.
//  Copyright © 2018 Buvaty. All rights reserved.
//

import UIKit
import GoogleMaps
import RxCoreLocation
import RxSwift
import NSObject_Rx
import UserNotifications

class ViewController: UIViewController {
    
    let locationManager = CLLocationManager()
    var isTheFirst = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapView()
        setUpLocationManager()
    }
    
    
    /// <#Description#>
    ///
    /// - Parameter location: <#location description#>
    func bindViewModel(location: CLLocation) {
        let viewModel = ViewModel()
        let output = viewModel.transform(input: ViewModel.Input(location:Observable.just(location)))
        
        output.pharmacyLocation.subscribe(onNext: {[weak self] pharmacies in
            guard let this = self else {return}
            this.drawMarker(shortestArray: pharmacies)
            this.monitorRegion(pharmacies: pharmacies)
        }).disposed(by: rx.disposeBag)
        
        output.showAlert.subscribe(onNext: {[weak self] (message) in
            guard let this = self else {return}
            this.showAlert(withTitle: AppConfigs.App.appName,
                           message: message)
        }).disposed(by: rx.disposeBag)
        
        output.route.subscribe(onNext: {[weak self] (routes) in
            guard let this = self else {return}
            this.drawRoute(routes: routes)
        }).disposed(by: rx.disposeBag)
        
        Observable.combineLatest(output.totalDistance, output.totalDuration).subscribe(onNext: {[weak self] (distance, time) in
            guard let this = self else {return}
            this.showAlert(withTitle: AppConfigs.App.appName, message: "Total distance: \(distance) meters\nTotal duration: \(time) minutes")
        }).disposed(by: rx.disposeBag)
    }
}

//MARK: Private Method
extension ViewController {
    
    
    /// <#Description#>
    fileprivate func setupMapView() {
        let camera = GMSCameraPosition.camera(withLatitude: AppConfigs.Map.latDefault,
                                              longitude: AppConfigs.Map.lngDefault,
                                              zoom: 15)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        
        self.view = mapView
    }
    
    
    /// <#Description#>
    fileprivate func setUpLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters // less batery ussage
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 10
        
        locationManager.rx
            .didChangeAuthorization
            .subscribe(onNext: { (manager: CLLocationManager, status: CLAuthorizationStatus) in
                switch status {
                case .authorizedAlways,.authorizedWhenInUse:
                    manager.startUpdatingLocation()
                    break
                default:
                    break
                }
            }).disposed(by: rx.disposeBag)
        
        locationManager.rx
            .location
            .debug("location")
            .do(onNext: { (location) in
                
            })
            .subscribe(onNext: { [weak self] location in
                guard let location = location else {return}
                guard let this = self else {return}
                
                guard this.isTheFirst == false else {return}
                this.isTheFirst = true
                
                this.bindViewModel(location: location)
            })
            .disposed(by: rx.disposeBag)
        
        locationManager.rx
            .didReceiveRegion
            .subscribe(onNext: { (manager, region, state) in
                switch state {
                case .monitoring:
                    print("You just monitor \(region.identifier)")
                    break
                    
                case .enter:
                    print("You just enter \(region.identifier)")
                    break
                    
                case .exit:
                    print("You just exit \(region.identifier)")
                    break
                }
            }).disposed(by: rx.disposeBag)
    }
    
    
    /// <#Description#>
    ///
    /// - Parameter shortestArray: <#shortestArray description#>
    fileprivate func drawMarker(shortestArray: [PharmacyLocation]) {
        guard let mapView = view as? GMSMapView else {return}
        
        var bounds = GMSCoordinateBounds()
        
        for i in 0..<shortestArray.count {
            let item = shortestArray[i]
            
            guard let lat = item.location?.lat else {continue}
            guard let lng = item.location?.lng else {continue}
            
            let position = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            
            let marker = GMSMarker(position: position)
            marker.title = item.name ?? ""
            marker.iconView = MarkerView(index: i)
            marker.map = mapView
            
            bounds = bounds.includingCoordinate(position)
        }
        
        mapView.animate(with: GMSCameraUpdate.fit(bounds))
    }
    
    
    /// <#Description#>
    ///
    /// - Parameter pharmacies: <#pharmacies description#>
    fileprivate func monitorRegion(pharmacies: [PharmacyLocation] ) {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse
            || CLLocationManager.authorizationStatus() == .authorizedWhenInUse{
            if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
                for item in pharmacies {
                    let regionCircular = CLCircularRegion(center: item.position.coordinate,
                                                          radius: AppConfigs.Location.regionCircularRadius,
                                                          identifier: item.id ?? UUID().uuidString)
                    regionCircular.notifyOnEntry = true
                    regionCircular.notifyOnExit = true
                    
                    locationManager.startMonitoring(for: regionCircular)
                    
                    UNUserNotificationCenter.scheduleNotification(region: regionCircular,
                                                                  message: "You have just visited \(item.name ?? "")")
                }
            } else {
                showAlert(withTitle: AppConfigs.App.appName,
                          message: "Your device do not support monitor location")
            }
        } else {
            showAlert(withTitle: AppConfigs.App.appName,
                      message: "You have to give location permission to monitor visit pharmacy place")
        }
    }
    
    /// <#Description#>
    ///
    /// - Parameter routes: <#routes description#>
    fileprivate func drawRoute(routes: [Route]) {
        guard let mapView = self.view as? GMSMapView else {return}
        guard routes.count > 0 else {return}
        
        for route in routes {
            
            guard let polyString = route.overviewPolyline?.points else {continue}
            
            print("polyString: \(polyString)")
            
            let path = GMSPath(fromEncodedPath: polyString)
            let polyline = GMSPolyline(path: path)
            polyline.strokeWidth = 5.0
            polyline.strokeColor = UIColor.purple
            polyline.map = mapView
        }
    }
    
    /// <#Description#>
    ///
    /// - Parameter location: <#location description#>
    fileprivate func drawCircleAt(location: CLLocation) {
        guard let mapView = self.view as? GMSMapView else {return}
        let circle = GMSCircle(position: location.coordinate, radius: AppConfigs.Location.regionCircularRadius)
        circle.fillColor = UIColor(red: 0.25, green: 0, blue: 0, alpha: 0.5)
        circle.map = mapView
    }
}
