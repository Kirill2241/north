//
//  OneContactViewProtocol.swift
//  Telephone Directory
//
//  Created by Diana Princess on 07.12.2022.
//

import UIKit
import MessageUI

protocol OneContactViewProtocol: MFMessageComposeViewControllerDelegate {
    func reload(fullName: String, phone: String, cell: String, email: String)
    
    func setImage(image: UIImage)
}
