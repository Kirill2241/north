//
//  ContactListPresenterProtocol.swift
//  Telephone Directory
//
//  Created by Diana Princess on 07.12.2022.
//

import Foundation
import UIKit

protocol ContactListPresenterProtocol {
    func tryRequest()
    func filterContacts(_ searchText: String, listIsFiltered: Bool)
    func openContact(id: String)
    func requestThumbnail(contacts: [ContactPresentationModel]) -> [ContactPresentationModel]
}
