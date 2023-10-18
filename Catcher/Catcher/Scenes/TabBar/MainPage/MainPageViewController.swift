//
//  MainPageViewController.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import UIKit
import SnapKit
import SwiftUI

final class MainPageViewController: UIViewController {
    private let mainPageView = MainPageView()
    private let viewModel = MainPageViewModel()
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>?
    
    override func loadView() {
        super.loadView()
        
        view = mainPageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDataSource()
        setHeader()
        applyItems()
    }
}

extension MainPageViewController {
    func setDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(
            collectionView: mainPageView.collectionView,
            cellProvider: { collectionView, indexPath, itemIdentifier in
                switch itemIdentifier {
                case .random(let item), .near(let item), .new(let item), .pick(let item):
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: defaultSectionCell.identifier,
                        for: indexPath) as? defaultSectionCell else { return UICollectionViewCell() }
                    cell.configure(data: item)
                    return cell
                    
                case .rank(let item):
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: RankSectionCell.identifier,
                        for: indexPath) as? RankSectionCell else { return UICollectionViewCell() }
                    cell.configure(data: item)
                    return cell
                }
            })
    }
    
    func setHeader() {
        guard let dataSource = dataSource else { return }
        dataSource.supplementaryViewProvider = { [weak self] (collectionView, kind, indexPath) in
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: SectionHeader.identifier,
                for: indexPath) as? SectionHeader else {
                return SectionHeader()
            }
            let title = self?.viewModel.getSectionTitle(section: indexPath.section)
            header.configure(sectionTitle: title)
            return header
        }
    }
    
    func applyItems() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        let randomSection = Section(id: "Random")
        let rankSection = Section(id: "Rank")
        let nearSection = Section(id: "Near")
        let newSection = Section(id: "New")
        let pickSection = Section(id: "Pick")
        
        [randomSection, rankSection, nearSection, newSection, pickSection].forEach {
            snapshot.appendSections([$0])
        }
        
        snapshot.appendItems(viewModel.randomItems, toSection: randomSection)
        snapshot.appendItems(viewModel.rankItems, toSection: rankSection)
        snapshot.appendItems(viewModel.nearItems, toSection: nearSection)
        snapshot.appendItems(viewModel.newItems, toSection: newSection)
        snapshot.appendItems(viewModel.pickItems, toSection: pickSection)
        
        dataSource?.apply(snapshot)
    }
}

struct MainPageViewControllerPreView: PreviewProvider {
    static var previews: some View {
        MainPageViewController().toPreview().edgesIgnoringSafeArea(.all)
    }
}
