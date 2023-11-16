//
//  Common.swift
//  Catcher
//
//  Created by 김지은 on 2023/10/13.
//

import UIKit

/**
 @struct Common.swift
 
 @brief 공통으로 사용하는 struct
 */
struct Common {
    
    /** @static statusbar높이 (CGFloat)*/
    static var kStatusbarHeight  : CGFloat {
        get {
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            return windowScene?.windows.first?.safeAreaInsets.top ?? 0
        }
    }
    
    /**
     @static
     
     @brief  screen 전체 사이즈
     
     @return CGRect
     */
    static func SCREEN_FULL() -> CGRect {
        return UIScreen.main.bounds
    }
    
    /**
     @static
     
     @brief  screen 넓이
     
     @return CGFloat
     */
    static func SCREEN_WIDTH() -> CGFloat {
        return Common.SCREEN_FULL().size.width
    }
    
    /**
     @static
     
     @brief  screen 높이
     
     @return CGFloat
     */
    static func SCREEN_HEIGHT() -> CGFloat {
        return Common.SCREEN_FULL().size.height
    }
    
    static var hasSafeArea: Bool {
        guard #available(iOS 11.0, *), let topPadding = (UIApplication.shared.delegate as? AppDelegate)?.window?.safeAreaInsets.top, topPadding > 24 else {
            return false
        }
        return true
    }
    
    static func IS_IPHONE_SE() -> Bool {
        return (SCREEN_WIDTH() == 320)
    }
}
