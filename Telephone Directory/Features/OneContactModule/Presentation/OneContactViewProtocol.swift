//
//  OneContactViewProtocol.swift
//  Telephone Directory
//
//  Created by Diana Princess on 07.12.2022.
//

import UIKit

protocol OneContactViewProtocol: AnyObject {
    func reloadView(fullName: String, phone: String, cell: String, email: String)
    func setImage(data: Data)
    func setRequestFailureView()
}
