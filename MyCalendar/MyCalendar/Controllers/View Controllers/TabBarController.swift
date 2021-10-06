//
//  TabBarController.swift
//  MyCalendar
//
//  Created by Bryan Gomez on 10/5/21.
//

import Foundation
import UIKit

class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        startObserving(&UserInterfaceStyleManager.shared)
    }
}
