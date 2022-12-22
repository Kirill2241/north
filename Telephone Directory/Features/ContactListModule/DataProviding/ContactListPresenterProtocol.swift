//
//  ContactListPresenterProtocol.swift
//  Telephone Directory
//
//  Created by Diana Princess on 07.12.2022.
//

import Foundation
import UIKit

protocol ContactListPresenterProtocol: UITableViewDataSource, UITableViewDelegate {
    init(view: ContactListViewProtocol,networkService: NetworkServiceProtocol, router: RouterProtocol)
    func filterContacts(_ searchText: String)
    func tryRequest()
}
