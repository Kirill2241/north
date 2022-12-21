//
//  Router.swift
//  Telephone Directory
//
//  Created by Diana Princess on 30.11.2022.
//

import Foundation
import UIKit

class Router: RouterProtocol{
    var navigationController: UINavigationController?
    var moduleBuilder: ModuleBuilderProtocol?
    
    init(navigationController: UINavigationController, moduleBuilder: ModuleBuilderProtocol) {
        self.navigationController = navigationController
        self.moduleBuilder = moduleBuilder
    }
    
    func initialViewController() {
        if let navigationController = navigationController {
            guard let contactListVC = moduleBuilder?.buildContactList(router: self) else { return }
            navigationController.viewControllers = [contactListVC]
        }
    }
    
    func openContact(fullName: String, phone: String, cell: String, email: String, largeImgStr: String, nat: String) {
        if let navigationController = navigationController {
            guard let oneContactVC = moduleBuilder?.buildOneContact(router: self, fullName: fullName, phone: phone, cell: cell, email: email, largeImgStr: largeImgStr, nat: nat) else { return }
            navigationController.pushViewController(oneContactVC, animated: true)
        }
    }
}
