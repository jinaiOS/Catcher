//
//  BaseHeaderViewController.swift
//  Catcher
//
//  Created by 김지은 on 2023/10/13.
//

import UIKit
/**
 @class BaseHeaderViewController.swift
 
 @brief BaseViewController를 상속받은 ViewController
 
 @detail 네비게이션 Header가 있는 BaseHeaderViewController
 */
class BaseHeaderViewController: BaseViewController {
    
    /** @brief 공통 헤더 객체 */
    var headerView : CommonHeaderView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //iphone x의 경우 헤더 위치를 재설정한다.
        headerView = CommonHeaderView.init(frame: CGRect.init(x: 0, y: Common.kStatusbarHeight, width: Common.SCREEN_WIDTH(), height: 50))
        
        //header backButton selector setting
        headerView.btnBack.addTarget(self, action: #selector(backButtonTouched(sender:)), for: .touchUpInside)
        
        self.view.addSubview(headerView)
        // Do any additional setup after loading the view.
    }
    
    /**
     @brief header의 title을 변경한다.
     
     @param title
     */
    func backButtonHidden() {
        headerView.btnBack.isHidden = true
    }
    
    /**
     @brief header의 title을 변경한다.
     
     @param title
     */
    func setHeaderTitleName(title : String) {
        headerView.lblTitle.text = title
    }
    
    /**
     @brief header의 숨김처리 설정
     
     @param isHidden : true(숨김), false(노출)
     */
    func setHeaderHidden(isHidden : Bool) {
        headerView.isHidden = isHidden
    }
    
    /**
     @brief backButton을 눌렀을때 들어오는 이벤트
     
     @param sender 버튼 객체
     */
    @objc func backButtonTouched(sender : UIButton)
    {
        navigationPopViewController(animated: true) { () -> (Void) in }
    }
    
}
