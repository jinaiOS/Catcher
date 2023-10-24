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
        view.contentMode = .scaleAspectFill
        view.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
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
    func configure(data: HomeItem, index: Int) {
        rankLabel.text = "\(index + 1)"
        ImageCacheManager.shared.loadImage(uid: data.info.uid) { [weak self] image in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.imageView.backgroundColor = .clear
                self.imageView.image = image
            }
        }
    }
}

private extension RankSectionCell {
    func setLayout() {
        [imageView, rankLabel].forEach {
            self.addSubview($0)
        }
        
        imageView.snp.makeConstraints {
            $0.top.trailing.bottom.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.8)
        }
        
        rankLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.bottom.equalToSuperview().offset(22)
        }
    }
    
    func getTextSize(text: String, font: UIFont) -> (CGFloat, CGFloat) {
        let label = UILabel()
        label.font = font
        label.text = text
        label.sizeToFit()
        return (label.frame.width, label.frame.height)
    }
}

