//
//  ChatViewController.swift
//  Catcher
//
//  Created by 김지은 on 2023/10/18.
//

import UIKit
import FirebaseAuth

class ChatViewController: UIViewController {
    
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle  = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    /// 데이터
    private var conversations = [Conversation]()

    /// Conversation tableview
    private let tbvConversation: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(ConversationTableViewCell.self,
                       forCellReuseIdentifier: ConversationTableViewCell.identifier)
        return table
    }()

    /// 대화가 없을 때 나오는 label
    private let noConversationsLabel: UILabel = {
        let label = UILabel()
        label.text = "대화를 시작해 보세요."
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()

    // 사용자 로그인을 감지하기 위한 옵저버
    private var loginObserver: NSObjectProtocol?
    
    private let indicator = UIActivityIndicatorView()
    
    private lazy var indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.5)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ThemeColor.backGroundColor
        view.addSubview(tbvConversation)
        view.addSubview(noConversationsLabel)
        setupTableView()
        
        // 뷰가 로드될 때 대화를 듣기 시작
        startListeningForCOnversations()
        
        setIndicatorLayout()
        
        indicator.hidesWhenStopped = true
        indicator.stopAnimating()
        indicator.style = .large
        indicator.color = .systemOrange
        indicatorView.isHidden = true
    }
    
    func setIndicatorLayout() {
        indicatorView.addSubview(indicator)
        
        view.addSubview(indicatorView)
        
        indicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        indicatorView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func processIndicatorView() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            indicatorView.isHidden.toggle()
            if indicator.isAnimating {
                indicator.stopAnimating()
            } else {
                indicator.startAnimating()
            }
        }
    }

    // 대화를 가져와서 표시하기
    private func startListeningForCOnversations() {
        CommonUtil.print(output:"starting conversation fetch...")
        self.processIndicatorView()
        // 데이터베이스에서 대화 가져오기
        DatabaseManager.shared.getAllConversations(completion: { [weak self] result in
            switch result {
            case .success(let conversations):
                CommonUtil.print(output:"successfully got conversation models")
                guard !conversations.isEmpty else {
                    self?.tbvConversation.isHidden = true
                    self?.noConversationsLabel.isHidden = false
                    return
                }
                self?.noConversationsLabel.isHidden = true
                self?.tbvConversation.isHidden = false
                self?.conversations = conversations

                DispatchQueue.main.async {
                    self?.tbvConversation.reloadData()
                }
                self?.processIndicatorView()
            case .failure(let error):
                self?.tbvConversation.isHidden = true
                self?.noConversationsLabel.isHidden = false
                CommonUtil.print(output:"failed to get convos: \(error)")
                self?.processIndicatorView()
            }
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tbvConversation.frame = view.bounds
        noConversationsLabel.frame = CGRect(x: 10,
                                            y: (view.height-100)/2,
                                            width: view.width-20,
                                            height: 100)
    }

    private func setupTableView() {
        tbvConversation.delegate = self
        tbvConversation.dataSource = self
    }

}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier,
                                                 for: indexPath) as! ConversationTableViewCell
        cell.configure(with: model)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = conversations[indexPath.row]
        openConversation(model)
    }

    func openConversation(_ model: Conversation) {
        let vc = ChattingDetailViewController(otherUid: model.otherUserUid)
        vc.title = model.name
        vc.headerTitle = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // begin delete
            let conversationId = conversations[indexPath.row].senderUid
            tableView.beginUpdates()
            self.conversations.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)

            tableView.endUpdates()
        }
    }
}
