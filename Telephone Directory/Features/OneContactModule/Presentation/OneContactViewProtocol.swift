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
}

extension OneContactViewController {
    struct RenderOptions {
        enum ScreenState {
            case imageIsLoading
            case error(Error)
            case downloaded(Data?)
            case smsComposing(_ controller: MFMessageComposeViewController)
            case smsComposingEnded(_ controller: MFMessageComposeViewController)
        }
        let screenState: ScreenState
    }
}
