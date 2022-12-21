//
//  ModuleBuilder.swift
//  Telephone Directory
//
//  Created by Diana Princess on 30.11.2022.
//

import Foundation
import UIKit

class ModuleBuilder: ModuleBuilderProtocol {
    func buildContactList(router: RouterProtocol) -> UIViewController {
        let view = ContactListViewController()
        let networkService = NetworkService()
        let presenter = ContactListPresenter(view: view, networkService: networkService, router: router)
        view.presenter = presenter
        return view
    }
    func buildOneContact(router: RouterProtocol, fullName: String, phone: String, cell: String, email: String, largeImgStr: String, nat: String) -> UIViewController{
        let view = OneContactViewController(nibName: "OneContactVC", bundle: nil)
        let networkService = NetworkService()
        let presenter = OneContactPresenter(view: view, networkService: networkService, router: router, fullName: fullName, phone: phone, cell: cell, email: email, largeImgStr: largeImgStr, nat: nat)
        view.presenter = presenter
        return view
    }
}
