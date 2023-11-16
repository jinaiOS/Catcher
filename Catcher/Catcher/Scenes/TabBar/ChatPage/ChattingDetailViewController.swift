//
//  ChattingDetailViewController.swift
//  Catcher
//
//  Created by 김지은 on 2023/10/19.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import SDWebImage
import AVFoundation
import AVKit
import CoreLocation
import Alamofire

/**
 @class ChattingDetailViewController.swift
 
 @brief MessagesViewController
 
 @detail 채팅 리스트 내부의 채팅 대화를 불러온다.
 */
final class ChattingDetailViewController: MessagesViewController {
    
    /// 프로필 이미지 - 나
    var senderPhotoURL: URL?
    /// 프로필 이미지 - 상대
    var otherUserPhotoURL: URL?
    
    var modalChecking = false
    
    public static let dateFormatter: DateFormatter = {
        let formattre = DateFormatter()
        formattre.dateFormat = "yyyy-MM-dd HH:mm"
        formattre.dateStyle = .medium
        formattre.timeStyle = .long
        formattre.locale = .current
        return formattre
    }()
    
    ///
    public var otherUserUid: String
    
    public var isNewConversation = false
    
    /// 메시지 데이터
    private var messages = [Message]()
    
    private var selfSender: Sender? {
        return Sender(photoURL: "",
                      senderId: FirebaseManager().getUID ?? "",
                      displayName: "Me")
    }
    
    var vBackHeader: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    /** @brief 공통 헤더 객체 */
    var headerView : CommonHeaderView!
    
    var headerTitle: String?
    
    private let indicator = UIActivityIndicatorView()
    
