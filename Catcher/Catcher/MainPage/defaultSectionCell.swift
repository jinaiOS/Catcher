//
//  defaultCell.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import UIKit
import SnapKit

final class defaultSectionCell: UICollectionViewCell {
    static let identifier = "defaultSectionCell"
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension defaultSectionCell {
    func configure(data: HomeItem) {
//        imageView.image = data.imageUrl
        imageView.image = UIImage(named: "sample1")
    }
}

private extension defaultSectionCell {
    func setLayout() {
        self.addSubview(imageView)
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
