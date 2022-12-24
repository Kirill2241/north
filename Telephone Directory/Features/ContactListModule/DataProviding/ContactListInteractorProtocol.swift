//
//  ContactListInteractorProtocol.swift
//  Telephone Directory
//
//  Created by Diana Princess on 22.12.2022.
//

import Foundation

protocol ContactListInteractorProtocol {
    init(presenter: ContactListPresenterProtocol, networkService: NetworkServiceProtocol, router: RouterProtocol)
    func requestContacts(numberOfContacts: Int)
    
    func openContact(contact: ContactItem)
}
