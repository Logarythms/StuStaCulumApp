//
//  UIApplication.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 04.06.23.
//  Copyright © 2023 stustaculum. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    var foregroundActiveScene: UIWindowScene? {
        connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
    }
}
