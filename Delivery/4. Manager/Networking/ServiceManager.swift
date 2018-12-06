//
//  Api.swift
//  Delivery
//
//  Created by ThuyenBV on 12/2/18.
//  Copyright © 2018 Buvaty. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
//import Moya_ObjectMapper

enum ApiError: Error {
    case serverError(title: String, description: String)
}

protocol DeliveryAPI {
    func getDirectionSpec(origin: String, destination: String) -> Observable<Routes>
}

class ServiceManager {
    static let shared = ServiceManager()
    var provider = AppConfigs.Network.useStaging ? Networking.newStubbingNetworking() : Networking.newDefaultNetworking()
}

extension ServiceManager: DeliveryAPI {
    func getDirectionSpec(origin: String, destination: String) -> Observable<Routes> {
        return provider.request(.direction(origi: origin, destination: destination))
            .map(Routes.self)
            .observeOn(MainScheduler.instance)
    }
}
