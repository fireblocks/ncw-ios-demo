//
//  AddAssetsViewController.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 04/10/2023.
//

import Foundation
import UIKit

protocol AddAssetsViewControllerDelegate: AnyObject {
    func dismissAddAssets(addedAssets: [Asset], failedAssets: [Asset])
}

class AddAssetsViewController: UIViewController {

//MARK: - PROPERTIES
    @IBOutlet weak var addAssetButton: AppActionBotton!
    @IBOutlet weak var noResultsView: UIView!
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.register(AddAssetViewCell.nib, forCellReuseIdentifier: AddAssetViewCell.nibName)
            tableView.dataSource = self
            tableView.delegate = self
        }
    }

    let viewModel: AddAssetsViewModel
    weak var delegate: AddAssetsViewControllerDelegate?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(devideId: String, delegate: AddAssetsViewControllerDelegate?) {
        self.delegate = delegate
        self.viewModel = AddAssetsViewModel(deviceId: devideId)
        super.init (nibName: "AddAssetsViewController", bundle: nil)
    }

//MARK: - LIFECYCLE functions
    override func viewDidLoad() {
        super.viewDidLoad()
        showActivityIndicator(isBackgroundEnabled: false)
        viewModel.delegate = self
        searchBar.searchTextField.backgroundColor = UIColor(named: "searchBar")
        searchBar.searchTextField.returnKeyType = .done
        searchBar.isUserInteractionEnabled = false
        self.navigationItem.title = "Select asset"
        addAssetButton.config(title: "Add Asset", image: UIImage(named: "plus"), style: .Disabled)
        addAssetButton.isEnabled = false
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(handleCloseTap))]

    }
    
    @objc func handleCloseTap() {
        self.dismiss(animated: true)
    }
    
    @IBAction func continueTapped(_ sender: AppActionBotton) {
        showActivityIndicator(isBackgroundEnabled: false)
        viewModel.createAsset()
    }
    
    private func showAlertView(message: String){
        showAlert(description: message, bottomAnchor: addAssetButton.topAnchor)
    }
}

extension AddAssetsViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getAssetsCount()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AddAssetViewCell.nibName, for: indexPath) as? AddAssetViewCell else {
            return UITableViewCell()
        }

        let asset = viewModel.getAssets()[indexPath.row]
        cell.configCellWith(asset: asset)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? AddAssetViewCell {
            cell.setSelected(isSelected: viewModel.didSelect(indexPath: indexPath))
            addAssetButton.config(title: "Add Asset", image: UIImage(named: "plus"), style: viewModel.getSelectedCount() == 0 ? .Disabled : .Primary)
            addAssetButton.isEnabled = viewModel.getSelectedCount() > 0
            addAssetButton.config(title: viewModel.getSelectedCount() > 1 ? "Add Assets" : "Add Asset", image: UIImage(named: "plus"), style: .Disabled)
        }
    }

}

extension AddAssetsViewController: AddAssetsDelegate {
    func reloadData() {
        self.tableView.reloadData()
    }
    
    func failedToLoadAssets() {
        showAlertView(message: "Failed to load assets from server. Please try again.")
    }
    
    func didLoadAssets() {
        hideActivityIndicator()
        self.tableView.reloadData()
        searchBar.isUserInteractionEnabled = true
    }
       
    func didAddAssets(addedAssets: [Asset], failedAssets: [Asset]) {
        hideActivityIndicator()
        failedAssets.forEach { asset in
            print("Failed to load asset: \(asset.symbol)")
        }
        self.delegate?.dismissAddAssets(addedAssets: addedAssets, failedAssets: failedAssets)
    }
}

extension AddAssetsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchDidChange(searchText: searchText)
        noResultsView.isHidden = viewModel.getAssetsCount() > 0

    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
