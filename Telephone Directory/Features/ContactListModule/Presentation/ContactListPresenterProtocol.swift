//
//  ContactListPresenterProtocol.swift
//  Telephone Directory
//
//  Created by Diana Princess on 07.12.2022.
//

import Foundation
import UIKit

protocol ContactListPresenterProtocol: class {
    var allContacts: [(ContactItem, Data?)] { get set }
    var filteredContacts: [(ContactItem, Data?)] { get set }
    init(view: ContactListViewProtocol)
    func filterContacts(_ searchText: String)
    func tryRequest()
    func fillViewWithContent()
    func collectData(_ data: Data?, contact: ContactItem)
    func errorAlert(error: HTTPError)
    func openOneContact(index: Int, filterIsUsed: Bool)
}
