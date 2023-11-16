//
//  ImageFactoryViewModel.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import UIKit

final class ImageFactoryViewModel {
    private let genProfile = GenerateProfile()
    var image: UIImage?
    
    /** @brief 이미지 변환 이벤트 */
    func imageTasking() -> UIImage? {
        guard let image = image else { return UIImage(named: "default") }
        let generatedImage = genProfile.generateImage(image: image)
        self.image = generatedImage
        return generatedImage
    }
}
