//
//  ChooseAssetViewController.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 20/06/2023.
//

import UIKit

class ChooseAssetViewController: UIViewController {
    
    static let identifier = "ChooseAssetViewController"

    var viewModel = ChooseAssetViewModel()
    
    @IBOutlet weak var tableView: UITableView! {
        didSet{
            tableView.register(AssetViewCell.nib, forCellReuseIdentifier: AssetViewCell.nibName)
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(handleCloseTap))]
        self.navigationItem.title = "Asset"
    }
    
    @objc func handleCloseTap() {
        navigationController?.popViewController(animated: true)
    }

}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension ChooseAssetViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getAssetsCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AssetViewCell.nibName, for: indexPath) as? AssetViewCell  else {
            return UITableViewCell()
        }
        
        let asset = viewModel.getAssetFor(index: indexPath.row)
        cell.configCellWith(asset: asset, isBlockchainHidden: true)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.getdataForNextScreen(index: indexPath.row)
    }
    
    private func navigateToNextScreen(with asset: Asset){
        switch viewModel.chooseAssetFlowType {
        case .send:
            let vc = AmountToSendViewController(nibName: "AmountToSendViewController", bundle: nil)
            vc.viewModel.asset = asset
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        case .receive:
            let vc = ReceiveViewController(nibName: "ReceiveViewController", bundle: nil)
            vc.viewModel.asset = asset
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        } 
    }
}

//MARK: - ChooseAssetViewModelDelegate
extension ChooseAssetViewController: ChooseAssetViewModelDelegate {
    
    func navigateToNextScreen(asset: Asset) {
        DispatchQueue.main.async { [weak self] in
            self?.navigateToNextScreen(with: asset)
        }
    }
}
