//
//  MyPageViewController.swift
//  Catcher
//
//  Created by 정기현 on 2023/10/17.
//

import Combine
import SafariServices
import SnapKit
import UIKit

enum MenuItems: String, CaseIterable {
    case setProfile = "기본 프로필 설정"
    case genImage = "캐리커처 이미지 생성"
    case inquiry = "1:1 문의"
    case terms = "개인 정보 및 처리 방침"
    case termsUse = "이용 약관"
    case opensource = "오픈소스 라이선스"
    case version = "앱 버전"
    case withdraw = "회원 탈퇴"
}

final class MyPageViewController: BaseViewController {
    private var userInfo: UserInfo?
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var nickName: UILabel = {
        let lb = UILabel()
        lb.text = "익명 님 어서 오세요!!"
        lb.font = .systemFont(ofSize: 20, weight: .light)
        lb.textAlignment = .left
        lb.numberOfLines = 0 // 두 줄로 표시
        lb.lineBreakMode = .byWordWrapping
        return lb
    }()
    
    private lazy var profilePhoto: UIImageView = {
        let im = UIImageView()
        loadProfileImage()
        im.contentMode = .scaleAspectFill
        im.layer.cornerRadius = CGFloat(photoSize / 2) // 반지름을 이미지 크기의 절반으로 설정하여 원 모양으로 클리핑
        im.clipsToBounds = true // 이미지를 원 모양으로 클리핑
        return im
    }()
    
    private lazy var imgCamera: UIImageView = {
       let im = UIImageView()
        im.image = UIImage(systemName: "camera.fill")
        im.tintColor = .black
        return im
    }()
    
    private lazy var myMainView: UIView = {
        let vw = UIView()
        vw.backgroundColor = .white
        vw.layer.cornerRadius = 16
        vw.addSubview(myMainStack)
        vw.borderColor = ThemeColor.primary
        vw.borderWidth = 1
        return vw
    }()
    
    private lazy var myMainStack: UIStackView = {
        let st = UIStackView(arrangedSubviews: [myTemperatureStack, myPointStack, mySaveStack])
        st.axis = .horizontal
        st.alignment = .fill
        st.distribution = .fill
        st.spacing = spacingStackHorizontal
        return st
    }()
    
    private lazy var myTemperatureStack: UIStackView = {
        let st = UIStackView(arrangedSubviews: [myGenderNumber, myGenderLabel])
        st.axis = .vertical
        st.alignment = .fill
        st.distribution = .equalSpacing
        st.spacing = spacingStackVertical
        return st
    }()
    
    private lazy var myGenderNumber: UILabel = {
        let lb = UILabel()
        lb.font = .systemFont(ofSize: 20, weight: .bold)
        lb.textAlignment = .center
        return lb
    }()
    
    private lazy var myGenderLabel: UILabel = {
        let lb = UILabel()
        lb.text = "성별"
        lb.font = .systemFont(ofSize: labelFontSize, weight: .light)
        lb.textAlignment = .center
        return lb
    }()
    
    private lazy var myPointStack: UIStackView = {
        let st = UIStackView(arrangedSubviews: [myPickedNumber, myPickedLabel])
        st.axis = .vertical
        st.alignment = .fill
        st.distribution = .equalSpacing
        st.spacing = spacingStackVertical
        return st
    }()
    
    private lazy var myPickedNumber: UILabel = {
        let lb = UILabel()
        lb.font = .systemFont(ofSize: 20, weight: .bold)
        lb.textAlignment = .center
        return lb
    }()
    
    private lazy var myPickedLabel: UILabel = {
        let lb = UILabel()
        lb.text = "받은 찜"
        lb.font = .systemFont(ofSize: labelFontSize, weight: .light)
        lb.textAlignment = .center
        return lb
    }()
    
    private lazy var mySaveStack: UIStackView = {
        let st = UIStackView(arrangedSubviews: [mySaveNumber, mySaveLabel])
        st.axis = .vertical
        st.alignment = .fill
        st.distribution = .equalSpacing
        st.spacing = spacingStackVertical
        
        return st
    }()
    
    private lazy var mySaveNumber: UILabel = {
        let lb = UILabel()
        lb.font = .systemFont(ofSize: 20, weight: .bold)
        lb.textAlignment = .center
        return lb
    }()
    
    private lazy var mySaveLabel: UILabel = {
        let lb = UILabel()
        lb.text = "나의 찜"
        lb.font = .systemFont(ofSize: labelFontSize, weight: .light)
        lb.textAlignment = .center
        return lb
    }()
    
