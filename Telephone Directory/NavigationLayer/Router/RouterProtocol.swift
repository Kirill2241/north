//
//  RouterProtocol.swift
//  Telephone Directory
//
//  Created by Diana Princess on 07.12.2022.
//

import Foundation
import UIKit
protocol RouterBasic {
    var navigationController: UINavigationController? { get set }
    var moduleBuilder: ModuleBuilderProtocol? { get set }
}

protocol RouterProtocol: RouterBasic {
    func initialViewController()
    func openContact(fullName: String, phone: String, cell: String, email: String, largeImgStr: String, nat: String)
}
