//
//  ContactViewController.swift
//  Catcher
//
//  Created by t2023-m0077 on 2023/10/20.
//

import UIKit

class ContactViewController: UIViewController {
    
    private let button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("저장", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    
    
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "연락처 차단"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    
    private let segmentedControl: UISegmentedControl = {
        let segmentedControl = UnderlineSegmentedControl(items: ["연락처", "차단된 연락처"])
        let font = UIFont.systemFont(ofSize: 40)
        
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()
    private let childView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let vc1: UIViewController = {
        let vc = UIViewController()
        return vc
    }()
    
    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "연락처를 검색해주세요"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchTextField.backgroundColor = ThemeColor.primary
        
        searchBar.setImage(UIImage(), for: .search, state: .normal)
        
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.textColor = UIColor.white // 텍스트색 변경
            if let placeholderLabel = textField.value(forKey: "attributedPlaceholder") as? NSAttributedString {
                let attributedString = NSMutableAttributedString(attributedString: placeholderLabel)
                attributedString.addAttributes([.foregroundColor: UIColor.white], range: NSRange(location: 0, length: attributedString.length))
                textField.attributedPlaceholder = attributedString
            }
        }
        return searchBar
    }()
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    private let vc2: UIViewController = {
        let vc = UIViewController()
        return vc
    }()
    private lazy var pageViewController: UIPageViewController = {
        let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        vc.setViewControllers([self.dataViewControllers[0]], direction: .forward, animated: true)
        vc.delegate = self
        vc.dataSource = self
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        return vc
    }()
    
    var dataViewControllers: [UIViewController] {
        [self.vc1, self.vc2]
    }
    var currentPage: Int = 0 {
        didSet {
            // from segmentedControl -> pageViewController 업데이트
            print(oldValue, self.currentPage)
            let direction: UIPageViewController.NavigationDirection = oldValue <= self.currentPage ? .forward : .reverse
            self.pageViewController.setViewControllers(
                [dataViewControllers[self.currentPage]],
                direction: direction,
                animated: true,
                completion: nil
            )
        }
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "ContactTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "ContactTableViewCell")
        self.view.addSubview(button)
        self.view.addSubview(label)
        self.view.addSubview(self.segmentedControl)
        self.view.addSubview(self.pageViewController.view)
        self.view.addSubview(searchBar)
        self.view.addSubview(tableView)
        
        // 버튼의 위치 제약 조건 설정
        button.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        button.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        
        // 버튼의 너비와 높이 설정
        button.widthAnchor.constraint(equalToConstant: 700).isActive = true
        button.heightAnchor.constraint(equalToConstant: 140).isActive = true
        
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1).isActive = true
        
        
        NSLayoutConstraint.activate([
            self.segmentedControl.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.segmentedControl.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.segmentedControl.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 79),
            self.segmentedControl.heightAnchor.constraint(equalToConstant: 60),
        ])
        NSLayoutConstraint.activate([
            self.pageViewController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 4),
            self.pageViewController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -4),
            self.pageViewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -4),
            self.pageViewController.view.topAnchor.constraint(equalTo: self.segmentedControl.bottomAnchor, constant: 5),
        ])
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 85),
            searchBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            searchBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            
            
        ])
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor, constant: 0),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            
            
        ])
        
        
        self.segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.gray], for: .normal)
        self.segmentedControl.setTitleTextAttributes(
            [
                NSAttributedString.Key.foregroundColor: UIColor.black,
                .font: UIFont.systemFont(ofSize: 15, weight: .semibold)
            ],
            for: .selected
        )
        self.segmentedControl.addTarget(self, action: #selector(changeValue(control:)), for: .valueChanged)
        self.segmentedControl.selectedSegmentIndex = 0
        self.changeValue(control: self.segmentedControl)
    }
    
    
    
    
    @objc private func changeValue(control: UISegmentedControl) {
        // 코드로 값을 변경하면 해당 메소드 호출 x
        self.currentPage = control.selectedSegmentIndex
    }
}

extension ContactViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard
            let index = self.dataViewControllers.firstIndex(of: viewController),
            index - 1 >= 0
        else { return nil }
        
        return self.dataViewControllers[index - 1]
    }
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard
            let index = self.dataViewControllers.firstIndex(of: viewController),
            index + 1 < self.dataViewControllers.count
        else { return nil }
        return self.dataViewControllers[index + 1]
    }
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard
            let viewController = pageViewController.viewControllers?[0],
            let index = self.dataViewControllers.firstIndex(of: viewController)
        else { return }
        self.currentPage = index
        self.segmentedControl.selectedSegmentIndex = index
    }
}

extension ContactViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell", for: indexPath) as? ContactTableViewCell else { return UITableViewCell() }
        cell.nameLabel.text = "aa"
        cell.phoneLabel.text = "bb"
        return cell
    }
    
    
    
}
