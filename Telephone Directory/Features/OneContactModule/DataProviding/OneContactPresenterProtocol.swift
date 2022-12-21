//
//  OneContactPresenterProtocol.swift
//  Telephone Directory
//
//  Created by Diana Princess on 07.12.2022.
//

import Foundation

protocol OneContactPresenterProtocol: class {
    init(view: OneContactViewProtocol, networkService: NetworkServiceProtocol, router: RouterProtocol, fullName: String, phone: String, cell: String, email: String, largeImgStr: String, nat: String)
    func findImage()
    
}
