//
//  DefaultSectionCell.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import UIKit
import SnapKit

final class DefaultSectionCell: UICollectionViewCell {
    static let identifier = "defaultSectionCell"
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = AppConstraint.mainCellCornerRadius
        view.clipsToBounds = true
        view.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DefaultSectionCell {
    func configure(data: UserInfo) {
        ImageCacheManager.shared.loadImage(uid: data.uid) { [weak self] image in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.imageView.backgroundColor = .clear
                self.imageView.image = image
            }
        }
    }
}

private extension DefaultSectionCell {
    func setUI() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 6
        layer.shadowOpacity = 0.5
        layer.masksToBounds = false
    }
    
    func setLayout() {
        self.addSubview(imageView)
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