    let spacingStackVertical: CGFloat = 10
    let spacingStackHorizontal: CGFloat = 70
    let labelFontSize: CGFloat = 13
    let photoSize = 80
    var menuItems = MenuItems.setProfile
    var tableViewHeight: CGFloat = 0
    
    private lazy var myTableView: UIView = {
        let vw = UIView()
        vw.backgroundColor = .white
        vw.layer.cornerRadius = 16
        vw.addSubview(menuLabel)
        vw.addSubview(myTable)
        vw.borderColor = ThemeColor.primary
        vw.borderWidth = 1
        return vw
    }()
    
    private lazy var menuLabel: UILabel = {
        let lb = UILabel()
        lb.text = "메뉴"
        lb.font = .systemFont(ofSize: 20, weight: .bold)
        lb.textAlignment = .left
        return lb
    }()
    
    private lazy var myTable: UITableView = {
        let tb = UITableView()
        tb.register(MenuTableViewCell.self, forCellReuseIdentifier: MenuTableViewCell.identifier)
        // 경계선 지우기
        tb.separatorStyle = .none
        //  스크롤 x
        tb.isScrollEnabled = false
        tb.showsVerticalScrollIndicator = false
        return tb
    }()
    
    private lazy var logOutButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("로그아웃", for: .normal)
        btn.layer.cornerRadius = 15
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = ThemeColor.primary
        btn.titleLabel?.font = ThemeFont.demibold(size: 25)
        return btn
    }()

    private lazy var contentView: UIView = {
        let vw = UIView()
        [nickName, profilePhoto, imgCamera, myMainView, myTableView, logOutButton].forEach { vw.addSubview($0) }
        return vw
    }()

    private lazy var scrollView: UIScrollView = {
        let sc = UIScrollView()
        sc.showsVerticalScrollIndicator = false
        sc.addSubview(contentView)
        view.addSubview(sc)
        return sc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayout()
        configure()
    }
}

private extension MyPageViewController {
    func configure() {
        view.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
        logOutButton.addTarget(self, action: #selector(pressLogOutButton), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapProfileImage))
        profilePhoto.addGestureRecognizer(tapGesture)
        profilePhoto.isUserInteractionEnabled = true
        
        fetchPickCount { [weak self] pickCount in
            guard let self = self else { return }
            mySaveNumber.text = "\(pickCount)"
        }
        
        fetchMyInfo()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didRecievePickUserCountNotification),
            name: NSNotification.Name(NotificationManager.NotiName.pick.key),
            object: nil)
    }
    
    func fetchMyInfo() {
        Task {
            guard let uid = FirebaseManager().getUID else { return }
            let (userInfo, error) = await FireStoreManager.shared.fetchUserInfo(uuid: uid)
            let (myPickedCount, err) = await FireStoreManager.shared.fetchMyPickedCount()
            if let error {
                CommonUtil.print(output: error.localizedDescription)
            }
            if let userInfo {
                self.userInfo = userInfo
                myGenderNumber.text = userInfo.sex
                myPickedNumber.text = "만 \(Date.calculateAge(birthDate: userInfo.birth))세"
                nickName.text = "\(userInfo.nickName)님 어서 오세요!!"
            }
            
            if let err {
                CommonUtil.print(output: err.localizedDescription)
            }
            if let myPickedCount {
                myPickedNumber.text = "\(myPickedCount)"
            }
        }
    }
    
    @objc func didRecievePickUserCountNotification(_ notification: Notification) {
        let count = notification.object as? Int
        if let count {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                mySaveNumber.text = "\(count)"
            }
        }
    }
    
    func fetchPickCount(completion: @escaping (Int) -> Void) {
        Task {
            let (result, error) = await FireStoreManager.shared.fetchPickUsers()
            if let error {
                CommonUtil.print(output: error.localizedDescription)
            }
            guard let result = result else { return }
            completion(result.count)
        }
    }
}

