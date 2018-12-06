//
//  Reachability.swift
//  Delivery
//
//  Created by ThuyenBV on 12/3/18.
//  Copyright © 2018 Buvaty. All rights reserved.
//

import Foundation
import RxSwift
import Reachability

// An observable that completes when the app gets online (possibly completes immediately).
func connectedToInternet() -> Observable<Bool> {
    return ReachabilityManager.shared.reach
}

private class ReachabilityManager: NSObject {
    
    static let shared = ReachabilityManager()
    
    fileprivate let reachability = Reachability.init()
    
    let _reach = ReplaySubject<Bool>.create(bufferSize: 1)
    var reach: Observable<Bool> {
        return _reach.asObservable()
    }
    
    override init() {
        super.init()
        
        reachability?.whenReachable = { reachability in
            DispatchQueue.main.async {
                self._reach.onNext(true)
            }
        }
        
        reachability?.whenUnreachable = { reachability in
            DispatchQueue.main.async {
                self._reach.onNext(false)
            }
        }
        
        do {
            try reachability?.startNotifier()
            _reach.onNext(reachability?.connection != .none)
        } catch {
            print("Unable to start notifier")
        }
    }
}