    private lazy var indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.5)
        return view
    }()
    
    init(otherUid: String) {
        self.otherUserUid = otherUid
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        view.backgroundColor = .red

        modalCheckToHeaderView(modalCheck: modalChecking)
        setHeaderViewLayout()
        messageCollectionViewDelegate()
        setupInputButton()
        setIndicatorLayout()
        
        guard let uid = FirebaseManager().getUID else { return }
        listenForMessages(id: uid, shouldScrollToBottom: true)
    }
    
    func messageCollectionViewDelegate() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.contentInset = UIEdgeInsets(top: 100, left: 0, bottom: 70, right: 0)
        
        messageInputBar.delegate = self
    }
    
    func setHeaderViewLayout() {
        headerView.btnBack.addTarget(self, action: #selector(backButtonTouched(sender:)), for: .touchUpInside)
        
        if !Common.IS_IPHONE_SE() {
            self.view.addSubview(vBackHeader)
        }
        self.view.addSubview(headerView)
        
        vBackHeader.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(headerView)
        }
    }
    
    /**
     @brief 인디케이터 layout 및 환경 설정
    */
    func modalCheckToHeaderView(modalCheck: Bool) {
        if modalChecking {
            headerView = CommonHeaderView.init(frame: CGRect.init(x: 0, y: 0, width: Common.SCREEN_WIDTH(), height: 50))
            headerView.lblTitle.text = headerTitle
            headerView.btnBack.isHidden = true
        } else {
            //iphone x의 경우 헤더 위치를 재설정한다.
            headerView = CommonHeaderView.init(frame: CGRect.init(x: 0, y: Common.kStatusbarHeight, width: Common.SCREEN_WIDTH(), height: 50))
            headerView.lblTitle.text = title
        }
        
    }
    
    /**
     @brief 인디케이터 layout 및 환경 설정
    */
    func setIndicatorLayout() {
        indicatorView.addSubview(indicator)
        
        view.addSubview(indicatorView)
        
        indicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        indicatorView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        indicator.hidesWhenStopped = true
        indicator.stopAnimating()
        indicator.style = .large
        indicator.color = .systemOrange
        indicatorView.isHidden = true
    }
    
    
    
    func processIndicatorView(isHide: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            indicatorView.isHidden = isHide
            if isHide {
                indicator.stopAnimating()
            } else {
                indicator.startAnimating()
            }
        }
    }
    
    private func setupInputButton() {
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        button.onTouchUpInside { [weak self] _ in
            self?.presentInputActionSheet()
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
    }
    
    private func presentInputActionSheet() {
        let actionSheet = UIAlertController(title: "Attach Media",
                                            message: "What would you like to attach?",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoInputActionsheet()
        }))
        actionSheet.addAction(UIAlertAction(title: "Video", style: .default, handler: { [weak self]  _ in
            self?.presentVideoInputActionsheet()
        }))
        actionSheet.addAction(UIAlertAction(title: "Location", style: .default, handler: { [weak self]  _ in
            self?.presentLocationPicker()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
    }
    
    private func presentLocationPicker() {
        let vc = LocationPickerViewController(coordinates: nil, isSendUsable: true)
        vc.title = "Pick Location"
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.completion = { [weak self] selectedCoorindates in
            
            guard let strongSelf = self else {
                return
            }
            
            guard let messageId = strongSelf.createMessageId(),
                  let name = strongSelf.headerTitle,
                  let selfSender = strongSelf.selfSender else {
                return
            }
            
            let longitude: Double = selectedCoorindates.longitude
            let latitude: Double = selectedCoorindates.latitude
            
            CommonUtil.print(output:"long=\(longitude) | lat= \(latitude)")
            
            
            let location = Location(location: CLLocation(latitude: latitude, longitude: longitude),
                                    size: .zero)
            
            let message = Message(sender: selfSender,
                                  messageId: messageId,
                                  sentDate: Date.dateFromyyyyMMddHHmm(str: Date.stringFromDate(date: Date()))!,
                                  kind: .location(location))
            if !strongSelf.isNewConversation {
                DatabaseManager.shared.sendMessage(otherUserUid: strongSelf.otherUserUid, name: name, newMessage: message, completion: { success in
                    if success {
                        self?.requestPush(message: message)
                        CommonUtil.print(output:"sent location message")
                    }
                    else {
                        CommonUtil.print(output:"failed to send location message")
                    }
                })
            } else {
                DatabaseManager.shared.createNewConversation(otherUserUid: strongSelf.otherUserUid, firstMessage: message, completion: { success in
                    if success {
                        self?.requestPush(message: message)
                        CommonUtil.print(output:"sent location message")
                    }
                    else {
                        CommonUtil.print(output:"failed to send location message")
                    }
                })
            }
        }
        present(vc, animated: true)
    }
    
    private func presentPhotoInputActionsheet() {
        let actionSheet = UIAlertController(title: "Attach Photo",
                                            message: "Where would you like to attach a photo from",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { [weak self] _ in
            
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
    }
    
    private func presentVideoInputActionsheet() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        picker.mediaTypes = ["public.movie"]
        picker.videoQuality = .typeMedium
        self.present(picker, animated: true)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
    
}
extension ChattingDetailViewController {
    private func listenForMessages(id: String, shouldScrollToBottom: Bool) {
        self.processIndicatorView(isHide: false)
        DatabaseManager.shared.getAllMessagesForConversation(with: otherUserUid, completion: { [weak self] result in
            switch result {
            case .success(let messages):
                CommonUtil.print(output:"success in getting messages: \(messages)")
                guard !messages.isEmpty else {
                    CommonUtil.print(output:"messages are empty")
                    return
                }
                self?.messages = messages
                self?.readMessage()
                self?.isNewConversation = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    self?.messagesCollectionView.scrollToLastItem()
                }
                self?.processIndicatorView(isHide: true)
            case .failure(let error):
                CommonUtil.print(output:"failed to get messages: \(error)")
                self?.isNewConversation = true
                self?.processIndicatorView(isHide: true)
            }
        })
    }
    
    private func readMessage() {
        self.processIndicatorView(isHide: false)
        DatabaseManager.shared.readMessage(otherUserUid: otherUserUid, completion: { success in
            if success {
                CommonUtil.print(output: "Read Message")
                self.processIndicatorView(isHide: true)
            }
            else {
                CommonUtil.print(output: "Read Message Error")
                self.processIndicatorView(isHide: true)
            }
        })
    }
    
}
// MARK: navigationcontroller 관리
extension ChattingDetailViewController {
    /**
     @brief backButton을 눌렀을때 들어오는 이벤트
     
     @param sender 버튼 객체
     */
    @objc func backButtonTouched(sender : UIButton)
    {
        navigationPopViewController(animated: true) { () -> (Void) in }
    }
    
    /**
     @brief deleteCount만큼 뒤로 이동한다. 네비게이션 이동(이전단계로 이동)
     
     @param animated - 애니메이션 여부
     
     @param deleteCount - 삭제할 스택의 수 (입력하지 않으면 기본적으로 바로 앞으로 이동한다)
     
     @param completion - 실행 후 적용할 closure
     */
    func navigationPopViewController(animated : Bool, deleteCount : Int = 1, completion : (() -> (Void))?)
    {
        let array = AppDelegate.navigationViewControllers()
        
        if (array.count - deleteCount) <= 1
        {
            //쌓여있는 스택의 수보다 삭제하려는 수가 많으면 메인으로 이동한다.
            AppDelegate.applicationDelegate().navigationController?.popToRootViewController(animated: true)
            //            self.navigationController?.popToRootViewController(animated: true)
        }
        else
        {
            //쌓여있는 스택에서 count만큼 삭제 한 viewcontroller로 이동한다.
            var mArr = Array<UIViewController>()
            for index in 0..<array.count
            {
                if array.count - deleteCount == index
                {
                    break
                }
                mArr.append(array[index])
            }
            
            if mArr.count > 0
            {
                AppDelegate.applicationDelegate().navigationController?.popToViewController(mArr.last!, animated: true)
            }
        }
    }
}
// 이미지 및 비디오 선택을 처리하는 UIImagePickerControllerDelegate 및 UINavigationControllerDelegate 메서드 구현
extension ChattingDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // 이미지 선택 취소 시 호출되는 메서드
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    // 이미지 또는 비디오를 선택한 경우 호출되는 메서드
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let messageId = createMessageId(),
              let name = self.title,
              let selfSender = selfSender else {
            return
        }
        
        if let image = info[.editedImage] as? UIImage, let imageData =  image.pngData() {
            let fileName = "photo_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".png"
            // 이미지 업로드
            StorageManager.shared.uploadMessagePhoto(with: imageData, fileName: fileName, completion: { [weak self] result in
                guard let strongSelf = self else {
                    return
                }
                
                switch result {
                case .success(let urlString):
                    // 메시지 전송 준비
                    CommonUtil.print(output:"Uploaded Message Photo: \(urlString)")
                    
                    guard let url = URL(string: urlString),
                          let placeholder = UIImage(systemName: "plus") else {
                        return
                    }
                    
                    let media = Media(url: url,
                                      image: nil,
                                      placeholderImage: placeholder,
                                      size: .zero)
                    
                    let message = Message(sender: selfSender,
                                          messageId: messageId,
                                          sentDate: Date.dateFromyyyyMMddHHmm(str: Date.stringFromDate(date: Date()))!,
                                          kind: .photo(media))
                    
                    if strongSelf.isNewConversation {
                        DatabaseManager.shared.createNewConversation(otherUserUid: strongSelf.otherUserUid, firstMessage: message, completion: { success in
                            
                            if success {
                                CommonUtil.print(output:"sent photo message")
                                self?.requestPush(message: message)
                                self?.processIndicatorView(isHide: true)
                            }
                            else {
                                CommonUtil.print(output:"failed to send photo message")
                                self?.processIndicatorView(isHide: true)
                            }
                            
                        })
                    } else {
                        DatabaseManager.shared.sendMessage(otherUserUid: strongSelf.otherUserUid, name: name, newMessage: message, completion: { success in
                            
                            if success {
                                CommonUtil.print(output:"sent photo message")
                                self?.requestPush(message: message)
                                self?.processIndicatorView(isHide: true)
                            }
                            else {
                                CommonUtil.print(output:"failed to send photo message")
                                self?.processIndicatorView(isHide: true)
                            }
                            
                        })
                    }
                case .failure(let error):
                    CommonUtil.print(output:"message photo upload error: \(error)")
                    self?.processIndicatorView(isHide: true)
                }
            })
        }
        else if let videoUrl = info[.mediaURL] as? URL {
            let fileName = "photo_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".mov"
            // 비디오 업로드
            StorageManager.shared.uploadMessageVideo(with: videoUrl, fileName: fileName, completion: { [weak self] result in
                guard let strongSelf = self else {
                    return
                }
                
                switch result {
                case .success(let urlString):
                    // 메시지 전송 준비
                    CommonUtil.print(output:"Uploaded Message Video: \(urlString)")
                    
                    guard let url = URL(string: urlString),
                          let placeholder = UIImage(systemName: "plus") else {
                        return
                    }
                    
                    let media = Media(url: url,
                                      image: nil,
                                      placeholderImage: placeholder,
                                      size: .zero)
                    
                    let message = Message(sender: selfSender,
                                          messageId: messageId,
                                          sentDate: Date.dateFromyyyyMMddHHmm(str: Date.stringFromDate(date: Date()))!,
                                          kind: .video(media))
                    
                    if strongSelf.isNewConversation {
                        DatabaseManager.shared.createNewConversation(otherUserUid: strongSelf.otherUserUid, firstMessage: message, completion: { success in
                            
                            if success {
                                CommonUtil.print(output:"sent photo message")
                                self?.requestPush(message: message)
                                self?.processIndicatorView(isHide: true)
                            }
                            else {
                                CommonUtil.print(output:"failed to send photo message")
                                self?.processIndicatorView(isHide: true)
                            }
                            
                        })
                    } else {
                        DatabaseManager.shared.sendMessage(otherUserUid: strongSelf.otherUserUid, name: name, newMessage: message, completion: { success in
                            if success {
                                CommonUtil.print(output:"sent video message")
                                self?.requestPush(message: message)
                                self?.processIndicatorView(isHide: true)
                            }
                            else {
                                CommonUtil.print(output:"failed to send photo message")
                                self?.processIndicatorView(isHide: true)
                            }
                            
                        })
                    }
                case .failure(let error):
                    CommonUtil.print(output:"message photo upload error: \(error)")
                    self?.processIndicatorView(isHide: true)
                }
            })
        }
    }
    
}

