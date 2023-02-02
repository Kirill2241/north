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
        let imageDataCache = ImageDataCache()
        let networkService = NetworkService(imageDataCache: imageDataCache)
        let contactsStorageService = DownloadedContactsStorageService()
        let presenter = ContactListPresenter(view: view, networkService: networkService, router: router, contactsStorageService: contactsStorageService)
        view.presenter = presenter
        contactsStorageService.delegate = presenter
        return view
    }
    func buildOneContact(router: RouterProtocol, oneContact: ContactItem) -> UIViewController { 
        let view = OneContactViewController(nibName: "OneContactVC", bundle: nil)
        let imageDataCache = ImageDataCache()
        let networkService = NetworkService(imageDataCache: imageDataCache)
        let presenter = OneContactPresenter(view: view, networkService: networkService, router: router, contact: oneContact)
        view.presenter = presenter
        return view
    }
}
