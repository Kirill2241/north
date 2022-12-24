//
//  OneContactPresenterProtocol.swift
//  Telephone Directory
//
//  Created by Diana Princess on 07.12.2022.
//

import Foundation

protocol OneContactPresenterProtocol: class {
    init(view: OneContactViewProtocol)
    func setImage(data: Data)
    
    func presentContactInfo(contact: ContactItem)
    func displayErrorMessage()
    func findImage()
}
