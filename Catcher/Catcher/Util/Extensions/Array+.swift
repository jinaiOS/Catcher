//
//  Array+.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import Foundation

extension Array {
    func randomElements(count: Int) -> [Element] {
        if count >= self.count {
            return self
        }
        let shuffledArray = self.shuffled()
        return Array(shuffledArray.prefix(count))
    }
}
