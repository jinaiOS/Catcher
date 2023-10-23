//
//  MainPageViewController.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import UIKit
import Combine
import SnapKit
import SwiftUI

final class MainPageViewController: UIViewController {
    private let mainPageView = MainPageView()
    private let viewModel = MainPageViewModel()
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>?
    private var cancellables = Set<AnyCancellable>()
    
    override func loadView() {
        super.loadView()
        
        view = mainPageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        setDataSource()
        setHeader()
        bind()
        viewModel.fetchMainPageData()
    }
}

private extension MainPageViewController {
    func configure() {
        mainPageView.collectionView.delegate = self
    }
    
    func bind() {
        viewModel.mainSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                guard let self = self else { return }
                applyItems(data: data)
            }.store(in: &cancellables)
    }
}

private extension MainPageViewController {
    func setDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(
            collectionView: mainPageView.collectionView,
            cellProvider: { collectionView, indexPath, itemIdentifier in
                switch itemIdentifier {
                case .random(let item), .near(let item), .new(let item), .pick(let item):
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: DefaultSectionCell.identifier,
                        for: indexPath) as? DefaultSectionCell else { return UICollectionViewCell() }
                    cell.configure(data: item)
                    return cell
                    
                case .rank(let item):
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: RankSectionCell.identifier,
                        for: indexPath) as? RankSectionCell else { return UICollectionViewCell() }
                    cell.configure(data: item, index: indexPath.item)
                    return cell
                }
            })
    }
    
    func setHeader() {
        guard let dataSource = dataSource else { return }
        dataSource.supplementaryViewProvider = { [weak self] (collectionView, kind, indexPath) in
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: SectionHeaderView.identifier,
                for: indexPath) as? SectionHeaderView else {
                return SectionHeaderView()
            }
            let title = self?.viewModel.getSectionTitle(section: indexPath.section)
            header.configure(sectionTitle: title)
            return header
        }
    }
    
    func applyItems(data: MainItems) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        
        let randomSection = Section(id: SectionName.random.sectionID)
        let rankSection = Section(id: SectionName.rank.sectionID)
        let nearSection = Section(id: SectionName.near.sectionID)
        let newSection = Section(id: SectionName.new.sectionID)
        let pickSection = Section(id: SectionName.pick.sectionID)
        
        [randomSection, rankSection, nearSection, newSection, pickSection].forEach {
            snapshot.appendSections([$0])
        }
        
        snapshot.appendItems(data.random, toSection: randomSection)
        snapshot.appendItems(data.rank, toSection: rankSection)
        snapshot.appendItems(data.near, toSection: nearSection)
        snapshot.appendItems(data.new, toSection: newSection)
        snapshot.appendItems(data.pick, toSection: pickSection)
        dataSource?.apply(snapshot)
    }
}

extension MainPageViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.item
        switch indexPath.section {
        case 0:
            let items = viewModel.mainSubject.value.random
            print(items[index])
            
        case 1:
            let items = viewModel.mainSubject.value.rank
            print(items[index])
            
        case 2:
            let items = viewModel.mainSubject.value.near
            print(items[index])
            
        case 3:
            let items = viewModel.mainSubject.value.new
            print(items[index])
            
        case 4:
            let items = viewModel.mainSubject.value.pick
            print(items[index])
            
        default:
            break
        }
    }
}

struct MainPageViewControllerPreView: PreviewProvider {
    static var previews: some View {
        MainPageViewController().toPreview().edgesIgnoringSafeArea(.all)
    }
}