extension MyPageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MenuItems.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let menuTableViewCell = tableView.dequeueReusableCell(withIdentifier: MenuTableViewCell.identifier, for: indexPath) as? MenuTableViewCell else {
            return UITableViewCell()
        }
        // 셀 선택시 색상 변경 x
        menuTableViewCell.selectionStyle = .none
        let menu = MenuItems.allCases[indexPath.row]
        menuTableViewCell.menuLabel.text = menu.rawValue
        return menuTableViewCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let vc = InfoViewController(userInfo: userInfo, isValidNickName: true)
            vc.delegate = self
            navigationPushController(viewController: vc, animated: true)
        case 1:
            let imageFactoryVC = ImageFactoryViewController()
            navigationPushController(viewController: imageFactoryVC, animated: true)
        case 2:
            let vc = AskViewController()
            navigationPushController(viewController: vc, animated: true)
        case 3:
            let url = URL(string: PRIVACY)
            let vc = SFSafariViewController(url: url!)
            present(vc, animated: true)
        case 4:
            let vc = TermsOfUseViewController()
            navigationPushController(viewController: vc, animated: true)
        case 5:
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        case 6:
            let appVersionVC = AppVersionViewController()
            navigationPushController(viewController: appVersionVC, animated: true)
        case 7:
            let revokeVC = RevokeViewController()
            navigationPushController(viewController: revokeVC, animated: true)
        default:
            break
        }
    }
}

extension MyPageViewController {
    @objc func pressLogOutButton() {
        showLogOutAlert()
    }
}

private extension MyPageViewController {
    func showLogOutAlert() {
        let alert = UIAlertController(
            title: "로그아웃",
            message: "로그아웃을 하시겠습니까?",
            preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .destructive) { _ in
            FirebaseManager().logOut
            AppDelegate.applicationDelegate().changeInitViewController(type: .Login)
        }
        let cancelAction = UIAlertAction(title: "취소", style: .default)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    func setLayout() {
        // 메뉴 아이템의 갯수에 따라 view의 높이를 변경
        tableViewHeight = CGFloat(MenuItems.allCases.count) * 44 + 70
        myTable.dataSource = self
        myTable.delegate = self
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom) // Set the bottom constraint to the top of the next button.
        }
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
            make.centerX.equalTo(scrollView)
        }
        nickName.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).inset(30)
            make.leading.equalTo(contentView.snp.leading).inset(27)
            make.trailing.equalTo(contentView.snp.trailing).inset(110)
//            make.height.equalTo(24)
        }
        profilePhoto.snp.makeConstraints { make in
            make.centerY.equalTo(nickName.snp.centerY)
            make.trailing.equalTo(contentView.snp.trailing).inset(20)
            make.height.width.equalTo(photoSize)
        }
        imgCamera.snp.makeConstraints { make in
            make.top.equalTo(profilePhoto).inset(50)
//            make.leading.equalTo(profilePhoto).inset(10)
            make.trailing.equalTo(contentView).inset(13)
            make.height.equalTo(25)
            make.width.equalTo(30)
        }
        myMainView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(contentView).inset(14)
            make.top.equalTo(nickName.snp.bottom).inset(-50)
            make.height.equalTo(100)
        }
        myMainStack.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(self.myMainView)
            make.height.equalTo(50
            )
        }
        menuLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.myTable)
            make.top.equalTo(self.myTableView).inset(20)
            make.height.equalTo(30)
        }
        myTable.snp.makeConstraints { make in
            make.bottom.equalTo(self.myTableView).inset(20)
            make.top.equalTo(self.menuLabel).inset(30)
            make.leading.equalTo(myTableView.snp_leadingMargin).inset(20)
            make.trailing.equalTo(self.myTableView).inset(20)
        }
        myTableView.snp.makeConstraints { make in
            make.top.equalTo(myMainView.snp.bottom).inset(-20)
            make.leading.trailing.equalTo(self.view).inset(14)
            make.height.equalTo(tableViewHeight)
        }
        logOutButton.snp.makeConstraints { make in
            make.top.equalTo(myTableView.snp.bottom).inset(-20)
          
            make.leading.trailing.equalTo(contentView).inset(14)
            make.height.equalTo(53)
            make.bottom.equalTo(contentView.snp.bottom).inset(20)
        }
    }
    
    func loadProfileImage() {
        guard let uid = FirebaseManager().getUID else { return }
        ImageCacheManager.shared.loadImage(uid: uid) { [weak self] image in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.profilePhoto.image = image
            }
        }
    }
    
    @objc func tapProfileImage() {
        let profileSettingVC = ProfileSettingViewController(allowAlbum: true)
        profileSettingVC.delegate = self
        navigationPushController(viewController: profileSettingVC, animated: true)
    }
}

extension MyPageViewController: ReloadProfileImage {
    func reloadProfile(profile: UIImage) {
        guard let uid = FirebaseManager().getUID else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.profilePhoto.image = profile
        }
        ImageCacheManager.shared.cachingImage(uid: uid, image: profile)
    }
}

extension MyPageViewController: UpdateUserInfo {
    func updateUserInfo() {
        fetchMyInfo()
    }
}
