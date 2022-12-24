//
//  ContactListPresenter.swift
//  Telephone Directory
//
//  Created by Diana Princess on 30.11.2022.
//

import Foundation
import UIKit

class ContactListPresenter: NSObject, ContactListPresenterProtocol {
    
    
    weak var view: ContactListViewProtocol?
    var interactor: ContactListInteractorProtocol?
    var allContacts: [(ContactItem, Data?)] = []
    var filteredContacts: [(ContactItem, Data?)] = []
    var searchBarIsEmpty: Bool = true
    required init(view: ContactListViewProtocol) {
        self.view = view
        super.init()
    }
    
    func requestContacts(numberOfContacts: Int) {
        //interactor?.requestContacts(numberOfContacts: numberOfContacts)
        /*
        let response = interactor?.requestContacts(numberOfContacts: numberOfContacts)
        switch response {
        case .success(let contactList):
            contactList.forEach({allContacts.append($0)})
            view?.setContentView()
        case .failure(_):
            view?.setRequestFailureView()
        case .none:
            view?.setRequestFailureView()
        }
        
        let networkData = await networkService.processContactListRequest(numberOfContacts, fields: fields)
        switch networkData.status {
        case .error:
            view?.setRequestFailureView()
        case .success:
            if networkData.result?.error != nil {
                view?.setAPIErrorView(errorString: (networkData.result?.error!)!)
            }else{
                for instance in networkData.result?.results ?? []{
                    let image = await requestImage(string: instance.picture.thumbnail)
                    let tuple = (instance, image)
                    allContacts.append(tuple)
                }
                view?.setContentView()
            }
        case .none:
            print("")
        }*/
    }
    
    
    /*
    func requestImage(string: String) async -> UIImage {
        guard let imageUrlString = string as? String else {
            return UIImage(named: "Error")!}
        let result = await networkService.requestImage(urlString: imageUrlString)
        switch result.status {
        case .success:
            return UIImage(data: result.data!)!
        case .error:
            return UIImage(named: "Error")!
        case .noConnection:
            return UIImage(named: "Error")!
        }
    }*/
    
    func filterContacts(_ searchText: String){
        filteredContacts = allContacts.filter({ (contactTuple: (ContactItem, Data?)) -> Bool in
            return contactTuple.0.fullname.lowercased().contains(searchText.lowercased())
        })
        view?.applyFilter()
    }
    
    func tryRequest() {
        interactor?.requestContacts(numberOfContacts: 1000)
    }
    
    func openOneContact(index: Int, filterIsUsed: Bool) {
        if filterIsUsed{
            let contactTuple = filteredContacts[index]
            interactor?.openContact(contact: contactTuple.0)
        }else{
            let contactTuple = allContacts[index]
            interactor?.openContact(contact: contactTuple.0)
        }
    }
    
    func fillViewWithContent() {
        //instances.forEach({allContacts.append($0)})
        view?.setContentView()
    }
    
    func collectData(_ data: Data?, contact: ContactItem) {
        allContacts.append((contact, data))
    }
    
    func errorAlert(error: HTTPError) {
        view?.setRequestFailureView()
    }
}
