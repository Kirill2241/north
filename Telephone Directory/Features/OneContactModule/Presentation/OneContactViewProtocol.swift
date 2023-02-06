//
//  OneContactViewProtocol.swift
//  Telephone Directory
//
//  Created by Diana Princess on 07.12.2022.
//

import UIKit
import MessageUI

protocol OneContactViewProtocol: AnyObject {
    func render(_ option: OneContactViewController.RenderOptions)
    func dismissMessageController(_ controller: MFMessageComposeViewController)
}

extension OneContactViewController {
    struct RenderOptions {
        enum ImageState {
            case isLoading
            case error(Error)
            case downloaded(Data?)
        }
        let imageState: ImageState
    }
}
