//
//  ContactListViewProtocol.swift
//  Telephone Directory
//
//  Created by Diana Princess on 07.12.2022.
//
import UIKit

protocol ContactListViewProtocol: AnyObject {
    func updateContactList(_ list: [ContactPresentationModel])
    func setRequestFailureView()
    func checkIfContactListIsFiltered() -> Bool
}
