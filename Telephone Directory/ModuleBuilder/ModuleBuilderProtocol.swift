//
//  ModuleBuilderProtocol.swift
//  Telephone Directory
//
//  Created by Diana Princess on 07.12.2022.
//

import Foundation
import UIKit
protocol ModuleBuilderProtocol {
    func buildContactList(router: RouterProtocol) -> UIViewController
    func buildOneContact(router: RouterProtocol, fullName: String, phone: String, cell: String, email: String, largeImgStr: String, nat: String) -> UIViewController
}
