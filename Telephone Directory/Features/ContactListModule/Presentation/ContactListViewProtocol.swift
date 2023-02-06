//
//  ContactListViewProtocol.swift
//  Telephone Directory
//
//  Created by Diana Princess on 07.12.2022.
//
import UIKit

protocol ContactListViewProtocol: AnyObject {
    func render(_ options: ContactListViewController.RenderOptions)
}

extension ContactListViewController {
    public struct RenderOptions {
        enum ProcessState {
            case isLoading
            case error(Error)
            case updated([ContactPresentationModel])
        }
        let state: ProcessState
        //let contactsList: [ContactPresentationModel]
    }
}
