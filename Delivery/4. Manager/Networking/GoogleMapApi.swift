//
//  GoogleMapApi.swift
//  Delivery
//
//  Created by ThuyenBV on 12/2/18.
//  Copyright © 2018 Buvaty. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import Alamofire

enum GoogleMapApi {
    case direction(origi:String, destination: String)
}

extension GoogleMapApi: TargetType {

    var baseURL: URL {
        return URL(string: AppConfigs.Network.baseURL)!
    }
    
    var path: String {
        switch self {
            case .direction: return "directions/json"
            // Add more api here
        }
    }
    
    var method: Moya.Method {
        switch self {
        default:
            return .get
        }
    }
    
    var parameters: [String: Any]? {
        var params: [String: Any] = [:]
        switch self {
        case .direction(let origin, let destination):
            params["origin"] = origin
            params["destination"] = destination
            params["mode"] = AppConfigs.Map.travelMode
            params["key"] = AppConfigs.Map.googleMapKey
            break
        }
        
        return params
    }
    
    public var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    var sampleData: Data {
        switch self {
            case .direction: return stubbedResponse("Directions")
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    var task: Task {
        if let parameters = parameters {
            return .requestParameters(parameters: parameters, encoding: parameterEncoding)
        }
        return .requestPlain
    }
}
