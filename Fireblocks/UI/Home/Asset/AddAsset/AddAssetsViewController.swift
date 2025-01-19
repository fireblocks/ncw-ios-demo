//
//  AddAssetsViewController.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 04/10/2023.
//

import Foundation
import UIKit
import Combine
#if DEV
import EmbeddedWalletSDKDev
#else
import EmbeddedWalletSDK
#endif


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

    @IBOutlet weak var addAssetButtonBC: NSLayoutConstraint!
    
    let viewModel: AddAssetsViewModel
    weak var delegate: AddAssetsViewControllerDelegate?
    var cancellable = Set<AnyCancellable>()
    
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

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let height = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 5.0
        self.addAssetButtonBC.constant = height
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }

    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.addAssetButtonBC.constant = 5
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }


    @objc func handleCloseTap() {
        self.dismiss(animated: true)
    }
    
    @IBAction func continueTapped(_ sender: AppActionBotton) {
        showActivityIndicator()
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
        cell.configCellWith(assetToAdd: asset)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? AddAssetViewCell {
            viewModel.didSelect(indexPath: indexPath)
            let asset = viewModel.getAssets()[indexPath.row]
            cell.configCellWith(assetToAdd: asset)
            addAssetButton.config(title: "Add Asset", image: UIImage(named: "plus"), style: viewModel.getSelectedCount() == 0 ? .Disabled : .Primary)
            addAssetButton.isEnabled = viewModel.getSelectedCount() > 0
            addAssetButton.config(title: viewModel.getSelectedCount() > 1 ? "Add Assets" : "Add Asset", image: UIImage(named: "plus"), style: .Disabled)
        }
    }

}

extension AddAssetsViewController: AddAssetsDelegate {
    func reloadData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func failedToLoadAssets() {
        DispatchQueue.main.async {
            self.showAlertView(message: "Failed to load assets from server. Please try again.")
        }
    }
    
    func didLoadAssets() {
        DispatchQueue.main.async {
            self.hideActivityIndicator()
            self.tableView.reloadData()
            self.searchBar.isUserInteractionEnabled = true
        }
    }
       
    func didAddAssets(addedAssets: [Asset], failedAssets: [Asset]) {
        DispatchQueue.main.async {
            self.hideActivityIndicator()
            failedAssets.forEach { asset in
                print("Failed to load asset: \(asset.symbol)")
            }
            self.delegate?.dismissAddAssets(addedAssets: addedAssets, failedAssets: failedAssets)
        }
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
