//
//  ChatViewController.swift
//  Catcher
//
//  Created by 김지은 on 2023/10/18.
//

import UIKit
import FirebaseAuth

class ChatViewController: UIViewController {
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // 내비게이션 바 설정
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose,
                                                            target: self,
                                                            action: #selector(didTapComposeButton))
        view.addSubview(tbvConversation)
        view.addSubview(noConversationsLabel)
        setupTableView()
        
        // 뷰가 로드될 때 대화를 듣기 시작
        startListeningForCOnversations()

        // 사용자 로그인 알림을 위한 옵저버
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main, using: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.startListeningForCOnversations()
        })
    }

    // 대화를 가져와서 표시하기
    private func startListeningForCOnversations() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }

        // 기존의 옵저버가 있다면 제거
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }

        print("starting conversation fetch...")

        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)

        // 데이터베이스에서 대화 가져오기
        DatabaseManager.shared.getAllConversations(for: safeEmail, completion: { [weak self] result in
            switch result {
            case .success(let conversations):
                print("successfully got conversation models")
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
            case .failure(let error):
                self?.tbvConversation.isHidden = true
                self?.noConversationsLabel.isHidden = false
                print("failed to get convos: \(error)")
            }
        })
    }

    // 쓰기 버튼이 눌렸을 때의 액션
    @objc private func didTapComposeButton() {
        let vc = NewConversationViewController()
        vc.completion = { [weak self] result in
            guard let strongSelf = self else {
                return
            }

            let currentConversations = strongSelf.conversations

            if let targetConversation = currentConversations.first(where: {
                $0.otherUserEmail == DatabaseManager.safeEmail(emailAddress: result.email)
            }) {
                let vc = ChattingDetailViewController(with: targetConversation.otherUserEmail, id: targetConversation.id)
                vc.isNewConversation = false
                vc.title = targetConversation.name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            }
            else {
                strongSelf.createNewConversation(result: result)
            }
        }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }

    private func createNewConversation(result: SearchResult) {
        let name = result.name
        let email = DatabaseManager.safeEmail(emailAddress: result.email)

        // 이 두 사용자 간의 대화가 이미 있는지 확인
        // 있다면 대화 ID 재사용, 아니면 새 코드 사용
        DatabaseManager.shared.conversationExists(iwth: email, completion: { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            switch result {
            case .success(let conversationId):
                let vc = ChattingDetailViewController(with: email, id: conversationId)
                vc.isNewConversation = false
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            case .failure(_):
                let vc = ChattingDetailViewController(with: email, id: nil)
                vc.isNewConversation = true
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
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
    
    // 뷰가 나타날 때 인증 유효성 검사
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
    }

    private func validateAuth() {
//        if FirebaseAuth.Auth.auth().currentUser == nil {
//            let vc = LoginViewController()
//            let nav = UINavigationController(rootViewController: vc)
//            nav.modalPresentationStyle = .fullScreen
//            present(nav, animated: false)
//        }
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
        let vc = ChattingDetailViewController(with: model.otherUserEmail, id: model.id)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // begin delete
            let conversationId = conversations[indexPath.row].id
            tableView.beginUpdates()
            self.conversations.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)

            DatabaseManager.shared.deleteConversation(conversationId: conversationId, completion: { success in
                if !success {
                    // add model and row back and show error alert

                }
            })

            tableView.endUpdates()
        }
    }
}
