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
        let presenter = ContactListPresenter(view: view)
        let interactor = ContactListInteractor(presenter: presenter, networkService: networkService, router: router)
        presenter.interactor = interactor
        view.presenter = presenter
        return view
    }
    func buildOneContact(router: RouterProtocol, oneContact: ContactItem) -> UIViewController{
        let view = OneContactViewController(nibName: "OneContactVC", bundle: nil)
        let networkService = NetworkService()
        let presenter = OneContactPresenter(view: view)
        view.presenter = presenter
        let interactor = OneContactInteractor(presenter: presenter, networkService: networkService, router: router, oneContact: oneContact)
        presenter.interactor = interactor
        return view
    }
}
