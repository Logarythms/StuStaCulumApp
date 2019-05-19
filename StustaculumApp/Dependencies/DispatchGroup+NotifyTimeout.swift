//
//  DispatchGroup+NotifyTimeout.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 19.05.19.
//  Copyright © 2019 stustaculum. All rights reserved.
//

import Foundation

extension DispatchGroup {
    
    func notifyWait(target: DispatchQueue, timeout: DispatchTime, handler: @escaping ((DispatchTimeoutResult) -> Void)) {
        DispatchQueue.global(qos: .default).async {
            let timeout = self.wait(timeout: timeout)
            target.async {
                handler(timeout)
            }
        }
    }
    
}