extension ChattingDetailViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let selfSender = self.selfSender,
              let messageId = createMessageId() else {
            return
        }
        
        CommonUtil.print(output:"Sending: \(text)")
        
        let message = Message(sender: selfSender,
                              messageId: messageId,
                              sentDate: Date.dateFromyyyyMMddHHmm(str: Date.stringFromDate(date: Date()))!,
                              kind: .text(text))
        // Send Message
        if isNewConversation {
            // create convo in database
            DatabaseManager.shared.createNewConversation(otherUserUid: otherUserUid, firstMessage: message, completion: { [weak self] success in
                if success {
                    CommonUtil.print(output:"message sent")
                    self?.isNewConversation = false
                    self?.listenForMessages(id: self?.otherUserUid ?? "", shouldScrollToBottom: true)
                    self?.messageInputBar.inputTextView.text = ""
                    self?.processIndicatorView(isHide: true)
                } else {
                    CommonUtil.print(output:"failed ot send")
                    self?.processIndicatorView(isHide: true)
                }
            })
        } else {
            // append to existing conversation data
            DatabaseManager.shared.sendMessage(otherUserUid: otherUserUid, name: headerTitle ?? "", newMessage: message, completion: { [weak self] success in
                if success {
                    self?.messageInputBar.inputTextView.text = ""
                    CommonUtil.print(output:"message sent")
                    self?.processIndicatorView(isHide: true)
                } else {
                    CommonUtil.print(output:"failed to send")
                    self?.processIndicatorView(isHide: true)
                }
            })
        }
        requestPush(message: message)
    }
    
    func requestPush(message: Message) {
        let apiUrl = "https://fcm.googleapis.com/fcm/send"
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": ServerKey.Authorization
        ]
        
        var messageStr = ""
        
        switch message.kind {
        case .text(let messageText):
            messageStr = messageText
        case .attributedText(_):
            break
        case .photo(_):
            messageStr = "이미지"
            break
        case .video(_):
            messageStr = "비디오"
            break
        case .location(_):
            messageStr = "지도"
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .custom(_), .linkPreview(_):
            break
        }
        
        Task {
            let (result, error) = await FireStoreManager.shared.fetchFcmToken(uid: otherUserUid)
            if let error {
                CommonUtil.print(output: error.localizedDescription)
                return
            }
            
            let (nameResult, nameError) = await FireStoreManager.shared.fetchUserInfo(uuid: FirebaseManager().getUID ?? "")
            if let nameError {
                CommonUtil.print(output: nameError.localizedDescription)
                return
            }
            
            let parameters: [String: Any] = [
                "to": result ?? "",
                "notification": [
                    "title": nameResult?.nickName,
                    "body": messageStr
                ],
                "data": [
                    "otherUserUid": FirebaseManager().getUID ?? ""
                ]
            ]
            
            AF.request(apiUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                .response { response in
                    switch response.result {
                    case .success(let value):
                        print("API Success: \(String(describing: value))")
                    case .failure(let error):
                        print("API Error: \(error)")
                    }
                }
        }
    }
    
    private func createMessageId() -> String? {
        CommonUtil.print(output:"created message id: \(otherUserUid)")
        
        return otherUserUid
    }
    
}

