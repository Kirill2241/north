//
//  OneContactPresenterProtocol.swift
//  Telephone Directory
//
//  Created by Diana Princess on 07.12.2022.
//

import Foundation
import MessageUI

protocol OneContactPresenterProtocol: AnyObject {
    func updateContactInfo() -> ContactDetailedInfo
    func requestImage()
    func makeACall(type: PhoneTypes)
    func sendSMS(type: PhoneTypes)
}
