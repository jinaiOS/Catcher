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
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        view.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        return view
    }()
    
    private lazy var nickNameLabel: UILabel = {
        let label = LabelFactory.makeLabel(
            text: nil,
            font: ThemeFont.bold(size: 30),
            textColor: .white,
            textAlignment: .left)
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOffset = CGSize(width: 2, height: 2)
        label.layer.shadowRadius = 5
        label.layer.shadowOpacity = 0.5
        return label
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
    func configure(data: UserInfo, nickNameOn: Bool) {
        ImageCacheManager.shared.loadImage(uid: data.uid) { [weak self] image in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.imageView.backgroundColor = .clear
                self.imageView.image = image
            }
        }
        if nickNameOn {
            nickNameLabel.text = data.nickName
        } else {
            nickNameLabel.text = nil
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
        [imageView, nickNameLabel].forEach {
            self.addSubview($0)
        }
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        nickNameLabel.snp.makeConstraints {
            $0.leading.bottom.equalToSuperview().inset(AppConstraint.defaultSpacing)
        }
    }
}
