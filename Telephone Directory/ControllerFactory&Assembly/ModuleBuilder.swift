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
        let downloadedContactsState = DownloadedContactsState()
        let imageDataCache = ImageDataCache()
        let presenter = ContactListPresenter(view: view, networkService: networkService, router: router, downloadedContactsState: downloadedContactsState, dataCache: imageDataCache)
        view.presenter = presenter
        return view
    }
    func buildOneContact(router: RouterProtocol, oneContact: ContactItem) -> UIViewController { 
        let view = OneContactViewController(nibName: "OneContactVC", bundle: nil)
        let networkService = NetworkService()
        let presenter = OneContactPresenter(view: view, networkService: networkService, router: router, contact: oneContact)
        view.presenter = presenter
        return view
    }
}
