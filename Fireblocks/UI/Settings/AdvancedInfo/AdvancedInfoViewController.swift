//
//  AdvancedInfoViewController.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 27/06/2023.
//

import UIKit

class AdvancedInfoViewController: UIViewController {
    
    static let identifier = "AdvancedInfoViewController"
    
    @IBOutlet weak var deviceIdLabel: UILabel!
    @IBOutlet weak var algorithmsCollectionView: UICollectionView!
    
    private let viewModel = AdvancedInfoViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Advanced Info"
        setAccountData()
        initCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func setAccountData() {
        deviceIdLabel.text = viewModel.getDeviceId()
    }
    
    private func initCollectionView() {
        algorithmsCollectionView.dataSource = self
        algorithmsCollectionView.delegate = self
        algorithmsCollectionView.register(UINib(nibName: MpcKeyCellView.identifier, bundle: nil), forCellWithReuseIdentifier: MpcKeyCellView.identifier)
    }
}

extension AdvancedInfoViewController:
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout
{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getMpcKeys().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MpcKeyCellView.identifier, for: indexPath) as! MpcKeyCellView
        let mpcKey = viewModel.getMpcKeys()[indexPath.row]
        cell.setData(mpcKey: mpcKey)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.bounds.width
        let cellHeight = CGFloat(150)
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
}
