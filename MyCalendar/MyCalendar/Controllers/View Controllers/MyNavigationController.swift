//
//  MyNavigationController.swift
//  MyCalendar
//
//  Created by Bryan Gomez on 10/5/21.
//

import Foundation
import UIKit

class MyNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        startObserving(&UserInterfaceStyleManager.shared)
    }
}
