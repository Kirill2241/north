//
//  OneContactInteractorProtocol.swift
//  Telephone Directory
//
//  Created by Diana Princess on 23.12.2022.
//

import Foundation

protocol OneContactInteractorProtocol {
    init(presenter: OneContactPresenterProtocol, networkService: NetworkServiceProtocol, router: RouterProtocol, oneContact: ContactItem)
    func requestImage(imageString: String)
}
