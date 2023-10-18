//
//  RankSectionCell.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import UIKit
import SnapKit

final class RankSectionCell: UICollectionViewCell {
    static let identifier = "RankSectionCell"
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleToFill
        return view
    }()
    
    private lazy var rankLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.bold(size: 60)
        label.textColor = ThemeColor.sectionLabel
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RankSectionCell {
    func configure(data: HomeItem) {
        imageView.image = UIImage(named: "sample2")
        rankLabel.text = data.rank
    }
}

private extension RankSectionCell {
    func setLayout() {
        [imageView, rankLabel].forEach {
            self.addSubview($0)
        }
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
//            $0.top.trailing.bottom.equalToSuperview()
//            $0.width.equalToSuperview().multipliedBy(0.8)
        }
        
        rankLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.bottom.equalToSuperview().offset(22)
        }
    }
}
