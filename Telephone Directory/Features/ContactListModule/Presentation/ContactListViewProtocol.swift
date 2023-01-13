//
//  ContactListViewProtocol.swift
//  Telephone Directory
//
//  Created by Diana Princess on 07.12.2022.
//
import UIKit

protocol ContactListViewProtocol: AnyObject {
    func setViewControllerDataSource(_ source: [Int: ContactPresentationModel])
    func setContentView()
    func setRequestFailureView()
    func applyFilter()
    func checkIfContactListIsFiltered() -> Bool
    func createNothingFoundLabel()
    func removeNothingFoundLabel()
}