extension ChattingDetailViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    var currentSender: MessageKit.SenderType {
        if let sender = selfSender {
            return sender
        }
        
        fatalError("Self Sender is nil, email should be cached")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let message = message as? Message else {
            return
        }
        
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else {
                return
            }
            imageView.sd_setImage(with: imageUrl, completed: nil)
        case .video(let video):
            guard let imageUrl = video.url else {
                return
            }
            var player : AVPlayer!
            var avPlayerLayer : AVPlayerLayer!
            player = AVPlayer(url: imageUrl)
            avPlayerLayer = AVPlayerLayer(player: player)
            avPlayerLayer.videoGravity = AVLayerVideoGravity.resize
            
            imageView.layer.addSublayer(avPlayerLayer)
        default:
            break
        }
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        let sender = message.sender
        if sender.senderId == selfSender?.senderId {
            // our message that we've sent
            return .link
        }
        
        return .secondarySystemBackground
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        let sender = message.sender
        
        if sender.senderId == selfSender?.senderId {
            if let currentUserImageURL = self.senderPhotoURL {
                avatarView.sd_setImage(with: currentUserImageURL, completed: nil)
            }
            else {
                ImageCacheManager.shared.loadImage(uid: FirebaseManager().getUID ?? "") { image in
                    DispatchQueue.main.async {
                        avatarView.image = image
                    }
                }
            }
        } else {
            ImageCacheManager.shared.loadImage(uid: otherUserUid) { image in
                DispatchQueue.main.async {
                    avatarView.image = image
                }
            }
        }
        
    }
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = Date.stringFromDate(date: message.sentDate, format: "MM/dd HH:mm")
        return NSAttributedString(string: dateString, attributes: [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.gray
        ])
    }
    //MARK: jingni 날짜 별로 헤더 다르게 설정
    //    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
    //            // 이전 섹션과 현재 섹션의 날짜를 비교하여 날짜가 바뀌면 새로운 날짜를 반환
    //            let currentSectionDate = message.sentDate
    //            let previousSectionDate = indexPath.section > 0 ? messages[indexPath.section - 1].sentDate : Date.distantPast
    //
    //            if !Calendar.current.isDate(currentSectionDate, inSameDayAs: previousSectionDate) {
    //                let formatter = DateFormatter()
    //                formatter.dateFormat = "MMM d, yyyy" // 원하는 날짜 형식으로 설정
    //                return NSAttributedString(string: formatter.string(from: currentSectionDate))
    //            }
    //
    //            return nil
    //        }
}

extension ChattingDetailViewController: MessageCellDelegate {
    func didTapMessage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        
        let message = messages[indexPath.section]
        
        switch message.kind {
        case .location(let locationData):
            let coordinates = locationData.location.coordinate
            let vc = LocationPickerViewController(coordinates: coordinates, isSendUsable: false)
            
            vc.title = "Location"
            present(vc, animated: true)
        default:
            break
        }
    }
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        
        let message = messages[indexPath.section]
        
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else {
                return
            }
            let vc = PhotoViewerViewController(with: imageUrl)
            navigationController?.pushViewController(vc, animated: true)
        case .video(let media):
            guard let videoUrl = media.url else {
                return
            }
            
            let vc = AVPlayerViewController()
            vc.player = AVPlayer(url: videoUrl)
            present(vc, animated: true)
        default:
            break
        }
    }
}
