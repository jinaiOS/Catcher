//
//  ConversationTableViewCell.swift
//  Catcher
//
//  Created by 김지은 on 2023/10/19.
//

import UIKit
import SDWebImage

class ConversationTableViewCell: UITableViewCell {

    static let identifier = "ConversationTableViewCell"

    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        return imageView
    }()

    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let userMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let newMessageCheckLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.numberOfLines = 0
        label.textColor = ThemeColor.primary
        return label
    }()
    
    private let newMessageTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.numberOfLines = 0
        label.textColor = .systemGray2
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userMessageLabel)
        contentView.addSubview(newMessageTimeLabel)
        contentView.addSubview(newMessageCheckLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        userImageView.frame = CGRect(x: 10,
                                     y: 10,
                                     width: 50,
                                     height: 50)

        userNameLabel.frame = CGRect(x: userImageView.right + 10,
                                     y: 10,
                                     width: contentView.width - 40 - userImageView.width - newMessageCheckLabel.width,
                                     height: (contentView.height-20)/2)

        userMessageLabel.frame = CGRect(x: userImageView.right + 10,
                                        y: userNameLabel.bottom,
                                        width: contentView.width - 40 - userImageView.width - newMessageCheckLabel.width,
                                        height: (contentView.height-20)/2)
        
        newMessageTimeLabel.frame = CGRect(x: contentView.right - 50,
                                           y: 10,
                                           width: 50,
                                           height: (contentView.height-20)/2)
        
        newMessageCheckLabel.frame = CGRect(x: contentView.right - 60,
                                            y: userNameLabel.bottom,
                                            width: 50,
                                            height: (contentView.height-20)/2)
    }

    public func configure(with model: Conversation) {
        switch model.kind {
        case .Text:
            userMessageLabel.text = model.message
        case .Photo:
            userMessageLabel.text = "이미지"
        case .Video:
            userMessageLabel.text = "비디오"
        case .Location:
            userMessageLabel.text = "지도"
        }
        userNameLabel.text = model.name
        newMessageTimeLabel.text = Date.stringFromDate(date: Date.dateFromyyyyMMddHHmm(str: model.date) ?? .now, format: "HH:mm")
        newMessageCheckLabel.text = "읽지 않음"
        if model.senderUid != FirebaseManager().getUID ?? "" && model.isRead == false {
            newMessageCheckLabel.isHidden = false
        } else {
            newMessageCheckLabel.isHidden = true
        }
        
        ImageCacheManager.shared.loadImage(uid: model.otherUserUid) { [weak self] image in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.userImageView.backgroundColor = .clear
                self.userImageView.image = image
            }
        }
    }

}
