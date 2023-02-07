//
//  ContactListViewController.swift
//  Telephone Directory
//
//  Created by Diana Princess on 30.11.2022.
//

import UIKit
import SnapKit

class ContactListViewController: UIViewController {
    
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
    
    private lazy var dataSource = createDataSource()
    var presenter: ContactListPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        configureViews()
        presenter?.tryRequest()
        // Do any additional setup after loading the view.
    }

}

// MARK: - Set up UI
extension ContactListViewController {
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
    
    private func setRequestFailureView(error: Error){
        let alert = UIAlertController(title: "При выполнении запроса произошла ошибка", message: "Пожалуйста, проверьте подключение. Ошибка: "+error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Повторить попытку", style: UIAlertAction.Style.default){ _ in
            self.presenter?.tryRequest()
        })
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: ViewProtocol implementation
extension ContactListViewController: ContactListViewProtocol {
    func render(_ options: RenderOptions) {
        switch options.state {
        case .isLoading:
            activityIndicator.startAnimating()
        case .error(let error):
            activityIndicator.stopAnimating()
            setRequestFailureView(error: error)
        case .updated(let list):
            activityIndicator.stopAnimating()
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
    }
}

// MARK: SearchController
extension ContactListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        presenter?.filterContacts(searchController.searchBar.text)
    }
}

// MARK: - Diffable Data source for TableView
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
                    if !tableView.isDragging && !tableView.isDecelerating {
                        self.presenter?.downloadThumbnailForContact(at: indexPath.row)
                    }
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

// MARK: TableView Delegate
extension ContactListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let contactPresentationModel = dataSource.snapshot().itemIdentifiers[indexPath.row]
            let id = contactPresentationModel.id
            presenter?.openContact(id: id)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        presenter?.imageDownloadingControl(true, [])
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            if let visibleRows = tableView.indexPathsForVisibleRows {
                let indexes = visibleRows.map { $0.row }
                presenter?.imageDownloadingControl(false, indexes)
            }
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let visibleRows = tableView.indexPathsForVisibleRows {
            let indexes = visibleRows.map { $0.row }
            presenter?.imageDownloadingControl(false, indexes)
        }
    }
}
