//
//  ContactListViewController.swift
//  Telephone Directory
//
//  Created by Diana Princess on 30.11.2022.
//

import UIKit
import SnapKit

class ContactListViewController: UIViewController {
    
    var presenter: ContactListPresenterProtocol?
    private let tableView = UITableView(frame: .zero)
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let searchController = UISearchController(searchResultsController: nil)
    private let nothingFoundLabel : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 20)
        lbl.textColor = UIColor.darkGray
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.textAlignment = .center
        lbl.text = "По Вашему запросу ничего не найдено"
        return lbl
    }()
    private var contactList: [ContactPresentationModel] = []
    private lazy var dataSource = createDataSource()
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var listIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        configureViews()
        presenter?.tryRequest()
        // Do any additional setup after loading the view.
    }
    
    private func configureViews() {
        tableView.register(ContactTableViewCell.self, forCellReuseIdentifier: ContactTableViewCell.reuseId)
        tableView.dataSource = dataSource
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.snp.makeConstraints{ (maker) in
            maker.top.leading.trailing.bottom.equalToSuperview()
        }
        tableView.isHidden = true
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints{ (maker) in
            maker.centerX.equalToSuperview()
            maker.centerY.equalToSuperview()
        }
        view.addSubview(nothingFoundLabel)
        nothingFoundLabel.snp.makeConstraints{ (maker) in
            maker.centerX.centerY.equalToSuperview()
            maker.leading.equalToSuperview().offset(30)
            maker.trailing.equalToSuperview().inset(30)
            maker.height.equalTo(50)
        }
        nothingFoundLabel.isHidden = true
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск контактов"
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.backgroundColor = UIColor.white
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - Navigation
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ContactListViewController: ContactListViewProtocol {
    
    func updateContactList(_ list: [ContactPresentationModel]) {
        contactList = list
        if list.count == 0 {
            nothingFoundLabel.isHidden = false
            tableView.isHidden = true
        } else {
            nothingFoundLabel.isHidden = true
            tableView.isHidden = false
            navigationController?.navigationBar.isHidden = false
            updateDataSource(list)
        }
    }
    
    func setRequestFailureView(error: Error){
        let alert = UIAlertController(title: "При выполнении запроса произошла ошибка", message: "Пожалуйста, проверьте подключение. Ошибка: "+error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Повторить попытку", style: UIAlertAction.Style.default){ _ in
            self.presenter?.tryRequest()
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    func isLoading(_ isLoading: Bool) {
        isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
    
}

extension ContactListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text != nil {
            let listIsFiltered = searchController.isActive && !searchBarIsEmpty
            presenter?.filterContacts(searchController.searchBar.text!, listIsFiltered: listIsFiltered)
        }
    }
}

extension ContactListViewController {
    func createDataSource() -> UITableViewDiffableDataSource<String, ContactPresentationModel> {
        return UITableViewDiffableDataSource(
            tableView: self.tableView,
            cellProvider: { tableView,indexPath,contact in
                let cell = tableView.dequeueReusableCell(withIdentifier: ContactTableViewCell.reuseId, for: indexPath) as! ContactTableViewCell
                let defaultImage = UIImage(systemName: "person.fill")!
                switch contact.thumbnailState {
                case .downloaded(let data):
                    let image = UIImage(data: data)!
                    cell.configure(fullName: contact.fullname, photo: image)
                case .failed:
                    cell.configure(fullName: contact.fullname, photo: defaultImage)
                case .notDownloaded:
                    cell.configure(fullName: contact.fullname, photo: defaultImage)
                    self.presenter?.downloadThumbnailForContact(at: indexPath.row)
                }
                return cell
            }
        )
    }
    
    func updateDataSource(_ contacts: [ContactPresentationModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<String, ContactPresentationModel>()
        snapshot.appendSections(["1"])
        snapshot.appendItems(contacts)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
}


extension ContactListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let contactPresentationModel = contactList[indexPath.row]
            let id = contactPresentationModel.id
            presenter?.openContact(id: id)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
}
